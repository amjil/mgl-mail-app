import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [Outbox, Messages])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Future<List<OutboxData>> pendingDue({String? accountId}) {
    final now = DateTime.now();
    final q = select(outbox)
      ..where((o) =>
          (o.status.equals('pending') | o.status.equals('failed')) &
          (o.nextRetryAt.isNull() | o.nextRetryAt.isSmallerOrEqualValue(now)))
      ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]);
    if (accountId != null) {
      q.where((o) => o.accountId.equals(accountId));
    }
    return q.get();
  }

  Future<OutboxData?> findById(int id) =>
      (select(outbox)..where((o) => o.id.equals(id))).getSingleOrNull();

  Future<int> insert(OutboxCompanion row) => into(outbox).insert(row);

  Future<void> markSending(int id) => (update(outbox)
        ..where((o) => o.id.equals(id)))
      .write(const OutboxCompanion(status: Value('sending')));

  Future<void> markSent(int id) =>
      (update(outbox)..where((o) => o.id.equals(id)))
          .write(const OutboxCompanion(status: Value('sent')));

  Future<void> markFailed({
    required int id,
    required int retryCount,
    required DateTime nextRetryAt,
    required String error,
  }) {
    return (update(outbox)..where((o) => o.id.equals(id))).write(
      OutboxCompanion(
        status: const Value('failed'),
        retryCount: Value(retryCount),
        nextRetryAt: Value(nextRetryAt),
        lastError: Value(error),
      ),
    );
  }

  Future<void> resetToPending(int id) {
    return (update(outbox)..where((o) => o.id.equals(id))).write(
      const OutboxCompanion(
        status: Value('pending'),
        nextRetryAt: Value(null),
      ),
    );
  }

  Future<void> deleteByMessageId(int messageId) =>
      (delete(outbox)..where((o) => o.messageId.equals(messageId))).go();

  Stream<List<OutboxData>> watchAll({String? accountId}) {
    final q = select(outbox)
      ..where((o) => o.status.isNotValue('sent'))
      ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]);
    if (accountId != null) {
      q.where((o) => o.accountId.equals(accountId));
    }
    return q.watch();
  }
}
