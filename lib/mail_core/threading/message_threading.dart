import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'message_id_util.dart';

/// Assigns [Messages.threadId] from Message-ID / In-Reply-To / References.
///
/// Incremental JWZ-style: link to any existing message that shares those IDs
/// (or already uses one as [threadId]); merge when a message bridges threads.
class MessageThreading {
  MessageThreading(this.db);

  final AppDatabase db;

  Future<String> assignForMessage(int localId) async {
    final message = await db.messageDao.findById(localId);
    if (message == null) {
      throw StateError('Message $localId not found');
    }

    final linkIds = MessageIdUtil.linkIds(
      messageId: message.messageId,
      inReplyTo: message.inReplyTo,
      referencesHeader: message.referencesHeader,
    );

    final related = linkIds.isEmpty
        ? <Message>[]
        : await db.messageDao.findThreadingCandidates(
            message.accountId,
            linkIds,
          );

    final existingThreads = <String>{};
    for (final m in related) {
      final t = m.threadId;
      if (t != null && t.isNotEmpty) existingThreads.add(t);
    }

    final refs = MessageIdUtil.parseHeaderIds(message.referencesHeader);
    final own = MessageIdUtil.normalize(message.messageId);
    final fallback = own ?? 'local-$localId';

    late final String canonical;
    if (existingThreads.isEmpty) {
      // Oldest reference is the conventional thread root when present.
      canonical = refs.isNotEmpty ? refs.first : fallback;
    } else {
      canonical = _pickCanonical(
        existingThreads,
        preferredRoots: {
          if (refs.isNotEmpty) refs.first,
          if (own != null) own,
          ...existingThreads,
        },
      );
      for (final t in existingThreads) {
        if (t != canonical) {
          await db.messageDao.reassignThreadId(
            message.accountId,
            from: t,
            to: canonical,
          );
        }
      }
    }

    if (message.threadId != canonical) {
      await db.messageDao.updateMessage(
        localId,
        MessagesCompanion(
          threadId: Value(canonical),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    return canonical;
  }

  /// Fill null [threadId] rows (migration / older DB). Oldest-first helps roots.
  Future<int> backfillMissing() async {
    final missing = await db.messageDao.findWithoutThreadId();
    if (missing.isEmpty) return 0;
    missing.sort((a, b) => a.date.compareTo(b.date));
    for (final m in missing) {
      await assignForMessage(m.id);
    }
    return missing.length;
  }

  static String _pickCanonical(
    Set<String> threads, {
    required Set<String> preferredRoots,
  }) {
    for (final root in preferredRoots) {
      if (threads.contains(root)) return root;
    }
    final sorted = threads.toList()..sort();
    return sorted.first;
  }
}
