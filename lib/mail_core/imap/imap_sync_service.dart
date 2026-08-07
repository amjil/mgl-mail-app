import 'dart:async';

import 'package:drift/drift.dart';
import 'package:enough_mail/enough_mail.dart';

import '../db/app_database.dart';
import '../search/fts_indexer.dart';

class ImapSyncService {
  ImapSyncService({
    required this.db,
    required this.account,
    required this.getSecret,
    this.useOAuth = false,
    this.isLogEnabled = false,
  }) : indexer = FtsIndexer(db);

  final AppDatabase db;
  final Account account;

  /// Password or OAuth access token (resolved just-in-time for refresh).
  final Future<String> Function() getSecret;
  final bool useOAuth;
  final bool isLogEnabled;
  final FtsIndexer indexer;

  ImapClient? _client;

  /// Serializes IMAP command sequences (single connection is not concurrent-safe).
  Future<void> _opChain = Future<void>.value();

  bool get isConnected => _client?.isLoggedIn ?? false;
  ImapClient get client {
    final c = _client;
    if (c == null) {
      throw StateError('IMAP client not connected');
    }
    return c;
  }

  Future<T> _serialized<T>(Future<T> Function() action) {
    final gate = Completer<void>();
    final prev = _opChain;
    _opChain = gate.future;
    return prev.catchError((_) {}).then((_) => action()).whenComplete(() {
      gate.complete();
    });
  }

  Future<void> connect() async {
    if (isConnected) return;
    final c = ImapClient(isLogEnabled: isLogEnabled);
    await c.connectToServer(
      account.imapHost,
      account.imapPort,
      isSecure: account.imapSsl,
    );
    final secret = await getSecret();
    if (useOAuth) {
      await c.authenticateWithOAuth2(account.username, secret);
    } else {
      await c.login(account.username, secret);
    }
    _client = c;
  }

  Future<void> disconnect() async {
    final c = _client;
    if (c == null) return;
    try {
      if (c.isLoggedIn) await c.logout();
    } catch (_) {}
    try {
      await c.disconnect();
    } catch (_) {}
    _client = null;
  }

  Future<void> syncAll({int inboxLimit = 50}) => _serialized(() async {
        await connect();
        await syncFolders();
        // Inbox is required; others are best-effort so one bad path
        // cannot wipe the whole sync.
        await _syncRoleSafe('inbox', limit: inboxLimit, required: true);
        await _syncRoleSafe('sent', limit: inboxLimit, required: false);
        await _syncRoleSafe('draft', limit: inboxLimit, required: false);
        await _syncRoleSafe('archive', limit: inboxLimit, required: false);
        await _syncRoleSafe('trash', limit: inboxLimit, required: false);
      });

  Future<void> _syncRoleSafe(
    String role, {
    required int limit,
    required bool required,
  }) async {
    try {
      await syncFolderByRole(role, limit: limit);
    } catch (e) {
      // ignore: avoid_print
      print('syncFolderByRole($role) failed: $e');
      if (required) rethrow;
    }
  }

  Future<void> syncFolders() async {
    final boxes = await client.listMailboxes(recursive: true);
    for (final box in boxes) {
      // Some servers LIST UTF-8 names but only accept modified UTF-7 in SELECT.
      final path = _storagePathFor(box);
      if (path.isEmpty) continue;
      final selectable = !box.isNotSelectable;
      await db.folderDao.upsertFolder(
        FoldersCompanion.insert(
          accountId: account.id,
          name: box.name,
          path: path,
          role: _mapRole(box),
          selectable: Value(selectable),
        ),
      );
    }
    // Guarantee an inbox row even when the server omits \Inbox / special-use.
    final inbox = await db.folderDao.findByRole(account.id, 'inbox');
    if (inbox == null) {
      await db.folderDao.upsertFolder(
        FoldersCompanion.insert(
          accountId: account.id,
          name: 'INBOX',
          path: 'INBOX',
          role: 'inbox',
          selectable: const Value(true),
        ),
      );
    }
    // Repair stale custom roles (e.g. localized Drafts/Archive left as custom).
    await _remapFolderRolesByName();
    await _mergeUnicodePathDuplicates();
    await _dedupeFolders();
    await refreshAllUnreadCounts();
  }

  Future<void> _remapFolderRolesByName() async {
    final all = await db.folderDao.listForAccount(account.id);
    for (final f in all) {
      final mapped = mapRoleFromName(f.name);
      if (mapped != 'custom' && mapped != f.role) {
        await (db.update(db.folders)..where((row) => row.id.equals(f.id)))
            .write(FoldersCompanion(role: Value(mapped)));
        // ignore: avoid_print
        print('remap folder "${f.name}" role ${f.role} → $mapped');
      }
    }
  }

  /// Drop leftover UTF-8 path rows when an mUTF-7 twin already exists.
  Future<void> _mergeUnicodePathDuplicates() async {
    final all = await db.folderDao.listForAccount(account.id);
    final byName = <String, List<Folder>>{};
    for (final f in all) {
      final key = f.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      (byName[key] ??= []).add(f);
    }
    for (final group in byName.values) {
      if (group.length <= 1) continue;
      Folder? ascii;
      final unicode = <Folder>[];
      for (final f in group) {
        if (_hasNonAscii(f.path)) {
          unicode.add(f);
        } else {
          ascii ??= f;
        }
      }
      if (ascii == null) continue;
      for (final u in unicode) {
        await _mergeFolders(from: u, into: ascii);
      }
    }
  }

