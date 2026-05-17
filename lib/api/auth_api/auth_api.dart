import 'dart:convert';
import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/auth_model.dart';
import 'package:http/http.dart' as http;

Future<AuthResponse> login(
  String username,
  String password,
  DeliveryType role,
) async {
  final loginUrl = '${AppConstants.getBaseUrl(role)}/login';
  final response = await http.post(
    Uri.parse(loginUrl),
    body: {'username': username, 'password': password},
  );
  if (response.statusCode == 200) {
    return AuthResponse.fromJson(jsonDecode(response.body), role: role);
  } else {
    final errorData = jsonDecode(response.body);
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
    await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );
  } catch (_) {
  }
}

Future<bool> validateToken(String authToken, DeliveryType role) async {
  try {
    final url = '${AppConstants.getBaseUrl(role)}/shift/times';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
