import 'package:enough_mail/enough_mail.dart';

import '../db/app_database.dart';
import 'imap_sync_service.dart';

/// Handles EXISTS / FETCH driven incremental sync for a mailbox.
class ImapDeltaSync {
  ImapDeltaSync(this.sync);

  final ImapSyncService sync;

  Future<void> onMailboxChanged(Mailbox mailbox) =>
      sync.syncMailboxDelta(mailbox);
}

/// Handles FLAG updates and EXPUNGE (soft-delete locally).
class ImapFlagDeltaSync {
  ImapFlagDeltaSync(this.sync);

  final ImapSyncService sync;
  AppDatabase get db => sync.db;

  Future<void> onFetchFlags(Mailbox mailbox) async {
    await sync.syncMailboxDelta(mailbox);
  }

  Future<void> onExpunge(Mailbox mailbox) async {
    final folder =
        await db.folderDao.findByPath(sync.account.id, mailbox.encodedPath);
    if (folder == null) return;
    // Soft approach: re-sync recent headers/flags; missing UIDs stay until
    // a later full window sync marks them — EXPUNGE alone lacks UID in
    // classic IMAP, so we refresh the folder window.
    await sync.syncFolderMessages(folder, limit: 50);
  }
}
