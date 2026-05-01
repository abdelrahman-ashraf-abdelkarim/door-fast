import 'dart:math';

import 'package:captain_app/core/app_navigation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const _ordersPayload = 'orders';
  static const _scheduledOrderNotificationStartId = 10000;
  static const _scheduledOrderNotificationsCount = 12;
  static int _notificationId = 0;
  static bool _mockOrderNotificationsScheduled = false;

  /// تهيئة الإشعارات
  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationPayload(response.payload);
      },
    );

    final launchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _handleNotificationPayload(launchDetails?.notificationResponse?.payload);
    }

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// عرض إشعار فوري
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'orders_channel',
          'New Orders',
          channelDescription: 'Notifications for new delivery orders',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      _notificationId++,
      title,
      "",
      notificationDetails,
      payload: _ordersPayload,
    );
  }

  static Future<void> scheduleMockOrderNotifications() async {
    if (_mockOrderNotificationsScheduled) return;
    _mockOrderNotificationsScheduled = true;

    const androidDetails = AndroidNotificationDetails(
      'scheduled_orders_channel',
      'Scheduled Mock Orders',
      channelDescription: 'Scheduled mock notifications for new orders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);
    final random = Random();
    var nextDelay = Duration.zero;

    for (var index = 0; index < _scheduledOrderNotificationsCount; index++) {
      await _flutterLocalNotificationsPlugin.cancel(
        _scheduledOrderNotificationStartId + index,
      );
    }

    for (var index = 0; index < _scheduledOrderNotificationsCount; index++) {
      nextDelay += Duration(seconds: 5 + random.nextInt(6));

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _scheduledOrderNotificationStartId + index,
        'طلب جديد 🚚',
        'طلب جديد في انتظار القبول',
        tz.TZDateTime.now(tz.local).add(nextDelay),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: _ordersPayload,
      );
    }
  }

  static void _handleNotificationPayload(String? payload) {
    if (payload == _ordersPayload) {
      openOrdersScreen();
    }
  }
}
