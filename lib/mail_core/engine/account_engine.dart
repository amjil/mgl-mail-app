import 'package:drift/drift.dart';
import 'package:enough_mail/enough_mail.dart';

import '../db/app_database.dart';
import '../imap/attachment_downloader.dart';
import '../imap/imap_sync_service.dart';
import '../oauth/outlook_oauth.dart';
import '../secure/account_credential_store.dart';
import '../sent/sent_reconcile_service.dart';
import '../smtp/imap_append_service.dart';
import '../smtp/smtp_service.dart';
import '../workers/imap_worker.dart';
import '../workers/outbox_worker.dart';
import '../workers/sent_worker.dart';

/// Per-account runtime: IMAP / Outbox / Sent workers.
class AccountEngine {
  AccountEngine({
    required this.db,
    required this.account,
    required this.credentials,
    OutlookOAuth? oauth,
  }) : oauth = oauth ?? OutlookOAuth();

  final AppDatabase db;
  final Account account;
  final AccountCredentialStore credentials;
  final OutlookOAuth oauth;

  ImapSyncService? sync;
  ImapWorker? imapWorker;
  OutboxWorker? outboxWorker;
  SentWorker? sentWorker;
  AttachmentDownloader? attachments;

  String get accountId => account.id;

  bool get _useOAuth => AuthType.parse(account.authType) == AuthType.oauth2;

  Future<String> _resolveSecret() async {
    if (_useOAuth) {
      var token = await credentials.readOAuth(account.id);
      if (token == null) {
        throw StateError('No OAuth token in keychain for ${account.id}');
      }
      if (token.isExpired) {
        token = await oauth.refresh(token);
        await credentials.saveOAuth(account.id, token);
      }
      return token.accessToken;
    }
    final password = await credentials.readPassword(account.id);
    if (password == null || password.isEmpty) {
      throw StateError('No password in keychain for ${account.id}');
    }
    return password;
  }

  Future<void> start() async {
    // Validate credentials exist before starting workers.
    await _resolveSecret();

    sync = ImapSyncService(
      db: db,
      account: account,
      getSecret: _resolveSecret,
      useOAuth: _useOAuth,
    );
    attachments = AttachmentDownloader(sync!);
    final smtp = SmtpService(
      account: account,
      getSecret: _resolveSecret,
      useOAuth: _useOAuth,
    );
    final append = ImapAppendService(sync!);
    final reconcile = SentReconcileService(sync!);

    imapWorker = ImapWorker(db: db, account: account, sync: sync!);
    Future<T> exclusive<T>(Future<T> Function() action) {
      final w = imapWorker;
      if (w != null) return w.runExclusive(action);
      return action();
    }

    outboxWorker = OutboxWorker(
      db: db,
      account: account,
      smtp: smtp,
      appendService: append,
      runExclusive: exclusive,
    );
    sentWorker = SentWorker(
      db: db,
      account: account,
      reconcile: reconcile,
      runExclusive: exclusive,
    );

    imapWorker!.start();
    outboxWorker!.start();
    sentWorker!.start();
  }

  Future<void> stop() async {
    await imapWorker?.stop();
    await outboxWorker?.stop();
    await sentWorker?.stop();
    await sync?.disconnect();
  }

  Future<void> syncNow() async {
    final worker = imapWorker;
    if (worker != null) {
      // Goes through worker so IDLE is stopped before SELECT.
      await worker.syncNow();
    } else {
      await sync?.syncAll();
    }
  }

  /// Sync a single mailbox by local folder id (stop IDLE → SELECT → fetch).
  Future<void> syncFolder(int folderId) async {
    final folder = await db.folderDao.findById(folderId);
    if (folder == null || folder.accountId != account.id) return;
    final s = sync;
    if (s == null) return;
    final worker = imapWorker;
    // For well-known roles, re-probe live LIST so we don't sync an empty twin.
    // Name can still map localized Drafts/Archive even when DB role is stale custom.
    Future<void> action() async {
      final role = s.effectiveRole(folder);
      if (role == 'draft' ||
          role == 'trash' ||
          role == 'junk' ||
          role == 'sent' ||
          role == 'archive') {
        await s.syncFolderByRole(role);
      } else {
        await s.syncFolderMessages(folder);
      }
    }

    if (worker != null) {
      await worker.runExclusive(action);
    } else {
      await action();
    }
  }

  Future<void> syncRole(String role) async {
    final s = sync;
    if (s == null) return;
    final worker = imapWorker;
    if (worker != null) {
      await worker.runExclusive(() => s.syncFolderByRole(role));
    } else {
      await s.syncFolderByRole(role);
    }
  }

  Future<void> downloadBodyIfNeeded(int messageId) async {
    final s = sync;
    if (s == null) return;
    final worker = imapWorker;
    if (worker != null) {
      await worker.runExclusive(() => s.downloadBodyIfNeeded(messageId));
    } else {
      await s.downloadBodyIfNeeded(messageId);
    }
  }