  /// Keep one selectable folder per well-known role, and one per display name.
  Future<void> _dedupeFolders() async {
    Future<int> score(Folder f) async {
      // Prefer folders that already have local mail (avoid keeping an empty twin).
      final msgCount = await db.messageDao.countInFolder(f.id);
      var s = msgCount * 1000;
      final n = f.name.toLowerCase().trim();
      if (f.path.toUpperCase() == 'INBOX') s += 500;
      if (f.role == 'draft' &&
          (n.contains('草稿') || n == 'drafts' || n == 'draft')) {
        s += 200;
      }
      if (f.role == 'archive' &&
          (n.contains('归档') ||
              n.contains('歸檔') ||
              n.contains('archive'))) {
        s += 200;
      }
      if (f.role == 'sent' &&
          (n.contains('已发送') ||
              n.contains('已傳送') ||
              n.contains('sent') ||
              n.contains('寄件'))) {
        s += 200;
      }
      if (f.role == 'trash' &&
          (n.contains('删除') ||
              n.contains('刪除') ||
              n.contains('trash') ||
              n.contains('deleted'))) {
        s += 200;
      }
      // Mild preference for shorter paths when scores tie.
      s += (200 - f.path.length).clamp(0, 200);
      return s;
    }

    Future<void> collapse(List<Folder> group) async {
      if (group.isEmpty) return;
      if (group.length == 1) {
        if (!group.first.selectable) {
          await db.folderDao.markSelectable(group.first.id, true);
        }
        return;
      }
      final scored = <({Folder f, int s})>[];
      for (final f in group) {
        scored.add((f: f, s: await score(f)));
      }
      scored.sort((a, b) {
        final c = b.s.compareTo(a.s);
        return c != 0 ? c : a.f.id.compareTo(b.f.id);
      });
      final keep = scored.first.f;
      await db.folderDao.markSelectable(keep.id, true);
      for (final item in scored.skip(1)) {
        await db.folderDao.markSelectable(item.f.id, false);
      }
    }

    final all = await db.folderDao.listForAccount(account.id);

    // Role groups: consider selectable + previously hidden twins.
    for (final role in const ['inbox', 'sent', 'draft', 'archive', 'trash']) {
      await collapse(all.where((f) => f.role == role).toList());
    }

    // Same display name with different paths.
    final still = await db.folderDao.listForAccount(account.id);
    final byName = <String, List<Folder>>{};
    for (final f in still) {
      final key = f.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      (byName[key] ??= []).add(f);
    }
    for (final group in byName.values) {
      await collapse(group);
    }
  }

  String _mapRole(Mailbox box) {
    if (box.isInbox) return 'inbox';
    if (box.isSent) return 'sent';
    if (box.isTrash) return 'trash';
    if (box.isDrafts) return 'draft';
    if (box.isArchive) return 'archive';
    return mapRoleFromName(box.name);
  }

  /// Public so UI/engine can treat localized Drafts/Archive as special even if role was custom.
  static String mapRoleFromName(String name) {
    final n = name.toLowerCase().trim();
    if (n == 'inbox') return 'inbox';
    if (n == 'sent' ||
        n == 'sent items' ||
        n == 'sent messages' ||
        n.contains('已发送') ||
        n.contains('已傳送') ||
        n.contains('寄件备份') ||
        n.contains('寄件備份')) {
      return 'sent';
    }
    if (n == 'drafts' ||
        n == 'draft' ||
        n.contains('草稿') ||
        n.contains('draft')) {
      return 'draft';
    }
    if (n == 'archive' ||
        n == 'archived' ||
        n.contains('归档') ||
        n.contains('歸檔') ||
        n.contains('档案') ||
        n.contains('檔案') ||
        n.contains('archive')) {
      return 'archive';
    }
    if (n == 'trash' ||
        n == 'deleted items' ||
        n == 'deleted messages' ||
        n.contains('trash') ||
        n.contains('deleted') ||
        n.contains('已删除') ||
        n.contains('已刪除') ||
        n.contains('垃圾桶') ||
        n.contains('ゴミ箱')) {
      return 'trash';
    }
    return 'custom';
  }

  /// Resolve effective role for a stored folder (name wins over stale custom).
  String effectiveRole(Folder folder) {
    if (folder.role != 'custom') return folder.role;
    return mapRoleFromName(folder.name);
  }

  Future<void> syncFolderByRole(String role, {int limit = 50}) async {
    await connect();
    // Probe live LIST candidates and keep the mailbox that actually has mail.
    // Chinese ISPs often expose both an empty "Drafts" and a populated localized drafts folder.
    final best = await _pickBestMailboxForRole(role);
    if (best != null) {
      final id = await db.folderDao.upsertFolder(
        FoldersCompanion.insert(
          accountId: account.id,
          name: best.box.name,
          path: best.path,
          role: role,
          selectable: const Value(true),
        ),
      );
      // Hide other same-role twins so UI/sync stick to the populated one.
      final twins =
          await db.folderDao.listByRole(role, accountId: account.id);
      for (final t in twins) {
        if (t.id != id) {
          await db.folderDao.markSelectable(t.id, false);
        }
      }
      // Also hide custom-named twins that map to this role.
      final all = await db.folderDao.listForAccount(account.id);
      for (final t in all) {
        if (t.id != id && mapRoleFromName(t.name) == role) {
          await db.folderDao.markSelectable(t.id, false);
          if (t.role != role) {
            await (db.update(db.folders)..where((row) => row.id.equals(t.id)))
                .write(FoldersCompanion(role: Value(role)));
          }
        }
      }
      final folder = await db.folderDao.findById(id);
      if (folder != null) {
        // Use full _selectFolder path adoption/merge — do not trust a bare
        // alreadySelected from probing (connection may have moved on).
        await syncFolderMessages(folder, limit: limit);
        return;
      }
    }

    final folder = await db.folderDao.findByRole(account.id, role);
    if (folder == null) {
      // ignore: avoid_print
      print('syncFolderByRole($role): no folder found');
      return;
    }
    await syncFolderMessages(folder, limit: limit);
  }

