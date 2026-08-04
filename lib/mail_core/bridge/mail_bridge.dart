import '../bridge/dto/mail_dtos.dart';
import '../engine/mail_engine.dart';
import '../secure/account_credential_store.dart';

/// UI-facing API. Prefer this over talking to Drift / IMAP directly.
class MailBridge {
  MailBridge(this._engine);

  final MailEngine _engine;

  /// [credentialMode] selects secret storage:
  /// - [CredentialStoreMode.development]: local JSON file (default in debug)
  /// - [CredentialStoreMode.production]: Keychain / Keystore (default in release)
  factory MailBridge.create({
    MailEngine? engine,
    CredentialStoreMode? credentialMode,
  }) {
    return MailBridge(
      engine ?? MailEngine(credentialMode: credentialMode),
    );
  }

  Future<void> initialize() => _engine.initialize();

  Future<void> dispose() => _engine.dispose();

  Future<MailAccountDto> addAccount({
    required String email,
    required String password,
    required String imapHost,
    required String smtpHost,
    String? displayName,
    String? username,
    int imapPort = 993,
    bool imapSsl = true,
    int smtpPort = 465,
    bool smtpSsl = true,
    bool startWorkers = true,
  }) {
    return _engine.addAccount(
      email: email,
      password: password,
      imapHost: imapHost,
      smtpHost: smtpHost,
      displayName: displayName,
      username: username,
      imapPort: imapPort,
      imapSsl: imapSsl,
      smtpPort: smtpPort,
      smtpSsl: smtpSsl,
      startWorkers: startWorkers,
    );
  }

  /// Sign in with Microsoft and register Outlook IMAP/SMTP (XOAUTH2).
  Future<MailAccountDto> addOutlookAccount({bool startWorkers = true}) {
    return _engine.addOutlookAccount(startWorkers: startWorkers);
  }

  Future<void> removeAccount(String accountId) =>
      _engine.removeAccount(accountId);

  Future<List<MailAccountDto>> listAccounts() => _engine.listAccounts();

  void setCurrentAccount(String? accountId) =>
      _engine.setCurrentAccount(accountId);

  Future<void> syncAll() => _engine.syncAll();

  Future<void> syncAccount(String accountId) =>
      _engine.syncAccount(accountId);

  Future<List<MailFolderDto>> listFolders({String? accountId}) =>
      _engine.listFolders(accountId: accountId);

  Stream<List<MailFolderDto>> watchFolders({String? accountId}) =>
      _engine.watchFolders(accountId: accountId);

  Stream<List<MailMessageDto>> watchFolder(int folderId) =>
      _engine.watchFolder(folderId);

  Future<void> syncFolder(int folderId) => _engine.syncFolder(folderId);

  Future<void> syncRole(String role, {String? accountId}) =>
      _engine.syncRole(role, accountId: accountId);

  Stream<List<MailMessageDto>> watchInbox({String? accountId}) =>
      _engine.watchInbox(accountId: accountId);

  Stream<List<MailMessageDto>> watchSent({String? accountId}) =>
      _engine.watchSent(accountId: accountId);

  Stream<List<MailMessageDto>> watchDrafts({String? accountId}) =>
      _engine.watchDrafts(accountId: accountId);

  Stream<List<MailMessageDto>> watchArchive({String? accountId}) =>
      _engine.watchArchive(accountId: accountId);

  Stream<List<MailMessageDto>> watchTrash({String? accountId}) =>
      _engine.watchTrash(accountId: accountId);

  Stream<List<MailOutboxDto>> watchOutbox({String? accountId}) =>
      _engine.watchOutbox(accountId: accountId);

  Future<MailMessageWithBody> openMessage(int messageId) =>
      _engine.openMessage(messageId);

  Future<void> ensureBodyDownloaded(int messageId) =>
      _engine.ensureBodyDownloaded(messageId);

  Future<MailAttachmentDto?> downloadAttachment(int attachmentId) =>
      _engine.downloadAttachment(attachmentId);

  Future<List<MailSearchResultDto>> search(
    String query, {
    String? accountId,
  }) =>
      _engine.search(query, accountId: accountId);

  Future<int> sendMail({
    required String accountId,
    required List<String> to,
    List<String>? cc,
    required String subject,
    String? plainText,
    String? htmlText,
    List<String>? attachmentPaths,
  }) {
    return _engine.sendMail(
      accountId: accountId,
      to: to,
      cc: cc,
      subject: subject,
      plainText: plainText,
      htmlText: htmlText,
      attachmentPaths: attachmentPaths,
    );
  }

  Future<int> saveDraft({
    required String accountId,
    List<String>? to,
    List<String>? cc,
    required String subject,
    String? plainText,
    String? htmlText,
    List<String>? attachmentPaths,
  }) {
    return _engine.saveDraft(
      accountId: accountId,
      to: to,
      cc: cc,
      subject: subject,
      plainText: plainText,
      htmlText: htmlText,
      attachmentPaths: attachmentPaths,
    );
  }

  Future<void> retryOutbox(int outboxId) => _engine.retryOutbox(outboxId);

  Future<void> deleteMessage(int messageId) =>
      _engine.deleteMessage(messageId);

  Future<void> moveToArchive(int messageId) =>
      _engine.moveToArchive(messageId);

  Future<void> moveToInbox(int messageId) =>
      _engine.moveToInbox(messageId);

  Future<void> onAppBackground(bool background) =>
      _engine.onAppBackground(background);
}
