import 'package:drift/drift.dart';

/// Account row — secrets live in secure storage, not here.
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get imapHost => text()();
  IntColumn get imapPort => integer().withDefault(const Constant(993))();
  BoolColumn get imapSsl => boolean().withDefault(const Constant(true))();
  TextColumn get smtpHost => text()();
  IntColumn get smtpPort => integer().withDefault(const Constant(465))();
  BoolColumn get smtpSsl => boolean().withDefault(const Constant(true))();
  TextColumn get username => text()();

  /// `password` | `oauth2`
  TextColumn get authType =>
      text().withDefault(const Constant('password'))();

  /// e.g. `outlook`, `generic`
  TextColumn get provider => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountId => text()();
  TextColumn get name => text()();
  TextColumn get path => text()();

  /// inbox / sent / trash / draft / custom
  TextColumn get role => text()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  BoolColumn get selectable => boolean().withDefault(const Constant(true))();

  @override
  List<String> get customConstraints => [
        'UNIQUE(account_id, path)',
      ];
}

class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountId => text()();
  IntColumn get folderId => integer().nullable()();
  TextColumn get uid => text().nullable()();
  TextColumn get messageId => text().nullable()();
  TextColumn get clientMessageId => text().nullable()();
  TextColumn get fromAddr => text().withDefault(const Constant(''))();
  TextColumn get fromName => text().nullable()();
  TextColumn get toAddr => text().withDefault(const Constant(''))();
  TextColumn get ccAddr => text().nullable()();
  TextColumn get bccAddr => text().nullable()();
  TextColumn get subject => text().nullable()();

  /// RFC Message-ID of the message being replied to (In-Reply-To).
  TextColumn get inReplyTo => text().nullable()();

  /// Space-separated References chain for threading.
  TextColumn get referencesHeader => text().nullable()();

  DateTimeColumn get date => dateTime()();

  /// inbox | sent | draft | outbox | failed
  TextColumn get state => text().withDefault(const Constant('inbox'))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  BoolColumn get hasAttachment =>
      boolean().withDefault(const Constant(false))();
  IntColumn get size => integer().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class MessageBodies extends Table {
  IntColumn get messageId => integer()();
  TextColumn get plainText => text().nullable()();
  TextColumn get htmlText => text().nullable()();
  BoolColumn get isDownloaded =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get downloadedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {messageId};
}

class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get messageId => integer()();
  TextColumn get filename => text()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get size => integer().nullable()();
  TextColumn get partId => text().nullable()();
  TextColumn get contentId => text().nullable()();
  TextColumn get localPath => text().nullable()();
  BoolColumn get isDownloaded =>
      boolean().withDefault(const Constant(false))();
}

class Outbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountId => text()();
  IntColumn get messageId => integer()();
  TextColumn get clientMessageId => text()();

  /// pending | sending | sent | failed
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class SyncStates extends Table {
  TextColumn get accountId => text()();
  IntColumn get folderId => integer()();
  IntColumn get lastUid => integer().withDefault(const Constant(0))();
  IntColumn get uidValidity => integer().nullable()();
  DateTimeColumn get lastSyncAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {accountId, folderId};
}