  /// SELECT each role candidate; return the one with the highest EXISTS count.
  Future<({Mailbox box, String path, int exists})?> _pickBestMailboxForRole(
    String role,
  ) async {
    List<Mailbox> boxes;
    try {
      boxes = await client.listMailboxes(recursive: true);
    } catch (e) {
      // ignore: avoid_print
      print('listMailboxes for role=$role failed: $e');
      return null;
    }

    final candidates = <Mailbox>[];
    for (final box in boxes) {
      if (box.isNotSelectable) continue;
      final mapped = _mapRole(box);
      final special = (role == 'draft' && box.isDrafts) ||
          (role == 'trash' && box.isTrash) ||
          (role == 'sent' && box.isSent) ||
          (role == 'inbox' && box.isInbox) ||
          (role == 'archive' && box.isArchive);
      if (mapped == role || special) {
        candidates.add(box);
      }
    }
    if (candidates.isEmpty) {
      // ignore: avoid_print
      print('role=$role: no LIST candidates');
      return null;
    }
    // ignore: avoid_print
    print(
      'role=$role candidates: '
      '${candidates.map((b) => "${b.name}[${b.encodedPath}]").join(", ")}',
    );

    int nameBonus(Mailbox box) {
      final n = box.name.toLowerCase();
      switch (role) {
        case 'draft':
          if (n.contains('草稿') || n.contains('draft')) return 2;
          break;
        case 'archive':
          if (n.contains('归档') ||
              n.contains('歸檔') ||
              n.contains('档案') ||
              n.contains('檔案') ||
              n.contains('archive')) {
            return 2;
          }
          break;
        case 'trash':
          if (n.contains('删除') ||
              n.contains('刪除') ||
              n.contains('trash') ||
              n.contains('deleted')) {
            return 2;
          }
          break;
        case 'sent':
          if (n.contains('已发送') ||
              n.contains('已傳送') ||
              n.contains('sent') ||
              n.contains('寄件')) {
            return 2;
          }
          break;
      }
      return 0;
    }

    ({Mailbox box, String path, int exists})? best;
    var bestScore = -1;
    for (final box in candidates) {
      final selected = await _selectMailboxTryingPaths(box);
      if (selected == null) continue;
      final count = selected.$1.messagesExists;
      final path = selected.$2;
      final score = count * 10 + nameBonus(box);
      // ignore: avoid_print
      print(
        'role=$role probe name="${box.name}" path="$path" '
        'exists=$count score=$score',
      );
      if (score > bestScore) {
        bestScore = score;
        best = (box: box, path: path, exists: count);
      }
    }
    // ignore: avoid_print
    print(
      'role=$role picked name="${best?.box.name}" path="${best?.path}" '
      'exists=${best?.exists} from ${candidates.length} candidates',
    );
    // Never blindly return an unselectable/unprobed twin.
    return best;
  }

  Future<void> syncFolderMessages(
    Folder folder, {
    int limit = 50,
    Mailbox? alreadySelected,
  }) async {
    final path = folder.path.trim();
    if (path.isEmpty) return;
    if (!folder.selectable) {
      await db.folderDao.markSelectable(folder.id, true);
    }
    var mailbox = alreadySelected;
    try {
      mailbox ??= await _selectFolder(folder);
    } catch (e) {
      // ignore: avoid_print
      print('SELECT failed path="$path" role=${folder.role}: $e');
      rethrow;
    }
    // Prefer server LIST encodedPath if current SELECT looks empty.
    var active = await _canonicalFolder(folder);
    try {
      if (mailbox!.messagesExists == 0) {
        final live = await _resolveLiveMailbox(active);
        if (live != null) {
          final retry = await _selectMailboxTryingPaths(live);
          if (retry != null &&
              retry.$1.messagesExists > mailbox.messagesExists) {
            mailbox = retry.$1;
            try {
              active = await _adoptWorkingPath(active, retry.$2);
            } catch (e) {
              // ignore: avoid_print
              print('adopt after empty-select retry failed: $e');
            }
            // ignore: avoid_print
            print(
              're-SELECT empty→exists name="${active.name}" '
              'path="${retry.$2}" exists=${mailbox.messagesExists}',
            );
          }
        }
      }
      final validity = mailbox.uidValidity;

    // ignore: avoid_print
    print(
      'syncFolderMessages name="${active.name}" path="${active.path}" '
      'role=${active.role} exists=${mailbox.messagesExists}',
    );

    final sync = await db.syncStateDao.find(account.id, active.id);
    if (sync?.uidValidity != null &&
        validity != null &&
        sync!.uidValidity != validity) {
      // ignore: avoid_print
      print('UIDVALIDITY changed for ${active.path}; refetching recent');
    }

    var allUids = <int>[];
    try {
      allUids = (await client.uidSearchMessages(searchCriteria: 'ALL'))
              .matchingSequence
              ?.toList() ??
          <int>[];
    } catch (e) {
      // ignore: avoid_print
      print('UID SEARCH ALL failed: $e');
    }
    if (allUids.isEmpty && mailbox.messagesExists > 0) {
      try {
        allUids = (await client.uidSearchMessages(searchCriteria: 'UID 1:*'))
                .matchingSequence
                ?.toList() ??
            <int>[];
      } catch (e) {
        // ignore: avoid_print
        print('UID SEARCH UID 1:* failed: $e');
      }
    }
    // Some CN ISP mailboxes report EXISTS but return empty UID SEARCH.
    // Recover UIDs (or store directly) via sequence FETCH of the recent window.
    if (allUids.isEmpty && mailbox.messagesExists > 0) {
      final end = mailbox.messagesExists;
      final start = end > limit ? end - limit + 1 : 1;
      allUids = await _uidsFromSequenceRange(start, end);
      if (allUids.isEmpty) {
        // Last resort: FETCH envelopes by sequence and upsert without UID list.
        // ignore: avoid_print
        print(
          'seq UID recovery empty; fetching envelopes $start:$end directly',
        );
        await _fetchAndStoreBySequence(active, start, end);
        await _saveSyncState(active.id, 0, validity);
        // ignore: avoid_print
        print(
          'syncFolderMessages done(seq) localCount='
          '${await db.messageDao.countInFolder(active.id)}',
        );
        return;
      }
    }
    // ignore: avoid_print
    print(
      'syncFolderMessages uidCount=${allUids.length} '
      'exists=${mailbox.messagesExists}',
    );
    if (allUids.isEmpty) {
      await _saveSyncState(active.id, 0, validity);
      return;
    }

    allUids.sort();
    final target = allUids.length <= limit
        ? allUids
        : allUids.sublist(allUids.length - limit);
    final targetStr = target.map((e) => '$e').toList();
    final existing = await db.messageDao.findExistingUids(active.id, targetStr);
    var newUids =
        target.where((u) => !existing.contains('$u')).toList(growable: false);
    if (newUids.isEmpty &&
        (await db.messageDao.countInFolder(active.id)) == 0) {
      newUids = target;
    }
    if (newUids.isNotEmpty) {
      await _fetchAndStoreHeaders(active, newUids);
    }

    await _fetchAndUpdateFlags(active, target);

    final maxUid = target.isEmpty ? 0 : target.last;
    await _saveSyncState(active.id, maxUid, validity);
    // ignore: avoid_print
    print(
      'syncFolderMessages done localCount='
      '${await db.messageDao.countInFolder(active.id)}',
    );
    } finally {
      await refreshUnreadCount(active.id);
    }
  }

  /// Recompute [Folders.unreadCount] from local unread messages.
  Future<void> refreshUnreadCount(int folderId) async {
    final n = await db.messageDao.countUnreadInFolder(folderId);
    await db.folderDao.setUnreadCount(folderId, n);
  }

