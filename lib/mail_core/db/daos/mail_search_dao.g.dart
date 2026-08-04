// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_search_dao.dart';

// ignore_for_file: type=lint
mixin _$MailSearchDaoMixin on DatabaseAccessor<AppDatabase> {
  $MessagesTable get messages => attachedDatabase.messages;
  MailSearchDaoManager get managers => MailSearchDaoManager(this);
}

class MailSearchDaoManager {
  final _$MailSearchDaoMixin _db;
  MailSearchDaoManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db.attachedDatabase, _db.messages);
}
