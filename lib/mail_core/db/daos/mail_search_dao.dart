import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'mail_search_dao.g.dart';

const kFtsMessagesCreateSql = '''
CREATE VIRTUAL TABLE IF NOT EXISTS fts_messages USING fts5(
  subject,
  body,
  from_addr,
  to_addr,
  account_id,
  tokenize = 'unicode61'
);
''';

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

  Future<void> ensureTable() => customStatement(kFtsMessagesCreateSql);

  /// Create FTS if missing, then backfill when [messages] and FTS counts drift.
  Future<void> ensureReady() async {
    await ensureTable();
    final msg = await _count(
      'SELECT COUNT(*) AS c FROM messages WHERE deleted = 0',
    );
    var fts = 0;
    try {
      fts = await _count('SELECT COUNT(*) AS c FROM fts_messages');
    } catch (_) {}
    if (fts != msg) {
      await rebuildAll();
    }
  }

  /// Reindex every non-deleted message (subject + body + addresses).
  Future<void> rebuildAll() async {
    await ensureTable();
    await customStatement('DELETE FROM fts_messages');
    await customStatement('''
INSERT INTO fts_messages(rowid, subject, body, from_addr, to_addr, account_id)
SELECT m.id,
       COALESCE(m.subject, ''),
       COALESCE(b.plain_text, b.html_text, ''),
       COALESCE(m.from_addr, ''),
       COALESCE(m.to_addr, ''),
       m.account_id
FROM messages m
LEFT JOIN message_bodies b ON b.message_id = m.id
WHERE m.deleted = 0
''');
  }

  Future<int> _count(String sql) async {
    final row = await customSelect(sql).getSingle();
    final v = row.data['c'];
    if (v is int) return v;
    if (v is BigInt) return v.toInt();
    return int.parse('$v');
  }

  Future<void> upsertFts({
    required int messageId,
    required String accountId,
    String? subject,
    String? body,
    String? fromAddr,
    String? toAddr,
  }) async {
    await ensureTable();
    await customStatement(
      'DELETE FROM fts_messages WHERE rowid = ?',
      [messageId],
    );
    await customStatement(
      'INSERT INTO fts_messages(rowid, subject, body, from_addr, to_addr, account_id) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      [messageId, subject ?? '', body ?? '', fromAddr ?? '', toAddr ?? '', accountId],
    );
  }

  Future<void> deleteFts(int messageId) async {
    await customStatement(
      'DELETE FROM fts_messages WHERE rowid = ?',
      [messageId],
    );
  }

  Future<void> deleteByAccount(String accountId) async {
    await ensureTable();
    await customStatement(
      'DELETE FROM fts_messages WHERE account_id = ?',
      [accountId],
    );
  }

  Future<List<MailSearchHit>> search(
    String query, {
    String? accountId,
    int limit = 50,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    await ensureTable();

    var rows = <QueryRow>[];
    final match = _ftsMatchQuery(trimmed);
    if (match != null) {
      try {
        rows = await customSelect(
          '''
          SELECT m.id AS message_id,
                 m.account_id AS account_id,
                 COALESCE(m.subject, '') AS subject,
                 COALESCE(
                   NULLIF(snippet(fts_messages, 1, '[', ']', '…', 12), ''),
                   NULLIF(snippet(fts_messages, 0, '[', ']', '…', 12), ''),
                   COALESCE(m.subject, '')
                 ) AS snip
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
      } catch (_) {
        rows = [];
      }
    }

    if (rows.isEmpty) {
      rows = await _likeFallback(trimmed, accountId: accountId, limit: limit);
    }

    return rows
        .map(
          (r) => MailSearchHit(
            messageId: _readInt(r, 'message_id'),
            accountId: r.read<String>('account_id'),
            subject: r.read<String>('subject'),
            snippet: r.readNullable<String>('snip') ?? r.read<String>('subject'),
          ),
        )
        .toList();
  }

  static int _readInt(QueryRow r, String key) {
    final v = r.data[key];
    if (v is int) return v;
    if (v is BigInt) return v.toInt();
    return int.parse('$v');
  }

  Future<List<QueryRow>> _likeFallback(
    String query, {
    String? accountId,
    required int limit,
  }) {
    final pattern = '%${_escapeLike(query)}%';
    return customSelect(
      '''
      SELECT m.id AS message_id,
             m.account_id AS account_id,
             COALESCE(m.subject, '') AS subject,
             COALESCE(m.subject, m.from_addr, '') AS snip
      FROM messages m
      WHERE m.deleted = 0
        AND (
          IFNULL(m.subject, '') LIKE ? ESCAPE '!'
          OR IFNULL(m.from_addr, '') LIKE ? ESCAPE '!'
          OR IFNULL(m.to_addr, '') LIKE ? ESCAPE '!'
          OR IFNULL(m.from_name, '') LIKE ? ESCAPE '!'
        )
        ${accountId != null ? 'AND m.account_id = ?' : ''}
      ORDER BY m.date DESC
      LIMIT ?
      ''',
      variables: [
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        if (accountId != null) Variable.withString(accountId),
        Variable.withInt(limit),
      ],
      readsFrom: {messages},
    ).get();
  }

  /// FTS5 prefix: `"test"*` (asterisk must be outside the quotes).
  static String? _ftsMatchQuery(String query) {
    final terms = <String>[];
    for (final raw in query.trim().split(RegExp(r'\s+'))) {
      final token = raw.replaceAll('"', '').replaceAll(RegExp(r'[*^{}()]'), '');
      if (token.isEmpty) continue;
      terms.add('"$token"*');
    }
    if (terms.isEmpty) return null;
    return terms.join(' AND ');
  }

  static String _escapeLike(String s) => s
      .replaceAll('!', '!!')
      .replaceAll('%', '!%')
      .replaceAll('_', '!_');
}