  Future<void> refreshAllUnreadCounts() async {
    final rows = await db.folderDao.listSelectable(accountId: account.id);
    for (final f in rows) {
      await refreshUnreadCount(f.id);
    }
  }

  Future<Folder> _canonicalFolder(Folder folder) async {
    final still = await db.folderDao.findById(folder.id);
    if (still != null) {
      if (!_hasNonAscii(still.path)) return still;
      final twin = await _findAsciiTwin(still);
      return twin ?? still;
    }
    final byName =
        await db.folderDao.findByName(folder.accountId, folder.name);
    if (byName != null) return byName;
    if (folder.role != 'custom') {
      final byRole =
          await db.folderDao.findByRole(folder.accountId, folder.role);
      if (byRole != null) return byRole;
    }
    return folder;
  }

  Future<void> syncMailboxDelta(Mailbox mailbox) => _serialized(() async {
        await connect();
        final path = mailbox.encodedPath;
        var folder = await db.folderDao.findByPath(account.id, path);
        if (folder == null) {
          await syncFolders();
          folder = await db.folderDao.findByPath(account.id, path);
          if (folder == null) return;
        }
        await syncFolderMessages(folder, limit: 30);
      });

  Future<List<int>> _uidsFromSequenceRange(int start, int end) async {
    if (end < start || end <= 0) return const [];
    final seq = MessageSequence.fromRange(start, end);
    for (final criteria in ['(UID)', 'UID', '(FLAGS UID)', 'FAST']) {
      try {
        final fetched = await client.fetchMessages(seq, criteria);
        final uids = fetched.messages
            .map((m) => m.uid)
            .whereType<int>()
            .toList();
        // ignore: avoid_print
        print('seq UID recovery $criteria $start:$end → ${uids.length} uids');
        if (uids.isNotEmpty) return uids;
      } catch (e) {
        // ignore: avoid_print
        print('seq UID recovery $criteria failed: $e');
      }
    }
    return const [];
  }

  Future<void> _fetchAndStoreBySequence(
    Folder folder,
    int start,
    int end,
  ) async {
    if (end < start || end <= 0) return;
    const criteriaOptions = <String>[
      '(FLAGS ENVELOPE)',
      '(ENVELOPE)',
      'ENVELOPE',
      '(FLAGS BODY.PEEK[HEADER])',
      'BODY.PEEK[HEADER]',
      'RFC822.HEADER',
      'FAST',
    ];
    // Fetch in small chunks for finicky CN ISP servers.
    for (var i = start; i <= end; i += 10) {
      final chunkEnd = i + 9 > end ? end : i + 9;
      final sequence = MessageSequence.fromRange(i, chunkEnd);
      Object? lastError;
      var ok = false;
      for (final criteria in criteriaOptions) {
        try {
          final result = await client.fetchMessages(sequence, criteria);
          for (final mime in result.messages) {
            await upsertFromMime(folder, mime);
          }
          ok = true;
          break;
        } catch (e) {
          lastError = e;
          final msg = e.toString();
          final retryable = msg.contains('Excessively complex') ||
              msg.contains('BAD') ||
              msg.contains('parse');
          // ignore: avoid_print
          print('SEQ FETCH $criteria $i:$chunkEnd failed: $e');
          if (!retryable) break;
        }
      }
      if (!ok && lastError != null) {
        // ignore: avoid_print
        print('SEQ FETCH $i:$chunkEnd gave up: $lastError');
      }
    }
  }

