import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'message_body_dao.g.dart';

@DriftAccessor(tables: [MessageBodies])
class MessageBodyDao extends DatabaseAccessor<AppDatabase>
    with _$MessageBodyDaoMixin {
  MessageBodyDao(super.db);

  Future<MessageBody?> find(int messageId) =>
      (select(messageBodies)..where((b) => b.messageId.equals(messageId)))
          .getSingleOrNull();

  Future<void> upsert(MessageBodiesCompanion row) =>
      into(messageBodies).insertOnConflictUpdate(row);
}
