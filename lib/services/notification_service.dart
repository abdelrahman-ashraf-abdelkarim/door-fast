import 'package:captain_app/core/app_navigation.dart';
import 'package:captain_app/firebase_options.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ─── Background handler — لازم يكون top-level function ───────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '🔥 BG HANDLER CALLED — data: ${message.data}, notification: ${message.notification?.title}',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.showFcmAsLocal(message);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'orders_channel';
  static const _channelName = 'New Orders';
  static const _ordersPayload = 'orders';

  static int _notificationId = 0;
  static bool _isInitialized = false;

  // ─── Channel مستقل يُستخدم في كل مكان ───────────────────────────────────
  static const _androidChannel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: 'Notifications for new delivery orders',
    importance: Importance.max, // ← HIGH PRIORITY
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

  // ─── init الكاملة (Foreground) ────────────────────────────────────────────
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

    // ✅ إنشاء الـ channel صريحاً — ضروري جداً على Android 8+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

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

  // ─── init المخففة (Background / Terminated isolate) ──────────────────────
  static Future<void> _initForBackground() async {
    if (_isInitialized) return;
    _isInitialized = true;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // ✅ لازم يتعمل هنا كمان — الـ background isolate محتاجه
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  // ─── FCM Listeners ────────────────────────────────────────────────────────
  static Future<void> _initFcm() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(alert: true, badge: true, sound: true);

    // ✅ منع FCM من عرض notification تلقائياً (علشان نعرضها بالـ channel بتاعنا)
    await fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    // Foreground
    FirebaseMessaging.onMessage.listen((message) {
      showFcmAsLocal(message);
    });

    // Background (ضغط على notification)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleData(message.data);
    });

    // Terminated (فتح التطبيق من notification)
    final initial = await fcm.getInitialMessage();
    if (initial != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleData(initial.data);
      });
    }
  }

  static Future<String?> getFcmToken() async {
    for (int i = 0; i < 3; i++) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) return token;
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }

  // ─── عرض الـ notification ─────────────────────────────────────────────────
  static Future<void> showNotification({
    required String title,
    String? body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for new delivery orders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      // ✅ fullscreen intent — يصحي الشاشة حتى لو مقفول
      fullScreenIntent: true,
      styleInformation: const DefaultStyleInformation(true, true),
    );

    await _plugin.show(
      _notificationId++,
      '\u200F$title',
      body ?? '',
      NotificationDetails(android: androidDetails),
      payload: _ordersPayload,
    );
  }

  // ─── بيتكال من الـ background handler ────────────────────────────────────
  static Future<void> showFcmAsLocal(RemoteMessage message) async {
    await _initForBackground();
    final title =
        message.notification?.title ??
        message.data['title'] as String? ??
        'طلب جديد';
    final body =
        message.notification?.body ?? message.data['body'] as String? ?? '';
    await showNotification(title: title, body: body);
  }

  static Future<void> cancelAll() async => _plugin.cancelAll();

  static Future<void> requestAllPermissions() async {
    final isBatteryIgnoring =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled;
    if (isBatteryIgnoring != true) {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }
    final isAutoStartEnabled =
        await DisableBatteryOptimization.isAutoStartEnabled;
    if (isAutoStartEnabled != true) {
      await DisableBatteryOptimization.showEnableAutoStartSettings(
        "Enable Auto Start",
        "Please enable auto start to allow notifications and background service to work properly.",
      );
    }
    final isManufacturerIgnoring = await DisableBatteryOptimization
        .isManufacturerBatteryOptimizationDisabled;
    if (isManufacturerIgnoring != true) {
      await DisableBatteryOptimization.showDisableManufacturerBatteryOptimizationSettings(
        "Your device has additional battery optimization that may block notifications.",
        "Please disable it to receive notifications.",
      );
    }
  }

  static void _handlePayload(String? payload) {
    if (payload == _ordersPayload) openOrdersScreen();
  }

  static void _handleData(Map<String, dynamic> data) {
    openOrdersScreen();
  }
}
