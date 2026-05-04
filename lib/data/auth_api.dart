import 'dart:convert';
import 'package:captain_app/models/auth_model.dart';
import 'package:http/http.dart' as http;

Future<AuthResponse> login() async {
  final response = await http.post(
    Uri.parse("http://192.168.1.8:8000/api/login"),
    body: {
      "phone": "01055555555",
      "password": "123456",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return AuthResponse.fromJson(data);
  } else {
    throw Exception("Login failed");
  }
}
