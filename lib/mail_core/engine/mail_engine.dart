import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../bridge/dto/mail_dtos.dart';
import '../bridge/mapper/mail_mapper.dart';
import '../db/app_database.dart';
import '../oauth/oauth_config.dart';
import '../oauth/oauth_token_store.dart';
import '../oauth/outlook_oauth.dart';
import '../search/fts_indexer.dart';
import '../search/mail_search_service.dart';
import '../secure/account_credential_store.dart';
import 'account_context.dart';
import 'account_engine.dart';

class MailEngine {
  MailEngine({
    AppDatabase? database,
    AccountCredentialStore? credentials,
    CredentialStoreMode? credentialMode,
    OutlookOAuth? outlookOAuth,
  })  : db = database ?? AppDatabase(),
        credentials = credentials ??
            AccountCredentialStore(mode: credentialMode),
        outlookOAuth = outlookOAuth ?? OutlookOAuth(),
        context = AccountContext() {
    searchService = MailSearchService(db);
    indexer = FtsIndexer(db);
  }

  final AppDatabase db;
  final AccountCredentialStore credentials;
  final OutlookOAuth outlookOAuth;
  final AccountContext context;
  late final MailSearchService searchService;
  late final FtsIndexer indexer;

  final Map<String, AccountEngine> _accounts = {};
  final _uuid = const Uuid();

  Future<void> initialize() async {
    final rows = await db.accountDao.listAccounts();
    for (final row in rows) {
      await _register(row, start: true);
    }
  }

