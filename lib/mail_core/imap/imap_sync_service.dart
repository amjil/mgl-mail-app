import 'dart:async';

import 'package:drift/drift.dart';
import 'package:enough_mail/enough_mail.dart';

import '../db/app_database.dart';
import '../search/fts_indexer.dart';

class ImapSyncService {
  ImapSyncService({
    required this.db,
    required this.account,
    required this.getSecret,
    this.useOAuth = false,
    this.isLogEnabled = false,
  }) : indexer = FtsIndexer(db);

  final AppDatabase db;
  final Account account;

  /// Password or OAuth access token (resolved just-in-time for refresh).
  final Future<String> Function() getSecret;
  final bool useOAuth;
  final bool isLogEnabled;
  final FtsIndexer indexer;

  ImapClient? _client;

  /// Serializes IMAP command sequences (single connection is not concurrent-safe).
  Future<void> _opChain = Future<void>.value();

  bool get isConnected => _client?.isLoggedIn ?? false;
  ImapClient get client {
    final c = _client;
    if (c == null) {
      throw StateError('IMAP client not connected');
    }
    return c;
  }

  Future<T> _serialized<T>(Future<T> Function() action) {
    final gate = Completer<void>();
    final prev = _opChain;
    _opChain = gate.future;
    return prev.catchError((_) {}).then((_) => action()).whenComplete(() {
      gate.complete();
    });
  }

  Future<void> connect() async {
    if (isConnected) return;
    final c = ImapClient(isLogEnabled: isLogEnabled);
    await c.connectToServer(
      account.imapHost,
      account.imapPort,
      isSecure: account.imapSsl,
    );
    final secret = await getSecret();
    if (useOAuth) {
      await c.authenticateWithOAuth2(account.username, secret);
    } else {
      await c.login(account.username, secret);
    }
    _client = c;
  }

  Future<void> disconnect() async {
    final c = _client;
    if (c == null) return;
    try {
      if (c.isLoggedIn) await c.logout();
    } catch (_) {}
    try {
      await c.disconnect();
    } catch (_) {}
    _client = null;
  }

  Future<void> syncAll({int inboxLimit = 50}) => _serialized(() async {
        await connect();
        await syncFolders();
        // Inbox is required; sent is best-effort so one bad Sent path
        // cannot wipe the whole sync.
        await _syncRoleSafe('inbox', limit: inboxLimit, required: true);
        await _syncRoleSafe('sent', limit: inboxLimit, required: false);
      });

  Future<void> _syncRoleSafe(
    String role, {
    required int limit,
    required bool required,
  }) async {
    try {
      await syncFolderByRole(role, limit: limit);
    } catch (e) {
      // ignore: avoid_print
      print('syncFolderByRole($role) failed: $e');
      if (required) rethrow;
    }
  }

  Future<void> syncFolders() async {
    final boxes = await client.listMailboxes(recursive: true);
    for (final box in boxes) {
      // SELECT requires the IMAP-encoded path (modified UTF-7), not decoded.
      final path = box.encodedPath.trim();
      if (path.isEmpty) continue;
      await db.folderDao.upsertFolder(
        FoldersCompanion.insert(
          accountId: account.id,
          name: box.name,
          path: path,
          role: _mapRole(box),
          selectable: Value(!box.isNotSelectable),
        ),
      );
    }
    // Guarantee an inbox row even when the server omits \Inbox / special-use.
    final inbox = await db.folderDao.findByRole(account.id, 'inbox');
    if (inbox == null) {
      await db.folderDao.upsertFolder(
        FoldersCompanion.insert(
          accountId: account.id,
          name: 'INBOX',
          path: 'INBOX',
          role: 'inbox',
          selectable: const Value(true),
        ),
      );
    }
  }

  String _mapRole(Mailbox box) {
    if (box.isInbox) return 'inbox';
    if (box.isSent) return 'sent';
    if (box.isTrash) return 'trash';
    if (box.isDrafts) return 'draft';
    final n = box.name.toLowerCase().trim();
    if (n == 'inbox') return 'inbox';
    if (n == 'sent' || n == 'sent items' || n == 'sent messages') {
      return 'sent';
    }
    if (n == 'drafts' || n == 'draft') {
      return 'draft';
    }
    if (n == 'trash' || n == 'deleted items') {
      return 'trash';
    }
    return 'custom';
  }

