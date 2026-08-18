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