  Future<void> dispose() async {
    for (final engine in _accounts.values) {
      await engine.stop();
    }
    _accounts.clear();
    await db.close();
  }

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
  }) async {
    final id = _uuid.v4();
    final companion = AccountsCompanion.insert(
      id: id,
      email: email,
      displayName: Value(displayName),
      imapHost: imapHost,
      imapPort: Value(imapPort),
      imapSsl: Value(imapSsl),
      smtpHost: smtpHost,
      smtpPort: Value(smtpPort),
      smtpSsl: Value(smtpSsl),
      username: username ?? email,
      authType: const Value('password'),
      provider: const Value('generic'),
    );
    await db.accountDao.upsert(companion);
    await credentials.savePassword(id, password);
    final account = (await db.accountDao.findById(id))!;
    await _register(account, start: startWorkers);
    return MailMapper.toAccountDto(account);
  }

  /// Browser OAuth → Outlook IMAP/SMTP via XOAUTH2.
  Future<MailAccountDto> addOutlookAccount({bool startWorkers = true}) async {
    final result = await outlookOAuth.signIn();
    return addOAuthAccount(
      email: result.email,
      token: result.token,
      provider: 'outlook',
      imapHost: OAuthConfig.outlookImapHost,
      imapPort: OAuthConfig.outlookImapPort,
      imapSsl: true,
      smtpHost: OAuthConfig.outlookSmtpHost,
      smtpPort: OAuthConfig.outlookSmtpPort,
      smtpSsl: false, // STARTTLS on 587
      startWorkers: startWorkers,
    );
  }

  Future<MailAccountDto> addOAuthAccount({
    required String email,
    required OAuthTokenData token,
    required String provider,
    required String imapHost,
    required String smtpHost,
    String? displayName,
    String? username,
    int imapPort = 993,
    bool imapSsl = true,
    int smtpPort = 587,
    bool smtpSsl = false,
    bool startWorkers = true,
  }) async {
    final id = _uuid.v4();
    final companion = AccountsCompanion.insert(
      id: id,
      email: email,
      displayName: Value(displayName ?? email),
      imapHost: imapHost,
      imapPort: Value(imapPort),
      imapSsl: Value(imapSsl),
      smtpHost: smtpHost,
      smtpPort: Value(smtpPort),
      smtpSsl: Value(smtpSsl),
      username: username ?? email,
      authType: const Value('oauth2'),
      provider: Value(provider),
    );
    await db.accountDao.upsert(companion);
    await credentials.saveOAuth(id, token);
    final account = (await db.accountDao.findById(id))!;
    await _register(account, start: startWorkers);
    return MailMapper.toAccountDto(account);
  }

  Future<void> removeAccount(String accountId) async {
    final engine = _accounts.remove(accountId);
    await engine?.stop();
    // best-effort keychain cleanup (may fail without Keychain entitlement)
    try {
      await credentials.delete(accountId);
    } catch (e) {
      // ignore: avoid_print
      print('credentials.delete failed for $accountId: $e');
    }
    // best-effort attachment cleanup
    try {
      final docs = await AppDatabase.attachmentDir(
        accountId: accountId,
        messageId: 0,
      );
      final root = docs.parent.parent;
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    } catch (_) {}
    await db.accountDao.deleteById(accountId);
  }

  Future<List<MailAccountDto>> listAccounts() async {
    final rows = await db.accountDao.listAccounts();
    return rows.map(MailMapper.toAccountDto).toList();
  }

  void setCurrentAccount(String? accountId) => context.setAccount(accountId);

  Future<void> syncAll() async {
    for (final engine in _accounts.values) {
      await engine.syncNow();
    }
  }

  Future<void> syncAccount(String accountId) async {
    await _accounts[accountId]?.syncNow();
  }

  Future<void> onAppBackground(bool background) async {
    for (final engine in _accounts.values) {
      await engine.setBackground(background);
    }
  }

  Stream<List<MailMessageDto>> watchInbox({String? accountId}) async* {
    final filter = accountId ?? context.currentAccountId;
    // Re-subscribe when folders change by polling folder ids periodically
    // via a simple approach: watch all messages for inbox folders.
    yield* Stream.multi((controller) async {
      Future<List<int>> inboxIds() async {
        final folders = await db.folderDao.listByRole('inbox', accountId: filter);
        return folders.map((f) => f.id).toList();
      }

      var ids = await inboxIds();
      StreamSubscription<List<Message>>? sub;

      Future<void> resubscribe() async {
        await sub?.cancel();
        ids = await inboxIds();
        sub = db.messageDao.watchByFolderIds(ids).listen((rows) async {
          final dtos = <MailMessageDto>[];
          for (final m in rows) {
            if (filter != null && m.accountId != filter) continue;
            final body = await db.messageBodyDao.find(m.id);
            dtos.add(MailMapper.toMessageDto(
              m,
              hasBody: body?.isDownloaded == true,
              folderRole: 'inbox',
            ));
          }
          controller.add(dtos);
        });
      }

      await resubscribe();
      final refresh = Stream.periodic(const Duration(seconds: 15)).listen((_) {
        resubscribe();
      });

      controller.onCancel = () async {
        await refresh.cancel();
        await sub?.cancel();
      };
    });
  }

  Stream<List<MailMessageDto>> watchSent({String? accountId}) {
    final filter = accountId ?? context.currentAccountId;
    return db.messageDao.watchByState('sent', accountId: filter).asyncMap(
      (rows) async {
        final dtos = <MailMessageDto>[];
        for (final m in rows) {
          final body = await db.messageBodyDao.find(m.id);
          dtos.add(MailMapper.toMessageDto(
            m,
            hasBody: body?.isDownloaded == true,
            folderRole: 'sent',
          ));
        }
        return dtos;
      },
    );
  }

  Stream<List<MailOutboxDto>> watchOutbox({String? accountId}) {
    final filter = accountId ?? context.currentAccountId;
    return db.outboxDao.watchAll(accountId: filter).asyncMap((rows) async {
      final out = <MailOutboxDto>[];
      for (final o in rows) {
        final m = await db.messageDao.findById(o.messageId);
        out.add(MailMapper.toOutboxDto(o, subject: m?.subject));
      }
      return out;
    });
  }

  /// Returns headers/metadata immediately from DB.
  /// Body download is separate via [ensureBodyDownloaded] so the UI is not
  /// blocked on IMAP (IDLE stop + BODY[] can hang on some servers).
  Future<MailMessageWithBody> openMessage(int messageId) async {
    final message = await db.messageDao.findById(messageId);
    if (message == null) {
      throw StateError('Message $messageId not found');
    }
    if (!message.isRead) {
      await db.messageDao.markRead(messageId);
    }
    final body = await db.messageBodyDao.find(messageId);
    final atts = await db.attachmentDao.listForMessage(messageId);
    return MailMessageWithBody(
      message: MailMapper.toMessageDto(
        message,
        hasBody: body?.isDownloaded == true,
      ),
      body: MailMapper.toBodyDto(body),
      attachments: atts.map(MailMapper.toAttachmentDto).toList(),
    );
  }

  Future<void> ensureBodyDownloaded(int messageId) async {
    final message = await db.messageDao.findById(messageId);
    if (message == null) return;
    final body = await db.messageBodyDao.find(messageId);
    if (body?.isDownloaded == true) return;
    await _accounts[message.accountId]
        ?.downloadBodyIfNeeded(messageId)
        .timeout(const Duration(seconds: 45));
  }

  Future<List<MailAttachmentDto>> listAttachments(int messageId) async {
    final rows = await db.attachmentDao.listForMessage(messageId);
    return rows.map(MailMapper.toAttachmentDto).toList();
  }

  Future<MailAttachmentDto?> downloadAttachment(int attachmentId) async {
    final att = await db.attachmentDao.findById(attachmentId);
    if (att == null) return null;
    final message = await db.messageDao.findById(att.messageId);
    if (message == null) return null;
    final updated =
        await _accounts[message.accountId]?.downloadAttachment(attachmentId);
    return updated == null ? null : MailMapper.toAttachmentDto(updated);
  }

  Future<List<MailSearchResultDto>> search(
    String query, {
    String? accountId,
  }) {
    return searchService.search(
      query,
      accountId: accountId ?? context.currentAccountId,
    );
  }

  Future<int> sendMail({
    required String accountId,
    required List<String> to,
    List<String>? cc,
    required String subject,
    String? plainText,
    String? htmlText,
    List<String>? attachmentPaths,
  }) async {
    if (!_accounts.containsKey(accountId)) {
      throw StateError('Account $accountId is not registered');
    }
    final clientMessageId = _uuid.v4();
    final rfcId = '<$clientMessageId@local>';
    final messageId = await db.messageDao.insertMessage(
      MessagesCompanion.insert(
        accountId: accountId,
        clientMessageId: Value(clientMessageId),
        messageId: Value(rfcId),
        fromAddr: Value((await db.accountDao.findById(accountId))!.email),
        toAddr: Value(to.join(', ')),
        ccAddr: Value(cc?.join(', ')),
        subject: Value(subject),
        date: DateTime.now(),
        state: const Value('outbox'),
        isRead: const Value(true),
        hasAttachment: Value(attachmentPaths?.isNotEmpty == true),
      ),
    );
    await db.messageBodyDao.upsert(
      MessageBodiesCompanion.insert(
        messageId: Value(messageId),
        plainText: Value(plainText),
        htmlText: Value(htmlText),
        isDownloaded: const Value(true),
        downloadedAt: Value(DateTime.now()),
      ),
    );
    if (attachmentPaths != null) {
      for (final path in attachmentPaths) {
        final file = File(path);
        await db.attachmentDao.insert(
          AttachmentsCompanion.insert(
            messageId: messageId,
            filename: file.uri.pathSegments.last,
            localPath: Value(path),
            isDownloaded: const Value(true),
            size: Value(await file.exists() ? await file.length() : null),
          ),
        );
      }
    }
    await indexer.indexMessage(
      messageId: messageId,
      accountId: accountId,
      subject: subject,
      body: plainText ?? htmlText,
      toAddr: to.join(', '),
    );
    await db.outboxDao.insert(
      OutboxCompanion.insert(
        accountId: accountId,
        messageId: messageId,
        clientMessageId: clientMessageId,
        status: const Value('pending'),
      ),
    );
    await _accounts[accountId]?.outboxWorker?.kick();
    return messageId;
  }

  Future<void> retryOutbox(int outboxId) async {
    final row = await db.outboxDao.findById(outboxId);
    if (row == null) return;
    await db.outboxDao.resetToPending(outboxId);
    await db.messageDao.updateMessage(
      row.messageId,
      MessagesCompanion(
        state: const Value('outbox'),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _accounts[row.accountId]?.outboxWorker?.kick();
  }

  Future<void> _register(Account account, {required bool start}) async {
    if (_accounts.containsKey(account.id)) return;
    final engine = AccountEngine(
      db: db,
      account: account,
      credentials: credentials,
      oauth: outlookOAuth,
    );
    _accounts[account.id] = engine;
    if (start) {
      try {
        await engine.start();
      } catch (_) {
        // Account stays registered; workers can be retried after credential fix.
      }
    }
  }
}
