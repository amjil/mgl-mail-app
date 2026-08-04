import 'package:enough_mail/enough_mail.dart';

import 'imap_sync_service.dart';

/// Handles EXISTS / FETCH driven incremental sync for a mailbox.
class ImapDeltaSync {
  ImapDeltaSync(this.sync);

  final ImapSyncService sync;

  Future<void> onMailboxChanged(Mailbox mailbox) =>
      sync.syncMailboxDelta(mailbox);
}

/// Handles FLAG updates.
class ImapFlagDeltaSync {
  ImapFlagDeltaSync(this.sync);

  final ImapSyncService sync;

  Future<void> onFetchFlags(Mailbox mailbox) async {
    await sync.syncMailboxDelta(mailbox);
  }
}
