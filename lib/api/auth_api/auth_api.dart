import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/auth_model.dart';
import 'package:dio/dio.dart';

Future<AuthResponse> login(
  String username,
  String password,
  DeliveryType role,
) async {
  final loginUrl = '${AppConstants.getBaseUrl(role)}/login';
  final response = await Dio().post(
    loginUrl,
    data: {'username': username, 'password': password},
    options: Options(validateStatus: (_) => true),
  );
  if (response.statusCode == 200) {
    return AuthResponse.fromJson(
      response.data as Map<String, dynamic>,
      role: role,
    );
  } else {
    final errorData = response.data as Map<String, dynamic>;
    throw Exception(errorData['message'] ?? 'فشل تسجيل الدخول');
  }
}

Future<void> updateFcmToken(
  String authToken,
  String fcmToken,
  DeliveryType role, // ← زود ده
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
  } catch (_) {}
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
    return false;
  }
}