  Future<void> _fetchAndStoreHeaders(Folder folder, List<int> uids) async {
    // Sina (and similar CN ISP IMAP) rejects many multi-attr FETCH forms with
    // "BAD Excessively complex FETCH attribute list". Try simplest first,
    // in small chunks.
    const criteriaOptions = <String>[
      '(FLAGS ENVELOPE)',
      '(ENVELOPE)',
      'ENVELOPE',
      '(FLAGS BODY.PEEK[HEADER])',
      'BODY.PEEK[HEADER]',
      'RFC822.HEADER',
      'FAST',
    ];

    String? workingCriteria;
    for (var i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10);
      final sequence = MessageSequence.fromIds(chunk, isUid: true);
      final result = await _uidFetchWithFallback(
        sequence,
        workingCriteria != null ? [workingCriteria] : criteriaOptions,
      );
      workingCriteria ??= result.$1;
      for (final mime in result.$2.messages) {
        await upsertFromMime(folder, mime);
      }
    }
  }

  /// Returns `(criteriaUsed, fetchResult)`.
  Future<(String, FetchImapResult)> _uidFetchWithFallback(
    MessageSequence sequence,
    List<String> criteriaOptions,
  ) async {
    Object? lastError;
    for (final criteria in criteriaOptions) {
      try {
        final result = await client.uidFetchMessages(sequence, criteria);
        return (criteria, result);
      } catch (e) {
        lastError = e;
        final msg = e.toString();
        final retryable = msg.contains('Excessively complex') ||
            msg.contains('BAD') ||
            msg.contains('parse');
        // ignore: avoid_print
        print('UID FETCH $criteria failed: $e');
        if (!retryable) rethrow;
      }
    }
    throw lastError ?? StateError('UID FETCH failed with no criteria');
  }

  Future<void> _fetchAndUpdateFlags(Folder folder, List<int> uids) async {
    if (uids.isEmpty) return;
    // UID FETCH already returns UIDs; keep attribute list minimal for Sina.
    for (var i = 0; i < uids.length; i += 20) {
      final chunk = uids.sublist(i, i + 20 > uids.length ? uids.length : i + 20);
      final sequence = MessageSequence.fromIds(chunk, isUid: true);
      FetchImapResult result;
      try {
        result = await client.uidFetchMessages(sequence, '(FLAGS)');
      } catch (_) {
        try {
          result = await client.uidFetchMessages(sequence, 'FLAGS');
        } catch (e) {
          // ignore: avoid_print
          print('FLAGS FETCH failed: $e');
          return;
        }
      }
      for (final mime in result.messages) {
        final uid = mime.uid;
        if (uid == null) continue;
        final existing =
            await db.messageDao.findByUid(account.id, folder.id, '$uid');
        if (existing == null) continue;
        await db.messageDao.updateMessage(
          existing.id,
          MessagesCompanion(
            isRead: Value(mime.isSeen),
            isStarred: Value(mime.isFlagged),
            deleted: Value(mime.isDeleted),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }
  }

  Future<int> upsertFromMime(Folder folder, MimeMessage mime) async {
    final uid = mime.uid;
    final uidStr = uid?.toString();
    final from = mime.from?.isNotEmpty == true ? mime.from!.first : null;
    final to = _joinAddresses(mime.to);
    final cc = _joinAddresses(mime.cc);
    final subject = mime.decodeSubject();
    final date = mime.decodeDate() ?? DateTime.now();
    final messageId =
        mime.getHeaderValue('message-id') ?? mime.envelope?.messageId;
    final clientId = mime.getHeaderValue('x-client-message-id');
    final inReplyTo = mime.getHeaderValue('in-reply-to');
    final references = mime.getHeaderValue('references');
    // ENVELOPE-only FETCH has no bodystructure; treat as unknown/false.
    final hasAtt = mime.hasAttachments();
    final state = folder.role == 'sent'
        ? 'sent'
        : folder.role == 'draft'
            ? 'draft'
            : folder.role == 'archive'
                ? 'archive'
                : folder.role == 'trash'
                    ? 'trash'
                    : 'inbox';

    if (uidStr != null) {
      final existing =
          await db.messageDao.findByUid(account.id, folder.id, uidStr);
      if (existing != null) {
        await db.messageDao.updateMessage(
          existing.id,
          MessagesCompanion(
            messageId: Value(messageId),
            clientMessageId: Value(clientId ?? existing.clientMessageId),
            fromAddr: Value(from?.email ?? existing.fromAddr),
            fromName: Value(from?.personalName ?? existing.fromName),
            toAddr: Value(to),
            ccAddr: Value(cc),
            subject: Value(subject),
            inReplyTo: Value(inReplyTo ?? existing.inReplyTo),
            referencesHeader: Value(references ?? existing.referencesHeader),
            date: Value(date),
            isRead: Value(mime.isSeen),
            isStarred: Value(mime.isFlagged),
            hasAttachment: Value(hasAtt),
            size: Value(mime.size),
            state: Value(state),
            updatedAt: Value(DateTime.now()),
          ),
        );
        await indexer.indexMessage(
          messageId: existing.id,
          accountId: account.id,
          subject: subject,
          fromAddr: from?.email,
          toAddr: to,
        );
        return existing.id;
      }
    }

    // Reconcile local outbox/draft by client / RFC message-id
    if (clientId != null && clientId.isNotEmpty) {
      final byClient =
          await db.messageDao.findByClientMessageId(account.id, clientId);
      if (byClient != null) {
        await db.messageDao.updateMessage(
          byClient.id,
          MessagesCompanion(
            folderId: Value(folder.id),
            uid: Value(uidStr),
            messageId: Value(messageId),
            state: Value(state),
            isRead: Value(mime.isSeen),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return byClient.id;
      }
    }
    if (messageId != null && messageId.isNotEmpty) {
      final byMid =
          await db.messageDao.findByRfcMessageId(account.id, messageId);
      if (byMid != null) {
        await db.messageDao.updateMessage(
          byMid.id,
          MessagesCompanion(
            folderId: Value(folder.id),
            uid: Value(uidStr),
            state: Value(state),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return byMid.id;
      }
    }

    final id = await db.messageDao.insertMessage(
      MessagesCompanion.insert(
        accountId: account.id,
        folderId: Value(folder.id),
        uid: Value(uidStr),
        messageId: Value(messageId),
        clientMessageId: Value(clientId),
        fromAddr: Value(from?.email ?? ''),
        fromName: Value(from?.personalName),
        toAddr: Value(to),
        ccAddr: Value(cc),
        subject: Value(subject),
        inReplyTo: Value(inReplyTo),
        referencesHeader: Value(references),
        date: date,
        state: Value(state),
        isRead: Value(mime.isSeen),
        isStarred: Value(mime.isFlagged),
        hasAttachment: Value(hasAtt),
        size: Value(mime.size),
      ),
    );

    await indexer.indexMessage(
      messageId: id,
      accountId: account.id,
      subject: subject,
      fromAddr: from?.email,
      toAddr: to,
    );

    if (hasAtt) {
      await _storeAttachmentMeta(id, mime);
    }
    return id;
  }

  Future<void> _storeAttachmentMeta(int messageId, MimeMessage mime) async {
    final parts = mime.findContentInfo(disposition: ContentDisposition.attachment);
    for (final info in parts) {
      await db.attachmentDao.upsertMeta(
        AttachmentsCompanion.insert(
          messageId: messageId,
          filename: info.fileName ?? 'attachment',
          mimeType: Value(info.contentType?.mediaType.toString()),
          size: Value(info.size),
          partId: Value(info.fetchId),
          contentId: Value(info.cid),
        ),
      );
    }
  }

  Future<void> downloadBodyIfNeeded(int messageId) => _serialized(() async {
        final message = await db.messageDao.findById(messageId);
        if (message == null || message.uid == null || message.folderId == null) {
          return;
        }
        final body = await db.messageBodyDao.find(messageId);
        if (body?.isDownloaded == true) return;

        final folder = await db.folderDao.findById(message.folderId!);
        if (folder == null || folder.path.trim().isEmpty) return;

        await connect();
        await _selectFolder(folder);
        final uid = int.parse(message.uid!);
        // Prefer PEEK so opening mail does not flip \Seen on the server twice;
        // fall back for servers that reject BODY.PEEK[].
        FetchImapResult? result;
        for (final criteria in ['BODY.PEEK[]', 'BODY[]', 'RFC822']) {
          try {
            result = await client.uidFetchMessage(
              uid,
              criteria,
              responseTimeout: const Duration(seconds: 30),
            );
            break;
          } catch (e) {
            // ignore: avoid_print
            print('uidFetchMessage($criteria) failed: $e');
          }
        }
        if (result == null || result.messages.isEmpty) return;
        final mime = result.messages.first;
        final plain = mime.decodeTextPlainPart();
        final html = mime.decodeTextHtmlPart();
        await db.messageBodyDao.upsert(
          MessageBodiesCompanion.insert(
            messageId: Value(messageId),
            plainText: Value(plain),
            htmlText: Value(html),
            isDownloaded: const Value(true),
            downloadedAt: Value(DateTime.now()),
          ),
        );
        await indexer.indexMessage(
          messageId: messageId,
          accountId: account.id,
          subject: message.subject,
          body: plain ?? html,
          fromAddr: message.fromAddr,
          toAddr: message.toAddr,
        );
        if (mime.hasAttachments()) {
          await _storeAttachmentMeta(messageId, mime);
        }
      });

  Future<void> _saveSyncState(int folderId, int lastUid, int? validity) {
    return db.syncStateDao.upsert(
      SyncStatesCompanion.insert(
        accountId: account.id,
        folderId: folderId,
        lastUid: Value(lastUid),
        uidValidity: Value(validity),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }

  String _joinAddresses(List<MailAddress>? addrs) {
    if (addrs == null || addrs.isEmpty) return '';
    return addrs.map((a) => a.email).join(', ');
  }

  bool _hasNonAscii(String s) {
    for (final unit in s.codeUnits) {
      if (unit > 0x7F) return true;
    }
    return false;
  }

  /// Convert a Unicode mailbox path to modified UTF-7 for SELECT/STORE.
  /// Encodes every path segment (enough_mail's Mailbox.encode only does the last).
  String _toImapPath(String path, {String pathSeparator = '/'}) {
    final p = path.trim();
    if (p.isEmpty || !_hasNonAscii(p)) return p;
    final sep = pathSeparator.isEmpty ? '/' : pathSeparator;
    return p
        .split(sep)
        .map((seg) {
          if (seg.isEmpty || !_hasNonAscii(seg)) return seg;
          return Mailbox.encode(seg, sep);
        })
        .join(sep);
  }

  /// Path we persist / SELECT with.
  /// Prefer the server-provided [Mailbox.encodedPath] whenever it is already
  /// ASCII (modified UTF-7). Re-encoding a decoded Unicode [Mailbox.path] can
  /// diverge from what SELECT accepts on some CN ISP servers.
  String _storagePathFor(Mailbox box) {
    final sep = box.pathSeparator.isEmpty ? '/' : box.pathSeparator;
    final enc = box.encodedPath.trim();
    if (enc.isNotEmpty && !_hasNonAscii(enc)) {
      return enc;
    }
    if (_hasNonAscii(box.path)) {
      return _toImapPath(box.path, pathSeparator: sep);
    }
    if (enc.isNotEmpty) return enc;
    return box.path.trim();
  }

  /// Candidate SELECT paths for a live LIST mailbox (order matters).
  List<String> _pathCandidatesForMailbox(Mailbox box) {
    final sep = box.pathSeparator.isEmpty ? '/' : box.pathSeparator;
    final out = <String>[];
    void add(String? p) {
      final t = p?.trim() ?? '';
      if (t.isNotEmpty && !out.contains(t)) out.add(t);
    }

    final enc = box.encodedPath.trim();
    if (enc.isNotEmpty && !_hasNonAscii(enc)) add(enc);
    add(_storagePathFor(box));
    add(_toImapPath(box.path, pathSeparator: sep));
    if (box.name.trim().isNotEmpty) {
      add(_toImapPath(box.name, pathSeparator: sep));
    }
    // Last resort: raw Unicode (usually fails on Sina-like servers).
    if (_hasNonAscii(box.path)) add(box.path);
    if (_hasNonAscii(box.name)) add(box.name);
    return out;
  }

  /// SELECT [box] trying every plausible path; returns (selected, workingPath).
  Future<(Mailbox, String)?> _selectMailboxTryingPaths(Mailbox box) async {
    Object? lastError;
    for (final path in _pathCandidatesForMailbox(box)) {
      try {
        final selected = await client.selectMailboxByPath(path);
        return (selected, path);
      } catch (e) {
        lastError = e;
        // ignore: avoid_print
        print(
          'SELECT try name="${box.name}" path="$path" failed: $e',
        );
      }
    }
    if (lastError != null) {
      // ignore: avoid_print
      print('SELECT all paths failed for name="${box.name}": $lastError');
    }
    return null;
  }

  Future<Mailbox?> _resolveLiveMailbox(Folder folder) async {
    List<Mailbox> boxes;
    try {
      boxes = await client.listMailboxes(recursive: true);
    } catch (_) {
      return null;
    }
    for (final box in boxes) {
      final imapPath = _storagePathFor(box);
      if (box.encodedPath == folder.path ||
          box.path == folder.path ||
          box.name == folder.name ||
          imapPath == folder.path) {
        return box;
      }
    }
    if (folder.role != 'custom') {
      for (final box in boxes) {
        if (_mapRole(box) == folder.role) return box;
      }
    }
    return null;
  }

  /// SELECT a folder using a path the server accepts (mUTF-7 when needed).
  /// Returns the mailbox; may merge duplicate local folder rows as a side effect.
  Future<Mailbox> _selectFolder(Folder folder) async {
    if (folder.role == 'inbox') {
      return client.selectInbox();
    }

    // If a twin already stores the working mUTF-7 path, prefer it up front.
    var active = folder;
    if (_hasNonAscii(folder.path)) {
      final twin = await _findAsciiTwin(folder);
      if (twin != null) {
        active = twin;
      }
    }

    final sep = client.serverInfo.pathSeparator ?? '/';
    final live = await _resolveLiveMailbox(active);
    final candidates = <String>[];

    if (!_hasNonAscii(active.path)) {
      candidates.add(active.path.trim());
    }
    if (live != null) {
      candidates.add(_storagePathFor(live));
      final enc = live.encodedPath.trim();
      if (enc.isNotEmpty && !_hasNonAscii(enc)) {
        candidates.add(enc);
      }
    }
    candidates.add(_toImapPath(active.path, pathSeparator: sep));
    candidates.add(_toImapPath(folder.path, pathSeparator: sep));
    if (folder.name.trim().isNotEmpty) {
      candidates.add(_toImapPath(folder.name, pathSeparator: sep));
    }
    // Last resort only — usually fails on this server.
    if (_hasNonAscii(folder.path)) {
      candidates.add(folder.path.trim());
    }

    Object? lastError;
    final tried = <String>{};
    for (final candidate in candidates) {
      final path = candidate.trim();
      if (path.isEmpty || !tried.add(path)) continue;
      try {
        final box = await client.selectMailboxByPath(path);
        try {
          await _adoptWorkingPath(folder, path);
          if (active.id != folder.id) {
            await _adoptWorkingPath(active, path);
          }
        } catch (e) {
          // SELECT succeeded; path bookkeeping must not fail the sync.
          // ignore: avoid_print
          print('adopt path "$path" failed: $e');
        }
        // ignore: avoid_print
        print('SELECT ok path="$path" role=${folder.role}');
        return box;
      } catch (e) {
        lastError = e;
        // ignore: avoid_print
        print('SELECT try path="$path" failed: $e');
      }
    }
    throw lastError ??
        StateError('SELECT failed for folder ${folder.name} (${folder.path})');
  }

  Future<Folder?> _findAsciiTwin(Folder folder) async {
    final rows = await db.folderDao.listByName(folder.accountId, folder.name);
    for (final f in rows) {
      if (f.id != folder.id && !_hasNonAscii(f.path)) return f;
    }
    if (folder.role != 'custom') {
      final byRole =
          await db.folderDao.listByRole(folder.role, accountId: folder.accountId);
      for (final f in byRole) {
        if (f.id != folder.id && !_hasNonAscii(f.path)) return f;
      }
    }
    return null;
  }

  /// Point [folder] at [workingPath], merging into an existing row if needed.
  Future<Folder> _adoptWorkingPath(Folder folder, String workingPath) async {
    if (workingPath == folder.path) {
      await db.folderDao.markSelectable(folder.id, true);
      return folder;
    }
    final other =
        await db.folderDao.findByPath(folder.accountId, workingPath);
    if (other == null) {
      await db.folderDao.updatePath(folder.id, workingPath);
      await db.folderDao.markSelectable(folder.id, true);
      return (await db.folderDao.findById(folder.id)) ?? folder;
    }
    if (other.id == folder.id) return folder;
    await _mergeFolders(from: folder, into: other);
    return other;
  }

  Future<void> _mergeFolders({
    required Folder from,
    required Folder into,
  }) async {
    if (from.id == into.id) return;
    await db.messageDao.reassignFolder(from.id, into.id);
    try {
      await db.syncStateDao.deleteForFolder(from.accountId, from.id);
    } catch (_) {}
    await db.folderDao.markSelectable(into.id, true);
    if (_hasNonAscii(into.path) && !_hasNonAscii(from.path)) {
      // Prefer keeping the ASCII/mUTF-7 path on the surviving row.
      try {
        await db.folderDao.updatePath(into.id, from.path);
      } catch (_) {}
    }
    await db.folderDao.deleteById(from.id);
    // ignore: avoid_print
    print(
      'merged folder id=${from.id} (${from.path}) → id=${into.id} (${into.path})',
    );
  }

  bool _isTrashName(String name) {
    final n = name.toLowerCase().trim();
    return n == 'trash' ||
        n == 'deleted' ||
        n == 'deleted items' ||
        n == 'deleted messages' ||
        n.contains('trash') ||
        n.contains('deleted') ||
        n == '已删除邮件' ||
        n == '已刪除的郵件' ||
        n == '已删除' ||
        n == '垃圾桶' ||
        n == 'ゴミ箱';
  }

  Future<Mailbox?> _findTrashMailbox() async {
    final boxes = await client.listMailboxes(recursive: true);
    for (final box in boxes) {
      if (box.isTrash || _isTrashName(box.name)) return box;
    }
    // DB fallback: resolve stored trash path to a live Mailbox.
    final row = await db.folderDao.findByRole(account.id, 'trash');
    if (row == null || row.path.trim().isEmpty) return null;
    for (final box in boxes) {
      if (box.encodedPath == row.path || box.name == row.name) return box;
    }
    return null;
  }

  bool _isArchiveName(String name) {
    final n = name.toLowerCase().trim();
    return n == 'archive' ||
        n == 'archived' ||
        n.contains('archive') ||
        n.contains('归档') ||
        n.contains('歸檔') ||
        n.contains('档案') ||
        n.contains('檔案');
  }

  Future<Mailbox?> _findMailboxByRole(String role) async {
    final boxes = await client.listMailboxes(recursive: true);
    for (final box in boxes) {
      if (role == 'inbox' && box.isInbox) return box;
      if (role == 'archive' && (box.isArchive || _isArchiveName(box.name))) {
        return box;
      }
      if (role == 'trash' && (box.isTrash || _isTrashName(box.name))) {
        return box;
      }
      if (role == 'draft' && box.isDrafts) return box;
      if (_mapRole(box) == role) return box;
    }
    final row = await db.folderDao.findByRole(account.id, role);
    if (row == null || row.path.trim().isEmpty) return null;
    for (final box in boxes) {
      if (box.encodedPath == row.path || box.name == row.name) return box;
    }
    // INBOX is often listed as path "INBOX" regardless of locale name.
    if (role == 'inbox') {
      for (final box in boxes) {
        if (box.isInbox || box.name.toUpperCase() == 'INBOX') return box;
      }
    }
    return null;
  }

  /// Public LIST lookup for APPEND / MOVE targets (requires [connect] first).
  Future<Mailbox?> findMailboxForRole(String role) =>
      _findMailboxByRole(role);

  /// Paths safe to pass as [ImapClient] `targetMailboxPath`.
  /// Prefer Unicode (`box.path` / display name) so enough_mail encodes once.
  /// Passing already-encoded mUTF-7 (`&X1JoYw-`) becomes `&-X1JoYw-` and
  /// servers respond with NODEST / "No such destination mailbox".
  List<String> _moveTargetPathCandidates(Mailbox box, [Folder? dbFolder]) {
    final out = <String>[];
    void add(String? p) {
      final t = p?.trim() ?? '';
      if (t.isNotEmpty && !out.contains(t)) out.add(t);
    }

    add(box.path);
    add(box.name);
    add(dbFolder?.name);
    // Only add encoded forms if they are plain ASCII names (e.g. INBOX),
    // never mUTF-7 (contains '&').
    final enc = box.encodedPath.trim();
    if (enc.isNotEmpty && !enc.contains('&')) add(enc);
    return out;
  }

  Future<GenericImapResult> _uidMoveOrCopyTo(
    MessageSequence sequence,
    Mailbox targetBox, {
    Folder? dbFolder,
  }) async {
    final candidates = _moveTargetPathCandidates(targetBox, dbFolder);
    Object? lastError;
    for (final path in candidates) {
      try {
        if (client.serverInfo.supportsMove) {
          final result =
              await client.uidMove(sequence, targetMailboxPath: path);
          // ignore: avoid_print
          print('UID MOVE ok targetMailboxPath="$path"');
          return result;
        }
        final result =
            await client.uidCopy(sequence, targetMailboxPath: path);
        await client.uidStore(
          sequence,
          [MessageFlags.deleted],
          action: StoreAction.add,
          silent: true,
        );
        await _expungeUid(sequence);
        // ignore: avoid_print
        print('UID COPY+delete ok targetMailboxPath="$path"');
        return result;
      } catch (e) {
        lastError = e;
        // ignore: avoid_print
        print('MOVE/COPY try path="$path" failed: $e');
      }
    }
    throw lastError ??
        StateError('MOVE/COPY failed for ${targetBox.name}; no path worked');
  }

  /// MOVE (or COPY+delete) [message] into the folder with [targetRole].
  /// Returns the local target folder id and new UID when known.
  Future<({int folderId, String? uid})> moveRemoteMessageToRole(
    Message message,
    String targetRole,
  ) =>
      _serialized(() async {
        final uidStr = message.uid;
        final folderId = message.folderId;
        if (uidStr == null || folderId == null) {
          throw StateError(
            'Message ${message.id} has no IMAP uid/folder; cannot move remotely',
          );
        }

        final folder = await db.folderDao.findById(folderId);
        if (folder == null || folder.path.trim().isEmpty) {
          throw StateError('Folder $folderId missing for message ${message.id}');
        }

        final targetFolder =
            await db.folderDao.findByRole(account.id, targetRole);
        if (targetFolder == null) {
          throw StateError('No $targetRole folder for account ${account.id}');
        }
        if (folder.role == targetRole || folder.id == targetFolder.id) {
          return (folderId: targetFolder.id, uid: uidStr);
        }

        final uid = int.tryParse(uidStr);
        if (uid == null) {
          throw StateError('Invalid IMAP uid "$uidStr"');
        }

        await connect();
        await _selectFolder(folder);

        final sequence = MessageSequence.fromId(uid, isUid: true);
        final targetBox = await _findMailboxByRole(targetRole);
        if (targetBox == null) {
          throw StateError('IMAP $targetRole mailbox not found');
        }

        final result = await _uidMoveOrCopyTo(
          sequence,
          targetBox,
          dbFolder: targetFolder,
        );

        final newIds = result.responseCodeCopyUid?.targetSequence.toList();
        final newUid =
            (newIds != null && newIds.isNotEmpty) ? newIds.first.toString() : null;
        // ignore: avoid_print
        print(
          'IMAP moved uid=$uid → ${targetBox.path} newUid=$newUid',
        );
        return (folderId: targetFolder.id, uid: newUid ?? uidStr);
      });

  /// Delete on the IMAP server via enough_mail [ImapClient].
  /// Prefer MOVE to Trash (Outlook-friendly); otherwise \Deleted + EXPUNGE.
  Future<void> deleteRemoteMessage(Message message) => _serialized(() async {
        final uidStr = message.uid;
        final folderId = message.folderId;
        if (uidStr == null || folderId == null) {
          throw StateError(
            'Message ${message.id} has no IMAP uid/folder; cannot delete remotely',
          );
        }

        final folder = await db.folderDao.findById(folderId);
        if (folder == null || folder.path.trim().isEmpty) {
          throw StateError('Folder $folderId missing for message ${message.id}');
        }

        final uid = int.tryParse(uidStr);
        if (uid == null) {
          throw StateError('Invalid IMAP uid "$uidStr"');
        }

        await connect();
        await _selectFolder(folder);

        final sequence = MessageSequence.fromId(uid, isUid: true);
        final inTrash = folder.role == 'trash';
        Mailbox? trashBox;
        if (!inTrash) {
          try {
            trashBox = await _findTrashMailbox();
          } catch (e) {
            // ignore: avoid_print
            print('listMailboxes for trash failed: $e');
          }
        }

        if (!inTrash && trashBox != null) {
          try {
            final trashFolder =
                await db.folderDao.findByRole(account.id, 'trash');
            await _uidMoveOrCopyTo(
              sequence,
              trashBox,
              dbFolder: trashFolder,
            );
            // ignore: avoid_print
            print(
              'IMAP deleted uid=$uid via MOVE/COPY to ${trashBox.path}',
            );
            return;
          } catch (e) {
            // ignore: avoid_print
            print('IMAP move to trash failed, trying flag+expunge: $e');
          }
        }

        await client.uidStore(
          sequence,
          [MessageFlags.deleted],
          action: StoreAction.add,
          silent: true,
        );
        await _expungeUid(sequence);
        // ignore: avoid_print
        print('IMAP deleted uid=$uid via \\Deleted+EXPUNGE in ${folder.path}');
      });

  /// Flag+EXPUNGE a single UID in [folderId] (used when replacing a draft APPEND).
  Future<void> expungeRemoteUid(int folderId, String uidStr) =>
      _serialized(() async {
        final folder = await db.folderDao.findById(folderId);
        if (folder == null || folder.path.trim().isEmpty) return;
        final uid = int.tryParse(uidStr);
        if (uid == null) return;
        await connect();
        await _selectFolder(folder);
        final sequence = MessageSequence.fromId(uid, isUid: true);
        await client.uidStore(
          sequence,
          [MessageFlags.deleted],
          action: StoreAction.add,
          silent: true,
        );
        await _expungeUid(sequence);
      });

  /// Store IMAP flags (`\Seen`, `\Flagged`) for a local message that has uid.
  Future<void> setRemoteFlags(
    Message message, {
    bool? seen,
    bool? flagged,
  }) =>
      _serialized(() async {
        if (seen == null && flagged == null) return;
        final uidStr = message.uid;
        final folderId = message.folderId;
        if (uidStr == null || folderId == null) return;

        final folder = await db.folderDao.findById(folderId);
        if (folder == null || folder.path.trim().isEmpty) return;

        final uid = int.tryParse(uidStr);
        if (uid == null) return;

        await connect();
        await _selectFolder(folder);
        final sequence = MessageSequence.fromId(uid, isUid: true);

        Future<void> store(List<String> flags, StoreAction action) async {
          if (flags.isEmpty) return;
          await client.uidStore(
            sequence,
            flags,
            action: action,
            silent: true,
          );
        }

        if (seen != null) {
          await store(
            [MessageFlags.seen],
            seen ? StoreAction.add : StoreAction.remove,
          );
        }
        if (flagged != null) {
          await store(
            [MessageFlags.flagged],
            flagged ? StoreAction.add : StoreAction.remove,
          );
        }
      });

  Future<void> _expungeUid(MessageSequence sequence) async {
    try {
      await client.uidExpunge(sequence);
    } catch (e) {
      // ignore: avoid_print
      print('uidExpunge failed ($e), falling back to EXPUNGE');
      await client.expunge();
    }
  }
}
