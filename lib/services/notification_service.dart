import 'package:captain_app/core/app_navigation.dart';
import 'package:captain_app/firebase_options.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ─────────────────────────────────────────────────────────────────────────────
// 🔥 Duplicate Detection
// ─────────────────────────────────────────────────────────────────────────────
String? _lastForegroundMessageId;
final Set<String> _handledBackgroundMessages = {};

// ─── Background handler — لازم يكون top-level function ───────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('══════════════════════════════════════');
  debugPrint('🔥 BG HANDLER CALLED');
  debugPrint('🆔 Message ID: ${message.messageId}');
  debugPrint('📦 DATA: ${message.data}');
  debugPrint('🔔 Notification Title: ${message.notification?.title}');
  debugPrint('══════════════════════════════════════');

  final id = message.messageId;

  if (id != null && _handledBackgroundMessages.contains(id)) {
    debugPrint('🚫 DUPLICATE BACKGROUND MESSAGE BLOCKED');
    return;
  }

  if (id != null) {
    _handledBackgroundMessages.add(id);
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.showFcmAsLocal(
    message,
    source: 'BACKGROUND_HANDLER',
  );
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
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

  // ─── init الكاملة (Foreground) ────────────────────────────────────────────
  static Future<void> init() async {
    debugPrint('🚀 NotificationService.init() CALLED');

    if (_isInitialized) {
      debugPrint('⚠️ NotificationService already initialized');
      return;
    }

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
        debugPrint('👆 Notification clicked');
        debugPrint('📦 Payload: ${response.payload}');
        _handlePayload(response.payload);
      },
    );

    debugPrint('✅ Local notification plugin initialized');

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    debugPrint('✅ Notification channel created');

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      debugPrint('🚀 App launched from notification');
      _handlePayload(launchDetails?.notificationResponse?.payload);
    }

    await _initFcm();
  }

  // ─── init المخففة (Background / Terminated isolate) ──────────────────────
  static Future<void> _initForBackground() async {
    debugPrint('🌙 _initForBackground() CALLED');

    if (_isInitialized) {
      debugPrint('⚠️ Background already initialized');
      return;
    }

    _isInitialized = true;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    debugPrint('✅ Background notification plugin initialized');

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    debugPrint('✅ Background notification channel created');
  }

  // ─── FCM Listeners ────────────────────────────────────────────────────────
  static Future<void> _initFcm() async {
    debugPrint('🔥 _initFcm() STARTED');

    final fcm = FirebaseMessaging.instance;

    final settings = await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('🔐 FCM Permission: ${settings.authorizationStatus}');

    await fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    debugPrint('✅ Foreground presentation options configured');

    // ─── Foreground ─────────────────────────────────────────────
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('══════════════════════════════════════');
      debugPrint('📩 FOREGROUND MESSAGE RECEIVED');
      debugPrint('🆔 Message ID: ${message.messageId}');
      debugPrint('📦 DATA: ${message.data}');
      debugPrint('🔔 Notification: ${message.notification?.title}');
      debugPrint('══════════════════════════════════════');

      final id = message.messageId;

      if (id != null && _lastForegroundMessageId == id) {
        debugPrint('🚫 DUPLICATE FOREGROUND MESSAGE BLOCKED');
        return;
      }

      _lastForegroundMessageId = id;

      await showFcmAsLocal(message, source: 'FOREGROUND_LISTENER');
    });

    // ─── Opened App ────────────────────────────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('📲 Notification opened app');
      debugPrint('📦 DATA: ${message.data}');
      _handleData(message.data);
    });

    // ─── Terminated ────────────────────────────────────────────
    final initial = await fcm.getInitialMessage();

    if (initial != null) {
      debugPrint('🚀 App opened from terminated notification');
      debugPrint('📦 DATA: ${initial.data}');

      Future.delayed(const Duration(milliseconds: 500), () {
        _handleData(initial.data);
      });
    }
  }

  static Future<String?> getFcmToken() async {
    for (int i = 0; i < 3; i++) {
      try {
        final token = await FirebaseMessaging.instance.getToken();

        debugPrint('🎯 TRY ${i + 1} FCM TOKEN: $token');

        if (token != null) return token;
      } catch (e) {
        debugPrint('❌ FCM TOKEN ERROR: $e');
      }

      await Future.delayed(const Duration(seconds: 2));
    }

    return null;
  }

  // ─── عرض الـ notification ─────────────────────────────────────────────────
  static Future<void> showNotification({
    required String title,
    String? body,
    bool isDeliveryChosen = false, // ✅ جديد
  }) async {
    debugPrint('══════════════════════════════════════');
    debugPrint('🔔 SHOW LOCAL NOTIFICATION');
    debugPrint('📝 TITLE: $title');
    debugPrint('📝 BODY: $body');
    debugPrint('🎯 IS DELIVERY CHOSEN: $isDeliveryChosen');
    debugPrint('🆔 LOCAL ID: $_notificationId');
    debugPrint('══════════════════════════════════════');

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for new delivery orders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      autoCancel: true,
      // ✅ لو الطلب موجّه يظهر حتى لو الشاشة مقفولة
      fullScreenIntent: isDeliveryChosen,
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
  static Future<void> showFcmAsLocal(
    RemoteMessage message, {
    required String source,
  }) async {
    debugPrint('📨 showFcmAsLocal() FROM: $source');

    await _initForBackground();

    final type = message.data['type'] as String?;
    // ✅ لو الباك اند بعت type == 'assigned_order' يبقى الطلب موجّه
    final isDeliveryChosen = type == 'assigned_order';

    final title =
        message.notification?.title ??
        message.data['title'] as String? ??
        (isDeliveryChosen ? 'الطلب مرسل إليك 🎯' : 'طلب جديد 🛵');

    final body =
        message.notification?.body ?? message.data['body'] as String? ?? '';

    debugPrint('📩 FINAL TITLE: $title');
    debugPrint('📩 FINAL BODY: $body');
    debugPrint('🎯 TYPE: $type | IS DELIVERY CHOSEN: $isDeliveryChosen');

    await showNotification(
      title: title,
      body: body,
      isDeliveryChosen: isDeliveryChosen, // ✅
    );
  }

  static Future<void> cancelAll() async {
    debugPrint('🧹 Cancel all notifications');
    await _plugin.cancelAll();
  }

  static Future<void> requestAllPermissions() async {
    debugPrint('🔋 Requesting battery permissions');

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
    debugPrint('📦 HANDLE PAYLOAD: $payload');

    if (payload == _ordersPayload) {
      debugPrint('📂 Opening orders screen');
      openOrdersScreen();
    }
  }

  static void _handleData(Map<String, dynamic> data) {
    debugPrint('📦 HANDLE DATA: $data');
    debugPrint('📂 Opening orders screen');

    openOrdersScreen();
  }
}
