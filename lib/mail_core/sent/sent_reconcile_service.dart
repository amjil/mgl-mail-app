import 'package:drift/drift.dart';
import 'package:enough_mail/enough_mail.dart';

import '../db/app_database.dart';
import '../imap/imap_sync_service.dart';
import '../search/fts_indexer.dart';

/// Claims local outbox/sent rows when IMAP Sent messages arrive.
class SentReconcileService {
  SentReconcileService(this.sync) : indexer = FtsIndexer(sync.db);

  final ImapSyncService sync;
  final FtsIndexer indexer;
  AppDatabase get db => sync.db;

  Future<void> reconcileRecent({int limit = 40}) async {
    final folder = await db.folderDao.findSent(sync.account.id);
    if (folder == null) return;
    await sync.connect();
    if (folder.role == 'inbox') {
      await sync.client.selectInbox();
    } else {
      await sync.client.selectMailboxByPath(folder.path);
    }
    final search = await sync.client.uidSearchMessages(searchCriteria: 'ALL');
    final uids = search.matchingSequence?.toList() ?? <int>[];
    if (uids.isEmpty) return;
    uids.sort();
    final target =
        uids.length <= limit ? uids : uids.sublist(uids.length - limit);
    final sequence = MessageSequence.fromIds(target, isUid: true);
    // Prefer simple ENVELOPE; fall back for Sina-like servers.
    Object? lastError;
    FetchImapResult? result;
    for (final criteria in const [
      '(FLAGS ENVELOPE)',
      '(ENVELOPE)',
      'ENVELOPE',
      'BODY.PEEK[HEADER]',
      'RFC822.HEADER',
    ]) {
      try {
        result = await sync.client.uidFetchMessages(sequence, criteria);
        break;
      } catch (e) {
        lastError = e;
        // ignore: avoid_print
        print('SentReconcile FETCH $criteria failed: $e');
      }
    }
    if (result == null) throw lastError!;
    for (final mime in result.messages) {
      await claimOrInsert(folder, mime);
    }
  }

  Future<void> claimOrInsert(Folder folder, MimeMessage mime) async {
    final clientId = mime.getHeaderValue('x-client-message-id');
    final messageId =
        mime.getHeaderValue('message-id') ?? mime.envelope?.messageId;
    final uid = mime.uid?.toString();

    if (clientId != null && clientId.isNotEmpty) {
      final local =
          await db.messageDao.findByClientMessageId(sync.account.id, clientId);
      if (local != null) {
        await _claim(local.id, folder, mime, uid);
        return;
      }
    }
    if (messageId != null && messageId.isNotEmpty) {
      final local =
          await db.messageDao.findByRfcMessageId(sync.account.id, messageId);
      if (local != null) {
        await _claim(local.id, folder, mime, uid);
        return;
      }
    }

    // Weak fingerprint
    final subject = mime.decodeSubject() ?? '';
    final date = mime.decodeDate() ?? DateTime.now();
    final to = (mime.to ?? []).map((a) => a.email).join(', ');
    final weak = await db.messageDao.findWeakSentCandidates(
      accountId: sync.account.id,
      subject: subject,
      around: date,
      toAddr: to,
    );
    final unclaimed = weak.where((m) => m.uid == null).toList();
    if (unclaimed.length == 1) {
      // ignore: avoid_print
      print('SentReconcile weak claim for ${unclaimed.first.id}');
      await _claim(unclaimed.first.id, folder, mime, uid);
      return;
    }

    await sync.upsertFromMime(folder, mime);
  }

  Future<void> _claim(
    int localId,
    Folder folder,
    MimeMessage mime,
    String? uid,
  ) async {
    await db.messageDao.updateMessage(
      localId,
      MessagesCompanion(
        folderId: Value(folder.id),
        uid: Value(uid),
        messageId: Value(mime.getHeaderValue('message-id')),
        state: const Value('sent'),
        isRead: Value(mime.isSeen),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
