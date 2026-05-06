// import 'dart:math';

// import 'package:captain_app/core/app_navigation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin
//   _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   static const _ordersPayload = 'orders';
//   static const _scheduledOrderNotificationStartId = 10000;
//   static const _scheduledOrderNotificationsCount = 12;
//   static int _notificationId = 0;
//   static bool _mockOrderNotificationsScheduled = false;

//   /// تهيئة الإشعارات
//   static Future<void> init() async {
//     tz.initializeTimeZones();
//     tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     const initSettings = InitializationSettings(android: androidSettings);

//     await _flutterLocalNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (response) {
//         _handleNotificationPayload(response.payload);
//       },
//     );

//     final launchDetails = await _flutterLocalNotificationsPlugin
//         .getNotificationAppLaunchDetails();
//     if (launchDetails?.didNotificationLaunchApp ?? false) {
//       _handleNotificationPayload(launchDetails?.notificationResponse?.payload);
//     }

//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.requestNotificationsPermission();
//   }

//   /// عرض إشعار فوري
//   static Future<void> showNotification({required String title}) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//           'orders_channel',
//           'New Orders',
//           channelDescription: 'Notifications for new delivery orders',
//           importance: Importance.max,
//           priority: Priority.high,
//           showWhen: true,
//         );

//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       _notificationId++,
//       title,
//       "",
//       notificationDetails,
//       payload: _ordersPayload,
//     );
//   }

//   static Future<void> scheduleMockOrderNotifications() async {
//     if (_mockOrderNotificationsScheduled) return;
//     _mockOrderNotificationsScheduled = true;

//     const androidDetails = AndroidNotificationDetails(
//       'scheduled_orders_channel',
//       'Scheduled Mock Orders',
//       channelDescription: 'Scheduled mock notifications for new orders',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const notificationDetails = NotificationDetails(android: androidDetails);
//     final random = Random();
//     final location = tz.getLocation('Africa/Cairo');
//     final now = tz.TZDateTime.now(location);

//     Duration nextDelay = Duration.zero;

//     // for (var index = 0; index < _scheduledOrderNotificationsCount; index++) {
//     //   await _flutterLocalNotificationsPlugin.cancel(
//     //     _scheduledOrderNotificationStartId + index,
//     //   );
//     // }

//     for (var index = 0; index < _scheduledOrderNotificationsCount; index++) {
//       nextDelay += Duration(seconds: 5 + random.nextInt(6));

//       final scheduledDate = tz.TZDateTime.now(location).add(nextDelay);

//       await _flutterLocalNotificationsPlugin.zonedSchedule(
//         _scheduledOrderNotificationStartId + index,
//         'طلب جديد 🚚',
//         'طلب جديد في انتظار القبول',
//         scheduledDate,
//         notificationDetails,
//         androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         payload: _ordersPayload,
//       );
//     }
//   }

//   static void _handleNotificationPayload(String? payload) {
//     if (payload == _ordersPayload) {
//       openOrdersScreen();
//     }
//   }
// }

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
  static bool _isInitialized = false;
  static bool _mockOrderNotificationsScheduled = false;

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
    const androidDetails = AndroidNotificationDetails(
      'orders_channel',
      'New Orders',
      channelDescription: 'Notifications for new delivery orders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      _notificationId++,
      title,
      body ?? '',
      details,
      payload: _ordersPayload,
    );
  }

  /// ================= SCHEDULE =================
  static Future<void> scheduleMockOrderNotifications() async {
    if (!_isInitialized) {
      await init(); // 🔥 حماية
    }

    if (_mockOrderNotificationsScheduled) return;
    _mockOrderNotificationsScheduled = true;

    const androidDetails = AndroidNotificationDetails(
      'scheduled_orders_channel',
      'Scheduled Orders',
      channelDescription: 'Scheduled notifications for new orders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    final random = Random();
    final location = tz.getLocation('Africa/Cairo');

    Duration nextDelay = Duration.zero;

    for (int i = 0; i < _scheduledOrderNotificationsCount; i++) {
      nextDelay += Duration(seconds: 5 + random.nextInt(6));

      final scheduledDate = tz.TZDateTime.now(location).add(nextDelay);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _scheduledOrderNotificationStartId + i,
        'طلب جديد 🚚',
        'طلب جديد في انتظار القبول',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: _ordersPayload,
      );
    }
  }

  /// ================= CANCEL =================
  static Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    _mockOrderNotificationsScheduled = false;
  }

  /// ================= HANDLER =================
  static void _handleNotificationPayload(String? payload) {
    if (payload == _ordersPayload) {
      openOrdersScreen();
    }
  }
}
