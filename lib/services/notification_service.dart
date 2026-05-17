import 'package:captain_app/core/app_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService._showFcmAsLocal(message);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'orders_channel';
  static const _channelName = 'New Orders';
  static const _ordersPayload = 'orders';

  static int _notificationId = 0;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handlePayload(response.payload);
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _handlePayload(launchDetails?.notificationResponse?.payload);
    }

    await _initFcm();
  }

  static Future<void> _initForBackground() async {
    if (_isInitialized) return;
    _isInitialized = true;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  static Future<void> _initFcm() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(alert: true, badge: true, sound: true);

    // ─── Foreground ───────────────────────────────────────────
    FirebaseMessaging.onMessage.listen((message) {
      _showFcmAsLocal(message);
    });

    // ─── Background (ضغط على الـ notification) ───────────────
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleData(message.data); // ✅ بيعدي order_id
    });

    // ─── Terminated (ضغط على الـ notification وفتح التطبيق) ──
    final initial = await fcm.getInitialMessage();
    if (initial != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleData(initial.data); // ✅ بيعدي order_id
      });
    }
  }

  static Future<String?> getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  static Future<void> showNotification({
    required String title,
    String? body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for new delivery orders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: DefaultStyleInformation(true, true),
    );

    await _plugin.show(
      _notificationId++,
      '\u200F$title',
      body ?? '',
      const NotificationDetails(android: androidDetails),
      payload: _ordersPayload,
    );
  }

  static Future<void> _showFcmAsLocal(RemoteMessage message) async {
    await _initForBackground();
    final title = message.notification?.title ?? 'طلب جديد';
    final body = message.notification?.body ?? '';
    await showNotification(title: title, body: body);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── بيفتح شاشة الأوردرات من الـ local notification payload ──
  static void _handlePayload(String? payload) {
    if (payload == _ordersPayload) {
      openOrdersScreen();
    }
  }

  // ─── بيفتح شاشة الأوردرات من الـ FCM data مع الـ order_id ───
  static void _handleData(Map<String, dynamic> data) {
    openOrdersScreen();
  }
}
