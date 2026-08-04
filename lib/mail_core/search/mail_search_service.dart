import '../bridge/dto/mail_dtos.dart';
import '../db/app_database.dart';
import 'fts_indexer.dart';

class MailSearchService {
  MailSearchService(this._db) : indexer = FtsIndexer(_db);

  final AppDatabase _db;
  final FtsIndexer indexer;

  Future<List<MailSearchResultDto>> search(
    String query, {
    String? accountId,
    int limit = 50,
  }) async {
    final hits = await _db.mailSearchDao.search(
      query,
      accountId: accountId,
      limit: limit,
    );
    return hits
        .map(
          (h) => MailSearchResultDto(
            messageId: h.messageId,
            accountId: h.accountId,
            subject: h.subject,
            snippet: h.snippet,
          ),
        )
        .toList();
  }
}
