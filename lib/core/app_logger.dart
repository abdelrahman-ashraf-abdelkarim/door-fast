import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    // في release mode نرفع الـ level لـ warning فأعلى بس
    level: kDebugMode ? Level.debug : Level.warning,
    printer: PrettyPrinter(
      methodCount: 1, // سطر واحد من الـ stack trace في debug
      errorMethodCount: 8, // أكتر تفصيل عند الـ errors
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // ── Public API ────────────────────────────────────────────────────────────

  /// معلومات تفصيلية للـ development (مش بتظهر في release)
  static void d(String tag, String message) => _logger.d('[$tag] $message');

  /// أحداث عادية (login، navigation، …)
  static void i(String tag, String message) => _logger.i('[$tag] $message');

  /// حاجات محتاج تاخد بالك منها بس مش error
  static void w(String tag, String message, [Object? error]) =>
      _logger.w('[$tag] $message', error: error);

  /// errors حقيقية — بتظهر في debug وفي release
  static void e(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => _logger.e('[$tag] $message', error: error, stackTrace: stackTrace);
}
