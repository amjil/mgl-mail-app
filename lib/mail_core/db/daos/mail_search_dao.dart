import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'mail_search_dao.g.dart';

class MailSearchHit {
  MailSearchHit({
    required this.messageId,
    required this.accountId,
    required this.snippet,
    required this.subject,
  });

  final int messageId;
  final String accountId;
  final String snippet;
  final String subject;
}

@DriftAccessor(tables: [Messages])
class MailSearchDao extends DatabaseAccessor<AppDatabase>
    with _$MailSearchDaoMixin {
  MailSearchDao(super.db);

  Future<void> upsertFts({
    required int messageId,
    required String accountId,
    String? subject,
    String? body,
    String? fromAddr,
    String? toAddr,
  }) async {
    await customStatement(
      'DELETE FROM fts_messages WHERE rowid = ?',
      [messageId],
    );
    await customStatement(
      'INSERT INTO fts_messages(rowid, subject, body, from_addr, to_addr, account_id) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      [messageId, subject, body, fromAddr, toAddr, accountId],
    );
  }

  Future<void> deleteFts(int messageId) async {
    await customStatement(
      'DELETE FROM fts_messages WHERE rowid = ?',
      [messageId],
    );
  }

  Future<List<MailSearchHit>> search(
    String query, {
    String? accountId,
    int limit = 50,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final safe = trimmed.replaceAll('"', '""');
    final match = '"$safe*"';

    final rows = await customSelect(
      '''
      SELECT m.id AS message_id,
             m.account_id AS account_id,
             COALESCE(m.subject, '') AS subject,
             snippet(fts_messages, 1, '[', ']', '…', 12) AS snip
      FROM fts_messages
      JOIN messages m ON m.id = fts_messages.rowid
      WHERE fts_messages MATCH ?
        AND m.deleted = 0
        ${accountId != null ? 'AND m.account_id = ?' : ''}
      ORDER BY rank
      LIMIT ?
      ''',
      variables: [
        Variable.withString(match),
        if (accountId != null) Variable.withString(accountId),
        Variable.withInt(limit),
      ],
      readsFrom: {messages},
    ).get();

    return rows
        .map(
          (r) => MailSearchHit(
            messageId: r.read<int>('message_id'),
            accountId: r.read<String>('account_id'),
            subject: r.read<String>('subject'),
            snippet: r.read<String>('snip'),
          ),
        )
        .toList();
  }
}
