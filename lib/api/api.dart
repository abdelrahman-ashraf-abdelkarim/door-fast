import 'dart:convert';
import 'package:captain_app/core/app_logger.dart';
import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Api {
  late final Dio _dio;
  final AuthCubit _authCubit;

  Api(AuthCubit authCubit) : _authCubit = authCubit {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
    // ترتيب الـ interceptors مهم: Token أولاً، ثم Retry
    _dio.interceptors.add(TokenInterceptor(authCubit));
    _dio.interceptors.add(RetryInterceptor(_dio));
  }

  // ─── ✅ baseUrl ديناميكي بناءً على نوع المندوب المسجّل ───────────────────
  String get baseUrl {
    final state = _authCubit.state;
    if (state is AuthAuthenticated) {
      return AppConstants.getBaseUrl(state.user.role);
    }
    // Fallback للـ delivery لو مفيش حد مسجّل دخول
    return AppConstants.deliveryBaseUrl;
  }

  /// رابط الفاتورة (مشتق من baseUrl الديناميكي)
  String invoiceUrl(String orderId) => '$baseUrl/orders/$orderId/invoice';

  // ─── GET ─────────────────────────────────────────────────────────────────
  Future<dynamic> get({required String url, @required String? token}) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(headers: _buildHeaders(token)),
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // ─── POST ────────────────────────────────────────────────────────────────
  Future<dynamic> post({
    required String url,
    @required dynamic body,
    @required String? token,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(headers: _buildHeaders(token)),
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // ─── PUT ─────────────────────────────────────────────────────────────────
  Future<dynamic> put({
    required String url,
    @required dynamic body,
    @required String? token,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            ..._buildHeaders(token),
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  Map<String, String> _buildHeaders(String? token) {
    if (token != null) return {'Authorization': 'Bearer $token'};
    return {};
  }

  Never _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final body = e.response?.data;

    // [FIX-15] log full details internally, show safe message to users
    AppLogger.e('Api', 'HTTP Error — status: $statusCode | body: $body');

    final apiMessage = statusCode == 400 || statusCode == 422
        ? _extractUserMessage(body)
        : null;
    if (apiMessage != null) {
      throw ApiException(apiMessage, statusCode: statusCode);
    }

    switch (statusCode) {
      case 401:
        throw ApiException(
          'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.',
          statusCode: statusCode,
        );
      case 403:
        throw ApiException(
          'ليس لديك صلاحية للقيام بهذه العملية.',
          statusCode: statusCode,
        );
      case 404:
        throw ApiException(
          'البيانات المطلوبة غير موجودة.',
          statusCode: statusCode,
        );
      case 422:
        throw ApiException(
          'البيانات المُدخلة غير صحيحة، يرجى المراجعة.',
          statusCode: statusCode,
        );
      case 500:
      case 502:
      case 503:
        throw ApiException(
          'حدث خطأ في الخادم، يرجى المحاولة لاحقاً.',
          statusCode: statusCode,
        );
      default:
        throw ApiException(
          'حدث خطأ في الاتصال، يرجى المحاولة مجدداً.',
          statusCode: statusCode,
        );
    }
  }

  String? _extractUserMessage(dynamic body) {
    try {
      final decoded = body is String ? jsonDecode(body) : body;
      if (decoded is! Map) return null;

      final message = decoded['message']?.toString().trim();
      if (message == null || message.isEmpty) return null;

      return message;
    } catch (_) {
      return null;
    }
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);

  final Dio _dio;

  static const int _maxRetries = 3;

  // الـ status codes اللي بنعمل عليها retry
  static const Set<int> _retryableStatusCodes = {500, 502, 503};

  // الـ HTTP methods اللي بنعمل عليها retry (GET بس افتراضياً)
  static const Set<String> _retryableMethods = {'GET'};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;

    // جيب العداد الحالي من الـ options (0 لو أول مرة)
    final attempt = (options.extra['_retryCount'] as int?) ?? 0;

    final shouldRetry = attempt < _maxRetries && _isRetryable(err, options);

    if (!shouldRetry) {
      return handler.next(err);
    }

    // حفظ العداد الجديد في الـ extra map
    options.extra['_retryCount'] = attempt + 1;

    // Exponential backoff: 1s, 2s, 4s
    final delay = Duration(seconds: 1 << attempt);
    AppLogger.d(
      'RetryInterceptor',
      'attempt ${attempt + 1}/$_maxRetries — '
      'retrying in ${delay.inSeconds}s → ${options.method} ${options.path}',
    );

    await Future<void>.delayed(delay);

    try {
      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  bool _isRetryable(DioException err, RequestOptions options) {
    // بس الـ methods المسموح بيها
    if (!_retryableMethods.contains(options.method.toUpperCase())) {
      return false;
    }

    // Network errors (timeout, no connection, …)
    if (err.response == null) return true;

    // Server errors المؤقتة
    final statusCode = err.response!.statusCode ?? 0;
    return _retryableStatusCodes.contains(statusCode);
  }
}

// ─── Token Interceptor ───────────────────────────────────────────────────────
class TokenInterceptor extends Interceptor {
  final AuthCubit authCubit;

  TokenInterceptor(this.authCubit);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final state = authCubit.state;
    if (state is AuthAuthenticated) {
      options.headers['Authorization'] = 'Bearer ${state.token}';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      authCubit.logout();
    }
    handler.next(err);
  }
}
