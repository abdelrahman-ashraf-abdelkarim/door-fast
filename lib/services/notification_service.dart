import 'package:captain_app/core/app_navigation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ─── Background Handler (لازم يكون TOP-LEVEL function خارج أي class) ──────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase اتعمل init في main.dart قبل ما نيجي هنا
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

  // ─── INIT الرئيسي (بيتنادى من main.dart) ─────────────────────────────────
  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    // 2. Local Notifications init
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handlePayload(response.payload);
      },
    );

    // 3. Permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation
            <AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 4. لو التطبيق اتفتح من local notification وهو terminated
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _handlePayload(launchDetails?.notificationResponse?.payload);
    }

    // 5. FCM Setup
    await _initFcm();
  }

  // ─── FCM Setup ────────────────────────────────────────────────────────────
  static Future<void> _initFcm() async {
    final fcm = FirebaseMessaging.instance;

    // طلب permission
    await fcm.requestPermission(alert: true, badge: true, sound: true);

    // Foreground: FCM مش بيظهر notification لوحده — إحنا بنعمله
    FirebaseMessaging.onMessage.listen((message) {
      _showFcmAsLocal(message);
    });

    // لو التطبيق في الـ background وفتح من الـ notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handlePayload(_ordersPayload);
    });

    // لو التطبيق كان terminated وفتح من الـ notification
    final initial = await fcm.getInitialMessage();
    if (initial != null) {
      // استنى شوية عشان الـ navigator يكون جاهز
      Future.delayed(const Duration(milliseconds: 500), () {
        _handlePayload(_ordersPayload);
      });
    }
  }

  // ─── إرسال FCM Token للـ backend (بيتنادى من AuthCubit بعد اللوجين) ──────
  static Future<String?> getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (_) {
      return null;
    }
  }

  // ─── Show Notification (Local — من WebSocket أو FCM) ─────────────────────
  static Future<void> showNotification({
    required String title,
    String? body,
  }) async {
    if (!_isInitialized) await init();

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
      '\u200F$title',  // RTL marker
      body ?? '',
      const NotificationDetails(android: androidDetails),
      payload: _ordersPayload,
    );
  }

  // ─── داخلي: حول FCM message لـ Local Notification ────────────────────────
  static Future<void> _showFcmAsLocal(RemoteMessage message) async {
    final title = message.notification?.title ?? 'طلب جديد';
    final body = message.notification?.body ?? '';
    await showNotification(title: title, body: body);
  }

  // ─── Cancel ───────────────────────────────────────────────────────────────
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Handle Payload (فتح شاشة الأوردرات) ─────────────────────────────────
  static void _handlePayload(String? payload) {
    if (payload == _ordersPayload) {
      openOrdersScreen();
    }
  }
}