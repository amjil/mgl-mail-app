import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize({bool requestPermissions = true}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwin = DarwinInitializationSettings(
      requestAlertPermission: requestPermissions,
      requestBadgePermission: requestPermissions,
      requestSoundPermission: requestPermissions,
    );
    final settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
    await _notifications.initialize(settings);
    _initialized = true;

    if (requestPermissions) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> showNewMail(
    int messageId,
    String sender,
    String subject,
  ) async {
    if (!_initialized) return;

    const android = AndroidNotificationDetails(
      'mgl_mail_new_messages',
      'New Messages',
      channelDescription: 'Notifications for newly received mail',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'New Mail',
    );
    const darwin = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _notifications.show(
      messageId,
      sender,
      subject,
      details,
    );
  }
}
