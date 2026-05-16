import 'package:captain_app/core/constants.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Api {
  late final Dio _dio;
  final AuthCubit _authCubit;

  Api(AuthCubit authCubit) : _authCubit = authCubit {
    _dio = Dio();
    _dio.interceptors.add(TokenInterceptor(authCubit));
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
    throw Exception(
      'there is a problem with status code $statusCode with body $body',
    );
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