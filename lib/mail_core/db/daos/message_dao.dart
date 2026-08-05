import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [Messages, Folders])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Future<Message?> findById(int id) =>
      (select(messages)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<Message?> findByUid(String accountId, int folderId, String uid) {
    return (select(messages)
          ..where((m) =>
              m.accountId.equals(accountId) &
              m.folderId.equals(folderId) &
              m.uid.equals(uid)))
        .getSingleOrNull();
  }

  Future<Message?> findByClientMessageId(
      String accountId, String clientMessageId) {
    return (select(messages)
          ..where((m) =>
              m.accountId.equals(accountId) &
              m.clientMessageId.equals(clientMessageId)))
        .getSingleOrNull();
  }

  Future<Message?> findByRfcMessageId(String accountId, String messageId) {
    return (select(messages)
          ..where((m) =>
              m.accountId.equals(accountId) & m.messageId.equals(messageId)))
        .getSingleOrNull();
  }

  Future<Set<String>> findExistingUids(
      int folderId, Iterable<String> uids) async {
    if (uids.isEmpty) return {};
    final rows = await (select(messages)
          ..where(
              (m) => m.folderId.equals(folderId) & m.uid.isIn(uids.toList())))
        .get();
    return rows.map((r) => r.uid).whereType<String>().toSet();
  }

  Future<int> insertMessage(MessagesCompanion row) =>
      into(messages).insert(row);

  Future<void> updateMessage(int id, MessagesCompanion row) =>
      (update(messages)..where((m) => m.id.equals(id))).write(row);

  Future<void> markRead(int id, {bool read = true}) => updateMessage(
        id,
        MessagesCompanion(
          isRead: Value(read),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> markStarred(int id, {bool starred = true}) => updateMessage(
        id,
        MessagesCompanion(
          isStarred: Value(starred),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> markDeleted(int id) => updateMessage(
        id,
        MessagesCompanion(
          deleted: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Stream<List<Message>> watchByFolderIds(List<int> folderIds) {
    if (folderIds.isEmpty) {
      return Stream.value(const []);
    }
    return (select(messages)
          ..where((m) =>
              m.folderId.isIn(folderIds) &
              m.deleted.equals(false) &
              m.state.isNotValue('outbox') &
              m.state.isNotValue('failed'))
          ..orderBy([(m) => OrderingTerm.desc(m.date)]))
        .watch();
  }

  Future<void> deleteByMessageId(int messageId) =>
      (delete(messages)..where((m) => m.id.equals(messageId))).go();

  Future<void> reassignFolder(int fromFolderId, int toFolderId) async {
    if (fromFolderId == toFolderId) return;
    final fromMsgs = await (select(messages)
          ..where((m) => m.folderId.equals(fromFolderId)))
        .get();
    for (final m in fromMsgs) {
      if (m.uid != null) {
        final clash = await findByUid(m.accountId, toFolderId, m.uid!);
        if (clash != null) {
          // Keep the canonical folder's copy; drop the duplicate row.
          await (delete(messages)..where((row) => row.id.equals(m.id))).go();
          continue;
        }
      }
      await updateMessage(
        m.id,
        MessagesCompanion(folderId: Value(toFolderId)),
      );
    }
  }

  Future<int> countInFolder(int folderId) async {
    final rows = await (select(messages)
          ..where(
            (m) => m.folderId.equals(folderId) & m.deleted.equals(false),
          ))
        .get();
    return rows.length;
  }

  Stream<List<Message>> watchByState(String state, {String? accountId}) {
    final q = select(messages)
      ..where((m) => m.state.equals(state) & m.deleted.equals(false))
      ..orderBy([(m) => OrderingTerm.desc(m.date)]);
    if (accountId != null) {
      q.where((m) => m.accountId.equals(accountId));
    }
    return q.watch();
  }

  Future<List<Message>> findWeakSentCandidates({
    required String accountId,
    required String subject,
    required DateTime around,
    required String toAddr,
  }) {
    final from = around.subtract(const Duration(minutes: 15));
    final to = around.add(const Duration(minutes: 15));
    return (select(messages)
          ..where((m) =>
              m.accountId.equals(accountId) &
              m.state.equals('sent') &
              m.deleted.equals(false) &
              m.subject.equals(subject) &
              m.toAddr.equals(toAddr) &
              m.date.isBetweenValues(from, to)))
        .get();
  }
}
