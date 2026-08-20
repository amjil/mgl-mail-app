import 'dart:async';

import 'package:enough_mail/enough_mail.dart';

typedef FolderChangedCallback = Future<void> Function(Mailbox mailbox);

/// Rotates IDLE across multiple mailboxes on a single IMAP connection.
class ImapMultiIdleManager {
  ImapMultiIdleManager({
    required this.client,
    required this.onFolderChanged,
    this.idleDuration = const Duration(minutes: 4),
    this.switchDelay = const Duration(milliseconds: 300),
  });

  final ImapClient client;
  final FolderChangedCallback onFolderChanged;
  final Duration idleDuration;
  final Duration switchDelay;

  List<Mailbox> _mailboxes = [];
  int _index = 0;
  bool _running = false;
  /// Local mirror of whether we believe IDLE is active. enough_mail's flag is
  /// private; tracking it ourselves avoids noisy "not in IDLE mode" warnings
  /// from duplicate [idleDone] calls.
  bool _inIdle = false;
  StreamSubscription<ImapEvent>? _sub;
  Completer<void>? _wake;
  Future<void>? _loopFuture;
  Future<void>? _stopFuture;
  Future<void>? _inFlightHandler;

  Future<void> start(List<Mailbox> mailboxes) async {
    _mailboxes = mailboxes
        .where((m) =>
            !m.isNotSelectable && m.encodedPath.trim().isNotEmpty)
        .toList();
    if (_mailboxes.isEmpty) return;
    _stopFuture = null;
    _running = true;
    _index = 0;
    _loopFuture = _runLoop();
  }

  /// Exit IDLE immediately and wait until the rotation loop is fully stopped.
  Future<void> stop() async {
    final inFlight = _stopFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }
    final done = Completer<void>();
    _stopFuture = done.future;
    try {
      _running = false;
      _wakeUp();
      await _sub?.cancel();
      _sub = null;
      await _idleDoneIfNeeded();
      // Finish any folder-change handler started before we cancelled the sub.
      final handler = _inFlightHandler;
      if (handler != null) {
        try {
          await handler;
        } catch (_) {}
      }
      final loop = _loopFuture;
      if (loop != null) {
        try {
          await loop;
        } catch (_) {}
        _loopFuture = null;
      }
    } finally {
      done.complete();
    }
  }

  void _wakeUp() {
    final w = _wake;
    if (w != null && !w.isCompleted) {
      w.complete();
    }
  }

  Future<void> _idleDoneIfNeeded() async {
    if (!_inIdle) return;
    _inIdle = false;
    try {
      await client.idleDone();
    } catch (_) {}
  }

  Future<void> _runLoop() async {
    while (_running && _mailboxes.isNotEmpty) {
      final mailbox = _mailboxes[_index % _mailboxes.length];
      _index++;
      try {
        await _idleMailbox(mailbox);
      } catch (e) {
        // ignore: avoid_print
        print('IDLE mailbox ${mailbox.encodedPath} failed: $e');
      }
      if (!_running) break;
      await Future<void>.delayed(switchDelay);
    }
  }

  Future<void> _idleMailbox(Mailbox mailbox) async {
    final path = mailbox.encodedPath.trim();
    if (path.isEmpty) return;
    if (!_running) return;

    await client.selectMailbox(mailbox);
    if (!_running) return;

    final done = Completer<void>();
    final wake = Completer<void>();
    _wake = wake;

    _sub = client.eventBus.on<ImapEvent>().listen((event) {
      final interesting = event is ImapMessagesExistEvent ||
          event is ImapFetchEvent ||
          event is ImapExpungeEvent ||
          event is ImapVanishedEvent;
      if (!interesting) return;
      if (_inFlightHandler != null) return;
      // Handle asynchronously without letting errors escape the event bus.
      _inFlightHandler = () async {
        await _idleDoneIfNeeded();
        try {
          await onFolderChanged(mailbox);
        } catch (e) {
          // ignore: avoid_print
          print('IDLE onFolderChanged failed: $e');
        } finally {
          _inFlightHandler = null;
          if (!done.isCompleted) done.complete();
        }
      }();
    });

    // Mark before idleStart: enough_mail sets its internal flag synchronously
    // when queuing IDLE, and [idleDone] must be allowed immediately after.
    _inIdle = true;
    unawaited(
      client.idleStart().catchError((Object e) {
        // ignore: avoid_print
        print('idleStart failed: $e');
        _inIdle = false;
        if (!done.isCompleted) done.complete();
      }),
    );

    await Future.any([
      done.future,
      wake.future,
      Future<void>.delayed(idleDuration),
    ]);

    await _sub?.cancel();
    _sub = null;
    if (_wake == wake) _wake = null;
    // No-op if the event handler or [stop] already left IDLE.
    await _idleDoneIfNeeded();
  }
}
