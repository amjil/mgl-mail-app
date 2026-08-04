import 'package:enough_mail/enough_mail.dart';

import '../db/app_database.dart';
import '../imap/imap_sync_service.dart';

/// Best-effort APPEND to server Sent after SMTP success.
class ImapAppendService {
  ImapAppendService(this.sync);

  final ImapSyncService sync;
  AppDatabase get db => sync.db;

  Future<void> appendToSent(MimeMessage message) async {
    final sent = await db.folderDao.findSent(sync.account.id);
    if (sent == null) return;
    await sync.connect();
    // Unicode name so enough_mail encodes once (DB path is often mUTF-7).
    await sync.client.appendMessage(
      message,
      targetMailboxPath: sent.name,
      flags: [MessageFlags.seen],
    );
  }

  /// APPEND to Drafts with `\Draft` (+ `\Seen`). Returns new UID when APPENDUID
  /// is available; null if no drafts folder or UID unknown.
  ///
  /// Pass Unicode `path`/`name` as targetMailboxPath — enough_mail re-encodes
  /// `Mailbox.encodedPath` (mUTF-7 → `&-...`) which breaks CN ISP servers.
  Future<String?> appendToDrafts(MimeMessage message) async {
    final drafts =
        await db.folderDao.findByRole(sync.account.id, 'draft');
    if (drafts == null) return null;
    await sync.connect();
    final box = await sync.findMailboxForRole('draft');
    final pathCandidates = <String>[];
    void add(String? p) {
      final t = p?.trim() ?? '';
      if (t.isNotEmpty && !pathCandidates.contains(t)) pathCandidates.add(t);
    }

    add(box?.path);
    add(box?.name);
    add(drafts.name);

    Object? lastError;
    for (final path in pathCandidates) {
      try {
        final result = await sync.client.appendMessage(
          message,
          targetMailboxPath: path,
          flags: [MessageFlags.draft, MessageFlags.seen],
        );
        final ids = result.responseCodeAppendUid?.targetSequence.toList();
        if (ids == null || ids.isEmpty) return null;
        return ids.first.toString();
      } catch (e) {
        lastError = e;
        // ignore: avoid_print
        print('APPEND draft try path="$path" failed: $e');
      }
    }
    if (lastError != null) throw lastError;
    return null;
  }
}
