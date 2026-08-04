// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_body_dao.dart';

// ignore_for_file: type=lint
mixin _$MessageBodyDaoMixin on DatabaseAccessor<AppDatabase> {
  $MessageBodiesTable get messageBodies => attachedDatabase.messageBodies;
  MessageBodyDaoManager get managers => MessageBodyDaoManager(this);
}

class MessageBodyDaoManager {
  final _$MessageBodyDaoMixin _db;
  MessageBodyDaoManager(this._db);
  $$MessageBodiesTableTableManager get messageBodies =>
      $$MessageBodiesTableTableManager(_db.attachedDatabase, _db.messageBodies);
}
