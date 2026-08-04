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

  Future<void> remove(int messageId) =>
      _db.mailSearchDao.deleteFts(messageId);
}
