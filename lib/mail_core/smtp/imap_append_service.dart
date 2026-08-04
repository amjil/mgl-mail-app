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
    await sync.client.appendMessage(
      message,
      targetMailboxPath: sent.path,
      flags: [MessageFlags.seen],
    );
  }
}
