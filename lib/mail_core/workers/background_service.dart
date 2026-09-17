import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../engine/mail_engine.dart';
import '../notifications/notification_service.dart';

const _periodicSyncUniqueName = 'mgl_mail_sync_task';
const _periodicSyncTaskName = 'sync_all_mail_accounts';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _periodicSyncTaskName &&
        task != Workmanager.iOSBackgroundTask) {
      return true;
    }

    MailEngine? engine;
    try {
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();
      await NotificationService.initialize(requestPermissions: false);

      engine = MailEngine();
      // A headless task only needs a short-lived IMAP client. Starting the
      // regular IDLE, outbox, and sent workers here can race the main isolate.
      await engine.initialize(startWorkers: false);
      await engine.syncAll();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Background fetch failed: $e');
      return false;
    } finally {
      await engine?.dispose();
    }
  });
}

class BackgroundService {
  static Future<void> initialize() {
    return Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> registerPeriodicSync() async {
    // workmanager 0.5.x periodic registration is Android-only. On iOS,
    // initialize() installs the Background Fetch callback; scheduling is
    // controlled by the native Background Modes configuration.
    if (!Platform.isAndroid) return;

    await Workmanager().registerPeriodicTask(
      _periodicSyncUniqueName,
      _periodicSyncTaskName,
      frequency: const Duration(minutes: 30),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
