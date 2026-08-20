import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/account_dao.dart';
import 'daos/attachment_dao.dart';
import 'daos/folder_dao.dart';
import 'daos/mail_search_dao.dart';
import 'daos/message_body_dao.dart';
import 'daos/message_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/sync_state_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Folders,
    Messages,
    MessageBodies,
    Attachments,
    Outbox,
    SyncStates,
  ],
  daos: [
    AccountDao,
    FolderDao,
    MessageDao,
    MessageBodyDao,
    AttachmentDao,
    OutboxDao,
    SyncStateDao,
    MailSearchDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_messages_uid '
            'ON messages(account_id, folder_id, uid) '
            'WHERE uid IS NOT NULL',
          );
          await customStatement(kFtsMessagesCreateSql);
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(accounts, accounts.authType);
            await m.addColumn(accounts, accounts.provider);
          }
          if (from < 3) {
            await m.addColumn(messages, messages.bccAddr);
            await m.addColumn(messages, messages.inReplyTo);
            await m.addColumn(messages, messages.referencesHeader);
          }
          if (from < 4) {
            await customStatement(kFtsMessagesCreateSql);
          }
        },
        beforeOpen: (details) async {
          await mailSearchDao.ensureReady();
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'mail_core',
      native: DriftNativeOptions(
        databasePath: () async {
          final docs = await getApplicationDocumentsDirectory();
          final path = p.join(docs.path, 'mail_core.sqlite');
          print('SQLite database: $path');
          return path;
        },
      ),
    );
  }

  /// Delete local mail rows for [accountId] and notify Drift watchers.
  /// `customStatement` would skip table updates, leaving All-accounts streams stale.
  Future<void> purgeAccountData(String accountId) async {
    await _purgeMailWhereAccount(
      'account_id = ?',
      [Variable.withString(accountId)],
    );
  }

  /// Drop folders/messages whose account row is already gone.
  Future<void> purgeOrphanedMail() async {
    await _purgeMailWhereAccount(
      'account_id NOT IN (SELECT id FROM accounts)',
      const [],
    );
  }

  Future<void> _purgeMailWhereAccount(
    String accountPred,
    List<Variable> vars,
  ) async {
    await transaction(() async {
      await customUpdate(
        'DELETE FROM attachments WHERE message_id IN '
        '(SELECT id FROM messages WHERE $accountPred)',
        variables: vars,
        updates: {attachments},
        updateKind: UpdateKind.delete,
      );
      await customUpdate(
        'DELETE FROM message_bodies WHERE message_id IN '
        '(SELECT id FROM messages WHERE $accountPred)',
        variables: vars,
        updates: {messageBodies},
        updateKind: UpdateKind.delete,
      );
      await customUpdate(
        'DELETE FROM outbox WHERE $accountPred',
        variables: vars,
        updates: {outbox},
        updateKind: UpdateKind.delete,
      );
      await customUpdate(
        'DELETE FROM sync_states WHERE $accountPred',
        variables: vars,
        updates: {syncStates},
        updateKind: UpdateKind.delete,
      );
      await customUpdate(
        'DELETE FROM messages WHERE $accountPred',
        variables: vars,
        updates: {messages},
        updateKind: UpdateKind.delete,
      );
      await customUpdate(
        'DELETE FROM folders WHERE $accountPred',
        variables: vars,
        updates: {folders},
        updateKind: UpdateKind.delete,
      );
    });
  }

  /// Attachment storage root under app documents.
  static Future<Directory> attachmentDir({
    required String accountId,
    required int messageId,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(
      p.join(docs.path, 'mail_core', 'attachments', accountId, '$messageId'),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
