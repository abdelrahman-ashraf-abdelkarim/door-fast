import 'package:captain_app/core/app_logger.dart';
import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/auth_model.dart';
import 'package:dio/dio.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

Future<AuthResponse> login(
  String username,
  String password,
  DeliveryType role,
) async {
  final dio = Dio();
  final baseUrl = AppConstants.getBaseUrl(role);

  // 1. Login
  final loginRes = await dio.post(
    "$baseUrl/login",
    data: {'username': username, 'password': password},
    options: Options(validateStatus: (_) => true),
  );
  if (loginRes.statusCode != 200) {
    final errorData = loginRes.data as Map<String, dynamic>;
    throw AuthException(errorData['message'] ?? 'فشل تسجيل الدخول');
  }

  final token = (loginRes.data as Map<String, dynamic>)['token'] as String;
  final authHeader = Options(headers: {'Authorization': 'Bearer $token'});

  // 2. Shift Status + 3. Shift Times — بالتوازي
  final results = await Future.wait([
    dio.get('$baseUrl/shift/status', options: authHeader),
    dio.get('$baseUrl/shift/times', options: authHeader),
  ]);

  final statusRes = results[0].data as Map<String, dynamic>;
  final timesRes = results[1].data as Map<String, dynamic>;

  return AuthResponse.fromJson({
    'login': loginRes.data,
    'status': statusRes,
    'times': timesRes,
  });
}

Future<void> updateFcmToken(
  String authToken,
  String fcmToken,
  DeliveryType role,
) async {
  try {
    final url = '${AppConstants.getBaseUrl(role)}/fcm-token';
    await Dio().post(
      url,
      data: {'fcm_token': fcmToken},
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  } catch (e) {
    AppLogger.w('AuthApi', 'FCM Token update failed', e);
  }
}

Future<bool> validateToken(String authToken, DeliveryType role) async {
  try {
    final url = '${AppConstants.getBaseUrl(role)}/shift/times';
    final response = await Dio().get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    return response.statusCode == 200;
  } catch (e) {
    AppLogger.w('AuthApi', 'Token validation failed', e);
    return false;
  }
}
