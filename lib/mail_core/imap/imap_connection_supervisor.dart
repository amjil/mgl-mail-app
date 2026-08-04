import 'dart:async';
import 'dart:math';

enum SupervisorState {
  disconnected,
  connecting,
  ready,
  idle,
  backoff,
  stopped,
}

/// Owns IMAP connection lifecycle with exponential backoff.
class ImapConnectionSupervisor {
  ImapConnectionSupervisor({
    required this.connect,
    required this.disconnect,
    this.initialBackoff = const Duration(seconds: 5),
    this.maxBackoff = const Duration(seconds: 60),
  });

  final Future<void> Function() connect;
  final Future<void> Function() disconnect;
  final Duration initialBackoff;
  final Duration maxBackoff;

  SupervisorState state = SupervisorState.disconnected;
  int _failures = 0;
  Timer? _backoffTimer;
  bool _wantConnected = false;

  Future<void> start() async {
    _wantConnected = true;
    await _ensureConnected();
  }

  Future<void> stop() async {
    _wantConnected = false;
    _backoffTimer?.cancel();
    state = SupervisorState.stopped;
    try {
      await disconnect();
    } catch (_) {}
    state = SupervisorState.disconnected;
  }

  /// Report an IMAP error so supervisor can reconnect.
  void reportError(Object error) {
    if (!_wantConnected || state == SupervisorState.stopped) return;
    _scheduleReconnect();
  }

  Future<void> enterIdle() async {
    if (state == SupervisorState.ready || state == SupervisorState.idle) {
      state = SupervisorState.idle;
    }
  }

  Future<void> leaveIdle() async {
    if (state == SupervisorState.idle) {
      state = SupervisorState.ready;
    }
  }

  Future<void> _ensureConnected() async {
    if (!_wantConnected) return;
    if (state == SupervisorState.connecting ||
        state == SupervisorState.ready ||
        state == SupervisorState.idle) {
      return;
    }
    state = SupervisorState.connecting;
    try {
      await connect();
      _failures = 0;
      state = SupervisorState.ready;
    } catch (e) {
      state = SupervisorState.disconnected;
      _scheduleReconnect();
      rethrow;
    }
  }

  void _scheduleReconnect() {
    _backoffTimer?.cancel();
    state = SupervisorState.backoff;
    final seconds = min(
      maxBackoff.inSeconds,
      initialBackoff.inSeconds * pow(2, _failures).toInt(),
    );
    _failures++;
    _backoffTimer = Timer(Duration(seconds: seconds), () async {
      if (!_wantConnected) return;
      state = SupervisorState.disconnected;
      try {
        await disconnect();
      } catch (_) {}
      try {
        await _ensureConnected();
      } catch (_) {
        // next backoff already scheduled by _ensureConnected on failure
      }
    });
  }
}