  Future<void> syncFolderByRole(String role, {int limit = 50}) async {
    final folder = await db.folderDao.findByRole(account.id, role);
    if (folder == null) return;
    await syncFolderMessages(folder, limit: limit);
  }

  Future<void> syncFolderMessages(Folder folder, {int limit = 50}) async {
    final path = folder.path.trim();
    if (path.isEmpty || !folder.selectable) return;
    late final Mailbox mailbox;
    try {
      if (folder.role == 'inbox') {
        // INBOX is case-insensitive and always exists — prefer dedicated API.
        mailbox = await client.selectInbox();
      } else {
        mailbox = await client.selectMailboxByPath(path);
      }
    } catch (e) {
      // ignore: avoid_print
      print('SELECT failed path="$path" role=${folder.role}: $e');
      rethrow;
    }
    final validity = mailbox.uidValidity;

    final sync = await db.syncStateDao.find(account.id, folder.id);
    if (sync?.uidValidity != null &&
        validity != null &&
        sync!.uidValidity != validity) {
      // UIDVALIDITY changed — refetch recent window only (no full repair).
      // ignore: avoid_print
      print('UIDVALIDITY changed for ${folder.path}; refetching recent');
    }

    final search = await client.uidSearchMessages(searchCriteria: 'ALL');
    final allUids = search.matchingSequence?.toList() ?? <int>[];
    if (allUids.isEmpty) {
      await _saveSyncState(folder.id, 0, validity);
      return;
    }

    allUids.sort();
    final target = allUids.length <= limit
        ? allUids
        : allUids.sublist(allUids.length - limit);
    final targetStr = target.map((e) => '$e').toList();
    final existing = await db.messageDao.findExistingUids(folder.id, targetStr);
    final newUids =
        target.where((u) => !existing.contains('$u')).toList(growable: false);
    if (newUids.isNotEmpty) {
      await _fetchAndStoreHeaders(folder, newUids);
    }

    // Refresh flags for known recent UIDs
    await _fetchAndUpdateFlags(folder, target);

    final lastUid = target.isEmpty ? 0 : target.last;
    await _saveSyncState(folder.id, lastUid, validity);
  }

  Future<void> syncMailboxDelta(Mailbox mailbox) => _serialized(() async {
        await connect();
        final path = mailbox.encodedPath;
        var folder = await db.folderDao.findByPath(account.id, path);
        if (folder == null) {
          await syncFolders();
          folder = await db.folderDao.findByPath(account.id, path);
          if (folder == null) return;
        }
        await syncFolderMessages(folder, limit: 30);
      });

