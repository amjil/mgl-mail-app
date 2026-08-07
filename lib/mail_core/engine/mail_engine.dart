import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:uuid/uuid.dart';

import '../bridge/dto/mail_dtos.dart';
import '../bridge/mapper/mail_mapper.dart';
import '../db/app_database.dart';
import '../imap/imap_sync_service.dart';
import '../oauth/oauth_config.dart';
import '../oauth/oauth_token_store.dart';
import '../oauth/outlook_oauth.dart';
import '../search/fts_indexer.dart';
import '../search/mail_search_service.dart';
import '../secure/account_credential_store.dart';
import '../smtp/outgoing_mime.dart';
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

  Future<List<MailFolderDto>> listFolders({String? accountId}) async {
    final filter = accountId ?? context.currentAccountId;
    final rows = await db.folderDao.listSelectable(accountId: filter);
    return _dedupeFolderDtos(rows.map(MailMapper.toFolderDto).toList());
  }

  Stream<List<MailFolderDto>> watchFolders({String? accountId}) {
    // Capture filter once; callers re-subscribe when account changes.
    final filter = accountId ?? context.currentAccountId;
    // Repair stale unreadCount=0 for already-synced local messages.
    unawaited(_refreshUnreadCounts(accountId: filter));
    return db.folderDao.watchSelectable(accountId: filter).asyncMap(
      (rows) async =>
          _dedupeFolderDtos(rows.map(MailMapper.toFolderDto).toList()),
    );
  }

  Future<void> _refreshUnreadCounts({String? accountId}) async {
    final rows = await db.folderDao.listSelectable(accountId: accountId);
    for (final f in rows) {
      final n = await db.messageDao.countUnreadInFolder(f.id);
      if (f.unreadCount != n) {
        await db.folderDao.setUnreadCount(f.id, n);
      }
    }
  }

  Future<void> _refreshFolderUnread(int? folderId) async {
    if (folderId == null) return;
    final n = await db.messageDao.countUnreadInFolder(folderId);
    await db.folderDao.setUnreadCount(folderId, n);
  }

  /// Collapse duplicate special-use / same-name folders per account.
  List<MailFolderDto> _dedupeFolderDtos(List<MailFolderDto> rows) {
    int score(MailFolderDto f) {
      var s = 1000 - f.path.length;
      if (f.path.toUpperCase() == 'INBOX') s += 500;
      // Prefer known roles over custom when names collide after remapping.
      if (f.role != 'custom') s += 100;
      return s;
    }

    final sorted = List<MailFolderDto>.from(rows)
      ..sort((a, b) {
        final c = score(b).compareTo(score(a));
        return c != 0 ? c : a.id.compareTo(b.id);
      });

    final seenRoles = <String>{};
    final seenNames = <String>{};
    final out = <MailFolderDto>[];
    for (final f in sorted) {
      final roleKey = '${f.accountId}|${f.role}';
      if (f.role != 'custom' && !seenRoles.add(roleKey)) continue;
      final nameKey = '${f.accountId}|${f.name.trim().toLowerCase()}';
      if (nameKey.endsWith('|')) {
        out.add(f);
        continue;
      }
      if (!seenNames.add(nameKey)) continue;
      out.add(f);
    }
    out.sort((a, b) {
      const order = {
        'inbox': 0,
        'sent': 1,
        'draft': 2,
        'archive': 3,
        'trash': 4,
        'custom': 5,
      };
      final c = (order[a.role] ?? 50).compareTo(order[b.role] ?? 50);
      if (c != 0) return c;
      return a.path.compareTo(b.path);
    });
    return out;
  }

  Stream<List<MailMessageDto>> watchFolder(int folderId) {
    return db.messageDao.watchByFolderIds([folderId]).asyncMap((rows) async {
      final folder = await db.folderDao.findById(folderId);
      final role = folder?.role;
      final dtos = <MailMessageDto>[];
      for (final m in rows) {
        final body = await db.messageBodyDao.find(m.id);
        dtos.add(MailMapper.toMessageDto(
          m,
          hasBody: body?.isDownloaded == true,
          folderRole: role,
        ));
      }
      return dtos;
    });
  }

  Future<void> syncFolder(int folderId) async {
    final folder = await db.folderDao.findById(folderId);
    if (folder == null) return;
    await _accounts[folder.accountId]?.syncFolder(folderId);
  }

  Future<void> syncRole(String role, {String? accountId}) async {
    final filter = accountId ?? context.currentAccountId;
    if (filter != null) {
      await _accounts[filter]?.syncRole(role);
      return;
    }
    for (final engine in _accounts.values) {
      try {
        await engine.syncRole(role);
      } catch (e) {
        // ignore: avoid_print
        print('syncRole($role) for ${engine.accountId} failed: $e');
      }
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

  Stream<List<MailMessageDto>> watchDrafts({String? accountId}) =>
      _watchByFolderRole('draft', accountId: accountId);

  Stream<List<MailMessageDto>> watchArchive({String? accountId}) =>
      _watchByFolderRole('archive', accountId: accountId);

  Stream<List<MailMessageDto>> watchTrash({String? accountId}) =>
      _watchByFolderRole('trash', accountId: accountId);

  Stream<List<MailMessageDto>> _watchByFolderRole(
    String role, {
    String? accountId,
  }) {
    final filter = accountId ?? context.currentAccountId;
    return Stream.multi((controller) async {
      Future<List<int>> folderIds() async {
        if (filter == null) {
          final folders = await db.folderDao.listByRole(role);
          return folders.map((f) => f.id).toList();
        }
        final all = await db.folderDao.listForAccount(filter);
        return all
            .where(
              (f) =>
                  f.role == role ||
                  ImapSyncService.mapRoleFromName(f.name) == role,
            )
            .map((f) => f.id)
            .toList();
      }

      StreamSubscription<List<Message>>? byStateSub;
      StreamSubscription<List<Message>>? byFolderSub;
      StreamSubscription<List<Folder>>? foldersSub;
      var stateRows = <Message>[];
      var folderRows = <Message>[];

      Future<void> emit() async {
        final byId = <int, Message>{};
        for (final m in stateRows) {
          byId[m.id] = m;
        }
        for (final m in folderRows) {
          byId[m.id] = m;
        }
        final merged = byId.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        final dtos = <MailMessageDto>[];
        for (final m in merged) {
          final body = await db.messageBodyDao.find(m.id);
          dtos.add(MailMapper.toMessageDto(
            m,
            hasBody: body?.isDownloaded == true,
            folderRole: role,
          ));
        }
        controller.add(dtos);
      }

      Future<void> resubscribeFolders() async {
        await byFolderSub?.cancel();
        final ids = await folderIds();
        // ignore: avoid_print
        print('watchRole=$role folderIds=$ids');
        byFolderSub = db.messageDao.watchByFolderIds(ids).listen((rows) async {
          folderRows = rows;
          await emit();
        });
      }

      byStateSub = db.messageDao.watchByState(role, accountId: filter).listen(
        (rows) async {
          stateRows = rows;
          await emit();
        },
      );
      // Re-bind when folder roles/paths change after sync probe.
      if (filter != null) {
        foldersSub = db.folderDao.watchSelectable(accountId: filter).listen(
          (_) {
            resubscribeFolders();
          },
        );
      }
      await resubscribeFolders();
      final refresh =
          Stream.periodic(const Duration(seconds: 5)).listen((_) {
        resubscribeFolders();
      });

      controller.onCancel = () async {
        await refresh.cancel();
        await byStateSub?.cancel();
        await byFolderSub?.cancel();
        await foldersSub?.cancel();
      };
    });
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
      await _refreshFolderUnread(message.folderId);
      final eng = _accounts[message.accountId];
      if (eng != null) {
        unawaited(eng.setMessageFlags(messageId, seen: true).catchError((_) {}));
      }
    }
    final body = await db.messageBodyDao.find(messageId);
    final atts = await db.attachmentDao.listForMessage(messageId);
    String? folderRole;
    if (message.folderId != null) {
      final folder = await db.folderDao.findById(message.folderId!);
      folderRole = folder?.role;
    }
    return MailMessageWithBody(
      message: MailMapper.toMessageDto(
        message.copyWith(isRead: true),
        hasBody: body?.isDownloaded == true,
        folderRole: folderRole,
      ),
      body: MailMapper.toBodyDto(body),
      attachments: atts.map(MailMapper.toAttachmentDto).toList(),
    );
  }

  Future<void> setRead(int messageId, {required bool read}) async {
    final message = await db.messageDao.findById(messageId);
    if (message == null) return;
    await db.messageDao.markRead(messageId, read: read);
    await _refreshFolderUnread(message.folderId);
    try {
      await _accounts[message.accountId]
          ?.setMessageFlags(messageId, seen: read);
    } catch (_) {}
  }

  Future<void> setStarred(int messageId, {required bool starred}) async {
    final message = await db.messageDao.findById(messageId);
    if (message == null) return;
    await db.messageDao.markStarred(messageId, starred: starred);
    try {
      await _accounts[message.accountId]
          ?.setMessageFlags(messageId, flagged: starred);
    } catch (_) {}
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

  Future<List<String>> searchContacts(String query, {String? accountId}) {
    return db.messageDao.searchContacts(
      query,
      accountId: accountId ?? context.currentAccountId,
    );
  }

  Future<int> sendMail({
    required String accountId,
    required List<String> to,
    List<String>? cc,
    List<String>? bcc,
    required String subject,
    String? plainText,
    String? htmlText,
    List<String>? attachmentPaths,
    String? inReplyTo,
    String? references,
    int? draftMessageId,
  }) async {
    if (!_accounts.containsKey(accountId)) {
      throw StateError('Account $accountId is not registered');
    }
    final account = (await db.accountDao.findById(accountId))!;
    final toJoined = to.join(', ');
    final ccJoined = cc?.join(', ');
    final bccJoined = bcc?.join(', ');
    final hasAtt = attachmentPaths?.isNotEmpty == true;

    late final int messageId;
    late final String clientMessageId;
    late final String rfcId;

    if (draftMessageId != null) {
      final existing = await db.messageDao.findById(draftMessageId);
      if (existing == null || existing.accountId != accountId) {
        throw StateError('Draft $draftMessageId not found');
      }
      messageId = draftMessageId;
      clientMessageId = existing.clientMessageId ?? _uuid.v4();
      rfcId = existing.messageId ?? '<$clientMessageId@local>';
      await db.messageDao.updateMessage(
        messageId,
        MessagesCompanion(
          toAddr: Value(toJoined),
          ccAddr: Value(ccJoined),
          bccAddr: Value(bccJoined),
          subject: Value(subject),
          inReplyTo: Value(inReplyTo),
          referencesHeader: Value(references),
          state: const Value('outbox'),
          isRead: const Value(true),
          hasAttachment: Value(hasAtt),
          date: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await db.attachmentDao.deleteForMessage(messageId);
      await db.outboxDao.deleteByMessageId(messageId);
    } else {
      clientMessageId = _uuid.v4();
      rfcId = '<$clientMessageId@local>';
      messageId = await db.messageDao.insertMessage(
        MessagesCompanion.insert(
          accountId: accountId,
          clientMessageId: Value(clientMessageId),
          messageId: Value(rfcId),
          fromAddr: Value(account.email),
          toAddr: Value(toJoined),
          ccAddr: Value(ccJoined),
          bccAddr: Value(bccJoined),
          subject: Value(subject),
          inReplyTo: Value(inReplyTo),
          referencesHeader: Value(references),
          date: DateTime.now(),
          state: const Value('outbox'),
          isRead: const Value(true),
          hasAttachment: Value(hasAtt),
        ),
      );
    }

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
            mimeType: Value(
              MediaType.guessFromFileName(file.uri.pathSegments.last).text,
            ),
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
      toAddr: toJoined,
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

  /// Save a compose draft locally (and APPEND to IMAP Drafts when available).
  /// Recipients may be empty. Pass [draftMessageId] to update an existing draft.
  ///
  /// Local DB write completes before return; IMAP APPEND runs in the background
  /// so callers can reuse [messageId] immediately (avoids duplicate drafts when
  /// auto-save overlaps a slow APPEND).
  Future<int> saveDraft({
    required String accountId,
    List<String>? to,
    List<String>? cc,
    List<String>? bcc,
    required String subject,
    String? plainText,
    String? htmlText,
    List<String>? attachmentPaths,
    String? inReplyTo,
    String? references,
    int? draftMessageId,
  }) async {
    if (!_accounts.containsKey(accountId)) {
      throw StateError('Account $accountId is not registered');
    }
    final account = (await db.accountDao.findById(accountId))!;
    final draftFolder = await db.folderDao.findDraft(accountId);
    final toJoined = (to ?? const []).join(', ');
    final ccJoined = cc?.join(', ');
    final bccJoined = bcc?.join(', ');
    final hasAtt = attachmentPaths?.isNotEmpty == true;

    late final int messageId;
    late final String clientMessageId;
    late final String rfcId;
    String? previousUid;
    int? previousFolderId;

    if (draftMessageId != null) {
      final existing = await db.messageDao.findById(draftMessageId);
      if (existing == null || existing.accountId != accountId) {
        throw StateError('Draft $draftMessageId not found');
      }
      messageId = draftMessageId;
      clientMessageId = existing.clientMessageId ?? _uuid.v4();
      rfcId = existing.messageId ?? '<$clientMessageId@local>';
      previousUid = existing.uid;
      previousFolderId = existing.folderId;
      await db.messageDao.updateMessage(
        messageId,
        MessagesCompanion(
          folderId: Value(draftFolder?.id ?? existing.folderId),
          toAddr: Value(toJoined),
          ccAddr: Value(ccJoined),
          bccAddr: Value(bccJoined),
          subject: Value(subject),
          inReplyTo: Value(inReplyTo),
          referencesHeader: Value(references),
          state: const Value('draft'),
          isRead: const Value(true),
          hasAttachment: Value(hasAtt),
          date: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await db.attachmentDao.deleteForMessage(messageId);
    } else {
      clientMessageId = _uuid.v4();
      rfcId = '<$clientMessageId@local>';
      messageId = await db.messageDao.insertMessage(
        MessagesCompanion.insert(
          accountId: accountId,
          folderId: Value(draftFolder?.id),
          clientMessageId: Value(clientMessageId),
          messageId: Value(rfcId),
          fromAddr: Value(account.email),
          toAddr: Value(toJoined),
          ccAddr: Value(ccJoined),
          bccAddr: Value(bccJoined),
          subject: Value(subject),
          inReplyTo: Value(inReplyTo),
          referencesHeader: Value(references),
          date: DateTime.now(),
          state: const Value('draft'),
          isRead: const Value(true),
          hasAttachment: Value(hasAtt),
        ),
      );
    }

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
            mimeType: Value(
              MediaType.guessFromFileName(file.uri.pathSegments.last).text,
            ),
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
      toAddr: toJoined,
    );

    unawaited(
      _pushDraftToImap(
        accountId: accountId,
        account: account,
        messageId: messageId,
        draftFolderId: draftFolder?.id,
        toJoined: toJoined,
        ccJoined: ccJoined,
        bccJoined: bccJoined,
        subject: subject,
        plainText: plainText,
        htmlText: htmlText,
        clientMessageId: clientMessageId,
        rfcId: rfcId,
        inReplyTo: inReplyTo,
        references: references,
        previousUid: previousUid,
        previousFolderId: previousFolderId,
      ),
    );
    return messageId;
  }

  Future<void> _pushDraftToImap({
    required String accountId,
    required Account account,
    required int messageId,
    required int? draftFolderId,
    required String toJoined,
    required String? ccJoined,
    required String? bccJoined,
    required String subject,
    required String? plainText,
    required String? htmlText,
    required String clientMessageId,
    required String rfcId,
    required String? inReplyTo,
    required String? references,
    required String? previousUid,
    required int? previousFolderId,
  }) async {
    try {
      final atts = await db.attachmentDao.listForMessage(messageId);
      final mime = await OutgoingMime.build(
        account: account,
        toAddr: toJoined,
        ccAddr: ccJoined ?? '',
        bccAddr: bccJoined ?? '',
        subject: subject,
        plainText: plainText,
        htmlText: htmlText,
        clientMessageId: clientMessageId,
        messageIdHeader: rfcId,
        inReplyTo: inReplyTo,
        references: references,
        attachments: atts,
      );
      final uid = await _accounts[accountId]?.appendDraft(mime);
      if (uid != null) {
        await db.messageDao.updateMessage(
          messageId,
          MessagesCompanion(
            uid: Value(uid),
            folderId: Value(draftFolderId),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      // Drop the previous IMAP copy so sync does not resurrect a stale draft.
      if (previousUid != null &&
          previousFolderId != null &&
          previousUid != uid) {
        try {
          await _accounts[accountId]?.expungeDraftUid(
            uid: previousUid,
            folderId: previousFolderId,
          );
        } catch (e) {
          // ignore: avoid_print
          print('expunge superseded draft uid=$previousUid failed: $e');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('saveDraft IMAP APPEND failed: $e');
    }
  }

  /// Update password-account hosts / password / display name.
  Future<MailAccountDto> updateAccount({
    required String accountId,
    String? displayName,
    String? password,
    String? imapHost,
    int? imapPort,
    String? smtpHost,
    int? smtpPort,
  }) async {
    final existing = await db.accountDao.findById(accountId);
    if (existing == null) {
      throw StateError('Account $accountId not found');
    }
    if (existing.authType == 'oauth2' && password != null) {
      throw StateError('Cannot set password on OAuth account');
    }
    await db.accountDao.upsert(
      AccountsCompanion(
        id: Value(accountId),
        email: Value(existing.email),
        displayName: Value(displayName ?? existing.displayName),
        imapHost: Value(imapHost ?? existing.imapHost),
        imapPort: Value(imapPort ?? existing.imapPort),
        imapSsl: Value(existing.imapSsl),
        smtpHost: Value(smtpHost ?? existing.smtpHost),
        smtpPort: Value(smtpPort ?? existing.smtpPort),
        smtpSsl: Value(existing.smtpSsl),
        username: Value(existing.username),
        authType: Value(existing.authType),
        provider: Value(existing.provider),
        createdAt: Value(existing.createdAt),
      ),
    );
    if (password != null && password.isNotEmpty) {
      await credentials.savePassword(accountId, password);
    }
    final engine = _accounts.remove(accountId);
    await engine?.stop();
    final updated = (await db.accountDao.findById(accountId))!;
    await _register(updated, start: true);
    return MailMapper.toAccountDto(updated);
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

  /// Prefer IMAP delete first; only then soft-delete locally / FTS.
  Future<void> deleteMessage(int messageId) async {
    final message = await db.messageDao.findById(messageId);
    if (message == null) return;
    final engine = _accounts[message.accountId];
    if (engine != null) {
      await engine.deleteMessage(messageId);
    } else if (message.uid == null) {
      await db.messageDao.markDeleted(messageId);
      await db.outboxDao.deleteByMessageId(messageId);
    } else {
      throw StateError('Account ${message.accountId} is not running');
    }
    try {
      await indexer.remove(messageId);
    } catch (_) {}
  }

  /// Move message to Archive on IMAP and locally.
  Future<void> moveToArchive(int messageId) =>
      moveToRole(messageId, 'archive');

  /// Move message to Inbox on IMAP and locally (e.g. unarchive).
  Future<void> moveToInbox(int messageId) =>
      moveToRole(messageId, 'inbox');

  Future<void> moveToRole(int messageId, String role) async {
    final message = await db.messageDao.findById(messageId);
    if (message == null) return;
    final engine = _accounts[message.accountId];
    if (engine != null) {
      await engine.moveMessageToRole(messageId, role);
    } else if (message.uid == null) {
      final folder = await db.folderDao.findByRole(message.accountId, role);
      if (folder == null) {
        throw StateError('No $role folder for account ${message.accountId}');
      }
      await db.messageDao.updateMessage(
        messageId,
        MessagesCompanion(
          folderId: Value(folder.id),
          state: Value(role),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      throw StateError('Account ${message.accountId} is not running');
    }
  }

  Future<void> createFolder({
    required String accountId,
    required String path,
  }) async {
    final engine = _accounts[accountId];
    if (engine == null) {
      throw StateError('Account $accountId is not running');
    }
    await engine.createFolder(path);
  }

  Future<void> renameFolder({
    required String accountId,
    required String oldPath,
    required String newPath,
  }) async {
    final engine = _accounts[accountId];
    if (engine == null) {
      throw StateError('Account $accountId is not running');
    }
    await engine.renameFolder(oldPath, newPath);
  }

  Future<void> deleteFolder({
    required String accountId,
    required String path,
  }) async {
    final engine = _accounts[accountId];
    if (engine == null) {
      throw StateError('Account $accountId is not running');
    }
    await engine.deleteFolder(path);
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
