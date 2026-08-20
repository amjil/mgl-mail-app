import 'dart:async';

import 'package:enough_mail/enough_mail.dart';

import '../db/app_database.dart';
import '../imap/imap_connection_supervisor.dart';
import '../imap/imap_delta_sync.dart';
import '../imap/imap_multi_idle_manager.dart';
import '../imap/imap_sync_service.dart';

class ImapWorker {
  ImapWorker({
    required this.db,
    required this.account,
    required this.sync,
  })  : delta = ImapDeltaSync(sync),
        flags = ImapFlagDeltaSync(sync);

  final AppDatabase db;
  final Account account;
  final ImapSyncService sync;
  final ImapDeltaSync delta;
  final ImapFlagDeltaSync flags;

  late final ImapConnectionSupervisor supervisor;
  ImapMultiIdleManager? _idle;
  bool _started = false;
  bool _pollMode = false;
  Timer? _pollTimer;

  /// Serializes connect / sync / idle so SELECT never runs during IDLE.
  Future<void> _gate = Future<void>.value();

  Future<T> _locked<T>(Future<T> Function() action) {
    final done = Completer<void>();
    final result = _gate.catchError((_) {}).then((_) => action());
    _gate = result.then((_) {}, onError: (_) {}).whenComplete(() {
      if (!done.isCompleted) done.complete();
    });
    return result;
  }

  void start() {
    if (_started) return;
    _started = true;
    supervisor = ImapConnectionSupervisor(
      connect: () async {
        await sync.connect();
        await sync.syncAll();
      },
      disconnect: () async {
        await _idle?.stop();
        _idle = null;
        await sync.disconnect();
      },
    );
    unawaited(_boot());
  }

  Future<void> _boot() async {
    try {
      await _locked(() async {
        await supervisor.start();
        if (_started && !_pollMode && sync.isConnected) {
          await _startIdle();
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('ImapWorker boot failed: $e');
      supervisor.reportError(e);
    }
  }

  /// Stop IDLE → sync → restart IDLE. Safe to call while idle is active.
  Future<void> syncNow({int inboxLimit = 50}) =>
      runExclusive(() => sync.syncAll(inboxLimit: inboxLimit));

  /// Run an IMAP action without colliding with IDLE.
  Future<T> runExclusive<T>(Future<T> Function() action) => _locked(() async {
        await _idle?.stop();
        _idle = null;
        try {
          return await action();
        } finally {
          if (_started && !_pollMode && sync.isConnected) {
            await _startIdle();
          }
        }
      });

  Future<void> stop() async {
    _started = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    try {
      await _locked(() async {
        await _idle?.stop();
        _idle = null;
        await supervisor.stop();
      });
    } catch (e) {
      // ignore: avoid_print
      print('ImapWorker.stop failed: $e');
      try {
        await supervisor.stop();
      } catch (_) {}
    }
  }

  Future<void> setPollMode(bool enabled) async {
    if (!_started) return;
    await _locked(() async {
      if (!_started) return;
      _pollMode = enabled;
      if (enabled) {
        await _idle?.stop();
        _idle = null;
        _pollTimer?.cancel();
        _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) {
          unawaited(_safeSync());
        });
      } else {
        _pollTimer?.cancel();
        _pollTimer = null;
        if (_started && sync.isConnected) {
          await _startIdle();
        }
      }
    });
  }

  Future<void> _safeSync() async {
    try {
      await syncNow(inboxLimit: 30);
    } catch (e) {
      supervisor.reportError(e);
    }
  }

  Future<void> _startIdle() async {
    if (!_started || _pollMode || !sync.isConnected) return;
    final folders = <Mailbox>[];
    try {
      final boxes = await sync.client.listMailboxes(recursive: true);
      for (final box in boxes) {
        if (box.isNotSelectable) continue;
        if (box.encodedPath.trim().isEmpty) continue;
        if (box.isInbox || box.isSent) {
          folders.add(box);
        }
      }
      if (folders.isEmpty) {
        for (final b in boxes) {
          if (b.isNotSelectable || b.encodedPath.trim().isEmpty) continue;
          final name = b.name.toLowerCase();
          if (b.isInbox || name == 'inbox') {
            folders.add(b);
            break;
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('ImapWorker list for IDLE failed: $e');
      supervisor.reportError(e);
      return;
    }

    if (!_started || folders.isEmpty) return;

    await _idle?.stop();
    _idle = ImapMultiIdleManager(
      client: sync.client,
      onFolderChanged: (mailbox) async {
        try {
          await supervisor.leaveIdle();
          await delta.onMailboxChanged(mailbox);
          await flags.onFetchFlags(mailbox);
          await supervisor.enterIdle();
        } catch (e) {
          // ignore: avoid_print
          print('ImapWorker IDLE folder change failed: $e');
          supervisor.reportError(e);
        }
      },
    );
    await supervisor.enterIdle();
    await _idle!.start(folders);
  }
}
