import 'dart:async';

import '../db/app_database.dart';
import '../sent/sent_reconcile_service.dart';

class SentWorker {
  SentWorker({
    required this.db,
    required this.account,
    required this.reconcile,
    this.runExclusive,
    this.interval = const Duration(minutes: 2),
  });

  final AppDatabase db;
  final Account account;
  final SentReconcileService reconcile;
  final Future<T> Function<T>(Future<T> Function() action)? runExclusive;
  final Duration interval;

  bool _running = false;
  Timer? _timer;

  void start() {
    if (_running) return;
    _running = true;
    unawaited(_safeReconcile());
    _timer = Timer.periodic(interval, (_) {
      unawaited(_safeReconcile());
    });
  }

  Future<void> stop() async {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> kick() => _safeReconcile();

  Future<void> _safeReconcile() async {
    try {
      final exclusive = runExclusive;
      if (exclusive != null) {
        await exclusive(() => reconcile.reconcileRecent());
      } else {
        await reconcile.reconcileRecent();
      }
    } catch (e) {
      // ignore: avoid_print
      print('SentWorker reconcile failed: $e');
    }
  }
}
