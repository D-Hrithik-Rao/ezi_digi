import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // Create channel on Android
    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'payment_channel_v4',
        'Payment Notifications',
        description: 'Payment success alerts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    _initialized = true;
    debugPrint('NotificationService: init complete');
  }

  static Future<bool> _ensurePermission() async {
    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Check if already granted — areNotificationsEnabled is reliable on all API levels
      final alreadyEnabled = await androidPlugin.areNotificationsEnabled();
      debugPrint('NotificationService: areNotificationsEnabled=$alreadyEnabled');

      if (alreadyEnabled == true) return true;

      // Not granted yet — request it
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('NotificationService: requestNotificationsPermission=$granted');
      return granted == true;
    }

    // iOS
    final iosPlugin =
    _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted == true;
    }

    return true; // other platforms assume ok
  }

  static Future<void> showPaymentNotification({
    required String title,
    required String body,
  }) async {
    await init();

    final permitted = await _ensurePermission();
    debugPrint('NotificationService: permitted=$permitted');

    if (!permitted) {
      debugPrint('NotificationService: no permission — cannot show notification');
      return;
    }

    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'payment_channel_v4',
            'Payment Notifications',
            channelDescription: 'Payment success alerts',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      debugPrint('NotificationService: shown successfully id=$id');
    } catch (e, st) {
      debugPrint('NotificationService: FAILED — $e\n$st');
    }
  }
}