import '../db/app_database.dart';

class FtsIndexer {
  FtsIndexer(this._db);

  final AppDatabase _db;

  Future<void> indexMessage({
    required int messageId,
    required String accountId,
    String? subject,
    String? body,
    String? fromAddr,
    String? toAddr,
  }) {
    return _db.mailSearchDao.upsertFts(
      messageId: messageId,
      accountId: accountId,
      subject: subject,
      body: body,
      fromAddr: fromAddr,
      toAddr: toAddr,
    );
  }

  Future<void> indexFromRows({
    required Message message,
    MessageBody? body,
  }) {
    return indexMessage(
      messageId: message.id,
      accountId: message.accountId,
      subject: message.subject,
      body: body?.plainText ?? body?.htmlText,
      fromAddr: message.fromAddr,
      toAddr: message.toAddr,
    );
  }

  Future<void> remove(int messageId) =>
      _db.mailSearchDao.deleteFts(messageId);
}