  Future<void> _fetchAndStoreHeaders(Folder folder, List<int> uids) async {
    // Sina (and similar CN ISP IMAP) rejects many multi-attr FETCH forms with
    // "BAD Excessively complex FETCH attribute list". Try simplest first,
    // in small chunks.
    const criteriaOptions = <String>[
      '(FLAGS ENVELOPE)',
      '(ENVELOPE)',
      'ENVELOPE',
      '(FLAGS BODY.PEEK[HEADER])',
      'BODY.PEEK[HEADER]',
      'RFC822.HEADER',
      'FAST',
    ];

    String? workingCriteria;
    for (var i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10);
      final sequence = MessageSequence.fromIds(chunk, isUid: true);
      final result = await _uidFetchWithFallback(
        sequence,
        workingCriteria != null ? [workingCriteria] : criteriaOptions,
      );
      workingCriteria ??= result.$1;
      for (final mime in result.$2.messages) {
        await upsertFromMime(folder, mime);
      }
    }
  }

  /// Returns `(criteriaUsed, fetchResult)`.
  Future<(String, FetchImapResult)> _uidFetchWithFallback(
    MessageSequence sequence,
    List<String> criteriaOptions,
  ) async {
    Object? lastError;
    for (final criteria in criteriaOptions) {
      try {
        final result = await client.uidFetchMessages(sequence, criteria);
        return (criteria, result);
      } catch (e) {
        lastError = e;
        final msg = e.toString();
        final retryable = msg.contains('Excessively complex') ||
            msg.contains('BAD') ||
            msg.contains('parse');
        // ignore: avoid_print
        print('UID FETCH $criteria failed: $e');
        if (!retryable) rethrow;
      }
    }
    throw lastError ?? StateError('UID FETCH failed with no criteria');
  }

  Future<void> _fetchAndUpdateFlags(Folder folder, List<int> uids) async {
    if (uids.isEmpty) return;
    // UID FETCH already returns UIDs; keep attribute list minimal for Sina.
    for (var i = 0; i < uids.length; i += 20) {
      final chunk = uids.sublist(i, i + 20 > uids.length ? uids.length : i + 20);
      final sequence = MessageSequence.fromIds(chunk, isUid: true);
      FetchImapResult result;
      try {
        result = await client.uidFetchMessages(sequence, '(FLAGS)');
      } catch (_) {
        try {
          result = await client.uidFetchMessages(sequence, 'FLAGS');
        } catch (e) {
          // ignore: avoid_print
          print('FLAGS FETCH failed: $e');
          return;
        }
      }
      for (final mime in result.messages) {
        final uid = mime.uid;
        if (uid == null) continue;
        final existing =
            await db.messageDao.findByUid(account.id, folder.id, '$uid');
        if (existing == null) continue;
        await db.messageDao.updateMessage(
          existing.id,
          MessagesCompanion(
            isRead: Value(mime.isSeen),
            isStarred: Value(mime.isFlagged),
            deleted: Value(mime.isDeleted),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }
  }

  Future<int> upsertFromMime(Folder folder, MimeMessage mime) async {
    final uid = mime.uid;
    final uidStr = uid?.toString();
    final from = mime.from?.isNotEmpty == true ? mime.from!.first : null;
    final to = _joinAddresses(mime.to);
    final cc = _joinAddresses(mime.cc);
    final subject = mime.decodeSubject();
    final date = mime.decodeDate() ?? DateTime.now();
    final messageId =
        mime.getHeaderValue('message-id') ?? mime.envelope?.messageId;
    final clientId = mime.getHeaderValue('x-client-message-id');
    // ENVELOPE-only FETCH has no bodystructure; treat as unknown/false.
    final hasAtt = mime.hasAttachments();
    final state = folder.role == 'sent'
        ? 'sent'
        : folder.role == 'draft'
            ? 'draft'
            : 'inbox';

    if (uidStr != null) {
      final existing =
          await db.messageDao.findByUid(account.id, folder.id, uidStr);
      if (existing != null) {
        await db.messageDao.updateMessage(
          existing.id,
          MessagesCompanion(
            messageId: Value(messageId),
            clientMessageId: Value(clientId ?? existing.clientMessageId),
            fromAddr: Value(from?.email ?? existing.fromAddr),
            fromName: Value(from?.personalName ?? existing.fromName),
            toAddr: Value(to),
            ccAddr: Value(cc),
            subject: Value(subject),
            date: Value(date),
            isRead: Value(mime.isSeen),
            isStarred: Value(mime.isFlagged),
            hasAttachment: Value(hasAtt),
            size: Value(mime.size),
            state: Value(state),
            updatedAt: Value(DateTime.now()),
          ),
        );
        await indexer.indexMessage(
          messageId: existing.id,
          accountId: account.id,
          subject: subject,
          fromAddr: from?.email,
          toAddr: to,
        );
        return existing.id;
      }
    }

    // Sent reconcile: claim by client / RFC message-id
    if (clientId != null && clientId.isNotEmpty) {
      final byClient =
          await db.messageDao.findByClientMessageId(account.id, clientId);
      if (byClient != null) {
        await db.messageDao.updateMessage(
          byClient.id,
          MessagesCompanion(
            folderId: Value(folder.id),
            uid: Value(uidStr),
            messageId: Value(messageId),
            state: const Value('sent'),
            isRead: Value(mime.isSeen),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return byClient.id;
      }
    }
    if (messageId != null && messageId.isNotEmpty) {
      final byMid =
          await db.messageDao.findByRfcMessageId(account.id, messageId);
      if (byMid != null) {
        await db.messageDao.updateMessage(
          byMid.id,
          MessagesCompanion(
            folderId: Value(folder.id),
            uid: Value(uidStr),
            state: Value(state),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return byMid.id;
      }
    }

    final id = await db.messageDao.insertMessage(
      MessagesCompanion.insert(
        accountId: account.id,
        folderId: Value(folder.id),
        uid: Value(uidStr),
        messageId: Value(messageId),
        clientMessageId: Value(clientId),
        fromAddr: Value(from?.email ?? ''),
        fromName: Value(from?.personalName),
        toAddr: Value(to),
        ccAddr: Value(cc),
        subject: Value(subject),
        date: date,
        state: Value(state),
        isRead: Value(mime.isSeen),
        isStarred: Value(mime.isFlagged),
        hasAttachment: Value(hasAtt),
        size: Value(mime.size),
      ),
    );

    await indexer.indexMessage(
      messageId: id,
      accountId: account.id,
      subject: subject,
      fromAddr: from?.email,
      toAddr: to,
    );

    if (hasAtt) {
      await _storeAttachmentMeta(id, mime);
    }
    return id;
  }

  Future<void> _storeAttachmentMeta(int messageId, MimeMessage mime) async {
    final parts = mime.findContentInfo(disposition: ContentDisposition.attachment);
    for (final info in parts) {
      await db.attachmentDao.upsertMeta(
        AttachmentsCompanion.insert(
          messageId: messageId,
          filename: info.fileName ?? 'attachment',
          mimeType: Value(info.contentType?.mediaType.toString()),
          size: Value(info.size),
          partId: Value(info.fetchId),
          contentId: Value(info.cid),
        ),
      );
    }
  }

  Future<void> downloadBodyIfNeeded(int messageId) => _serialized(() async {
        final message = await db.messageDao.findById(messageId);
        if (message == null || message.uid == null || message.folderId == null) {
          return;
        }
        final body = await db.messageBodyDao.find(messageId);
        if (body?.isDownloaded == true) return;

        final folder = await db.folderDao.findById(message.folderId!);
        if (folder == null || folder.path.trim().isEmpty) return;

        await connect();
        if (folder.role == 'inbox') {
          await client.selectInbox();
        } else {
          await client.selectMailboxByPath(folder.path);
        }
        final uid = int.parse(message.uid!);
        // Prefer PEEK so opening mail does not flip \Seen on the server twice;
        // fall back for servers that reject BODY.PEEK[].
        FetchImapResult? result;
        for (final criteria in ['BODY.PEEK[]', 'BODY[]', 'RFC822']) {
          try {
            result = await client.uidFetchMessage(
              uid,
              criteria,
              responseTimeout: const Duration(seconds: 30),
            );
            break;
          } catch (e) {
            // ignore: avoid_print
            print('uidFetchMessage($criteria) failed: $e');
          }
        }
        if (result == null || result.messages.isEmpty) return;
        final mime = result.messages.first;
        final plain = mime.decodeTextPlainPart();
        final html = mime.decodeTextHtmlPart();
        await db.messageBodyDao.upsert(
          MessageBodiesCompanion.insert(
            messageId: Value(messageId),
            plainText: Value(plain),
            htmlText: Value(html),
            isDownloaded: const Value(true),
            downloadedAt: Value(DateTime.now()),
          ),
        );
        await indexer.indexMessage(
          messageId: messageId,
          accountId: account.id,
          subject: message.subject,
          body: plain ?? html,
          fromAddr: message.fromAddr,
          toAddr: message.toAddr,
        );
        if (mime.hasAttachments()) {
          await _storeAttachmentMeta(messageId, mime);
        }
      });

  Future<void> applyExpungeSequenceIds(
    Folder folder,
    List<int> sequenceIds,
  ) async {
    // Sequence IDs are volatile; best-effort: mark matching recent msgs deleted
    // via FLAGS sync instead when possible. Here we no-op if we only have seq.
    // Caller should follow with a flag/delta sync.
    await syncFolderMessages(folder, limit: 50);
  }

  Future<void> _saveSyncState(int folderId, int lastUid, int? validity) {
    return db.syncStateDao.upsert(
      SyncStatesCompanion.insert(
        accountId: account.id,
        folderId: folderId,
        lastUid: Value(lastUid),
        uidValidity: Value(validity),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }

  String _joinAddresses(List<MailAddress>? addrs) {
    if (addrs == null || addrs.isEmpty) return '';
    return addrs.map((a) => a.email).join(', ');
  }
}
