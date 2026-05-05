import 'dart:convert';
import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/auth_model.dart';
import 'package:http/http.dart' as http;

Future<AuthResponse> login(String username, String password) async {
  final response = await http.post(
    Uri.parse('${AppConstants.baseUrl}/login'),
    body: {
      'username': username,
      'password': password,
    },
  );
  if (response.statusCode == 200) {
    return AuthResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('فشل تسجيل الدخول');
  }
}