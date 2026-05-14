import 'package:captain_app/core/app_navigation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const _ordersPayload = 'orders';

  static int _notificationId = 0;
  static bool _isInitialized = false;

  /// ================= INIT =================
  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // ✅ timezone setup
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationPayload(response.payload);
      },
    );

    await _flutterLocalNotificationsPlugin.cancelAll();

    // ✅ permission (Android 13+)
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // ✅ لو التطبيق اتفتح من notification
    final details = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp ?? false) {
      _handleNotificationPayload(details?.notificationResponse?.payload);
    }
  }

  /// ================= INSTANT =================
  static Future<void> showNotification({
    required String title,
    String? body,
  }) async {
    if (!_isInitialized) await init();
    const androidDetails = AndroidNotificationDetails(
      'orders_channel',
      'New Orders',
      channelDescription: 'Notifications for new delivery orders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: DefaultStyleInformation(true, true),
    );

    const details = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      _notificationId++,
      '\u200F$title',
      body ?? '',
      details,
      payload: _ordersPayload,
    );
  }

  /// ================= SCHEDULE =================

  /// ================= CANCEL =================
  static Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// ================= HANDLER =================
  static void _handleNotificationPayload(String? payload) {
    if (payload == _ordersPayload) {
      openOrdersScreen();
    }
  }
}