  Future<Attachment?> downloadAttachment(int attachmentId) async {
    final downloader = attachments;
    if (downloader == null) return null;
    final worker = imapWorker;
    if (worker != null) {
      return worker.runExclusive(() => downloader.download(attachmentId));
    }
    return downloader.download(attachmentId);
  }

  Future<void> deleteMessage(int messageId) async {
    final message = await db.messageDao.findById(messageId);
    if (message == null || message.accountId != account.id) return;

    final s = sync;
    final hasImap = message.uid != null && message.folderId != null;

    // IMAP first so we don't claim success when the server still has the mail.
    if (hasImap) {
      if (s == null) {
        throw StateError('IMAP not ready; cannot delete on server');
      }
      final worker = imapWorker;
      if (worker != null) {
        await worker.runExclusive(() => s.deleteRemoteMessage(message));
      } else {
        await s.deleteRemoteMessage(message);
      }
    }

    await db.messageDao.markDeleted(messageId);
    await db.outboxDao.deleteByMessageId(messageId);
  }

  /// Move message to [targetRole] (e.g. `archive`) on IMAP + update local row.
  Future<void> moveMessageToRole(int messageId, String targetRole) async {
    final message = await db.messageDao.findById(messageId);
    if (message == null || message.accountId != account.id) return;

    final targetFolder = await db.folderDao.findByRole(account.id, targetRole);
    if (targetFolder == null) {
      throw StateError('No $targetRole folder for account ${account.id}');
    }

    if (message.state == targetRole && message.folderId == targetFolder.id) {
      return;
    }

    final hasImap = message.uid != null && message.folderId != null;
    String? newUid = message.uid;
    var folderId = targetFolder.id;

    if (hasImap) {
      final s = sync;
      if (s == null) {
        throw StateError('IMAP not ready; cannot move on server');
      }
      final worker = imapWorker;
      final result = worker != null
          ? await worker.runExclusive(
              () => s.moveRemoteMessageToRole(message, targetRole),
            )
          : await s.moveRemoteMessageToRole(message, targetRole);
      folderId = result.folderId;
      newUid = result.uid;
    }

    await db.messageDao.updateMessage(
      messageId,
      MessagesCompanion(
        folderId: Value(folderId),
        uid: Value(newUid),
        state: Value(targetRole),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Best-effort APPEND draft MIME to server Drafts; returns new UID when known.
  Future<String?> appendDraft(MimeMessage mime) async {
    final s = sync;
    if (s == null) return null;
    final append = ImapAppendService(s);
    final worker = imapWorker;
    if (worker != null) {
      return worker.runExclusive(() => append.appendToDrafts(mime));
    }
    return append.appendToDrafts(mime);
  }

  /// Remove a superseded Drafts UID (e.g. after re-APPEND on edit). Best-effort.
  Future<void> expungeDraftUid({
    required String uid,
    required int folderId,
  }) async {
    final s = sync;
    if (s == null) return;
    final worker = imapWorker;
    if (worker != null) {
      await worker.runExclusive(() => s.expungeRemoteUid(folderId, uid));
    } else {
      await s.expungeRemoteUid(folderId, uid);
    }
  }

  /// Best-effort flag sync to IMAP (`\Seen` / `\Flagged`).
  Future<void> setMessageFlags(
    int messageId, {
    bool? seen,
    bool? flagged,
  }) async {
    final message = await db.messageDao.findById(messageId);
    if (message == null || message.accountId != account.id) return;
    if (message.uid == null || message.folderId == null) return;
    final s = sync;
    if (s == null) return;
    final worker = imapWorker;
    if (worker != null) {
      await worker.runExclusive(
        () => s.setRemoteFlags(message, seen: seen, flagged: flagged),
      );
    } else {
      await s.setRemoteFlags(message, seen: seen, flagged: flagged);
    }
  }

  Future<void> setBackground(bool background) async {
    await imapWorker?.setPollMode(background);
  }

  Future<void> createFolder(String path) async {
    final s = sync;
    if (s == null) {
      throw StateError('IMAP not ready; cannot create folder');
    }
    final worker = imapWorker;
    if (worker != null) {
      await worker.runExclusive(() => s.createFolder(path));
    } else {
      await s.createFolder(path);
    }
  }

  Future<void> renameFolder(String oldPath, String newPath) async {
    final s = sync;
    if (s == null) {
      throw StateError('IMAP not ready; cannot rename folder');
    }
    final worker = imapWorker;
    if (worker != null) {
      await worker.runExclusive(() => s.renameFolder(oldPath, newPath));
    } else {
      await s.renameFolder(oldPath, newPath);
    }
  }

  Future<void> deleteFolder(String path) async {
    final s = sync;
    if (s == null) {
      throw StateError('IMAP not ready; cannot delete folder');
    }
    final worker = imapWorker;
    if (worker != null) {
      await worker.runExclusive(() => s.deleteFolder(path));
    } else {
      await s.deleteFolder(path);
    }
  }
}
