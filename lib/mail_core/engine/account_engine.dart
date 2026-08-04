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

  Future<void> setBackground(bool background) async {
    await imapWorker?.setPollMode(background);
  }
}
