// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;

// class Api {
//   Future<dynamic> get({required String url, @required String? token}) async {
//     Map<String, String> headers = {};

//     if (token != null) {
//       headers.addAll({'Authorization': 'Bearer $token'});
//     }

//      print('📤 Request URL: $url');
//   print('📤 Headers: $headers');
//     http.Response response = await http.get(Uri.parse(url), headers: headers);

//     print('📥 Status Code: ${response.statusCode}');
//   print('📥 Response Body: ${response.body}');

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception(
//         'there is a problem with status code ${response.statusCode}',
//       );
//     }
//   }

//   Future<dynamic> post({
//     required String url,
//     @required dynamic body,
//     @required String? token,
//   }) async {
//     Map<String, String> headers = {};

//     if (token != null) {
//       headers.addAll({'Authorization': 'Bearer $token'});
//     }
//     http.Response response = await http.post(
//       Uri.parse(url),
//       body: body,
//       headers: headers,
//     );
//     if (response.statusCode == 200) {
//       Map<String, dynamic> data = jsonDecode(response.body);

//       return data;
//     } else {
//       throw Exception(
//         'there is a problem with status code ${response.statusCode} with body ${jsonDecode(response.body)}',
//       );
//     }
//   }

//   Future<dynamic> put({
//     required String url,
//     @required dynamic body,
//     @required String? token,
//   }) async {
//     Map<String, String> headers = {};
//     headers.addAll({'Content-Type': 'application/x-www-form-urlencoded'});
//     if (token != null) {
//       headers.addAll({'Authorization': 'Bearer $token'});
//     }

//     // print('url = $url body = $body token = $token ');
//     http.Response response = await http.put(
//       Uri.parse(url),
//       body: body,
//       headers: headers,
//     );
//     if (response.statusCode == 200) {
//       Map<String, dynamic> data = jsonDecode(response.body);
//       // print(data);
//       return data;
//     } else {
//       throw Exception(
//         'there is a problem with status code ${response.statusCode} with body ${jsonDecode(response.body)}',
//       );
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:captain_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:captain_app/cubits/auth_cubit/auth_state.dart';

class Api {
  late final Dio _dio;

  Api(AuthCubit authCubit) {
    _dio = Dio();
    _dio.interceptors.add(TokenInterceptor(authCubit));
  }

  // ─── GET ────────────────────────────────────────────────────────────────────
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

  // ─── POST ───────────────────────────────────────────────────────────────────
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

  // ─── PUT ────────────────────────────────────────────────────────────────────
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
    // أضف التوكن الحالي تلقائياً في كل request
    final state = authCubit.state;
    if (state is AuthAuthenticated) {
      options.headers['Authorization'] = 'Bearer ${state.token}';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // لو السيرفر بعت توكن جديد في الـ header → حدّثه تلقائياً
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ✅ لو السيرفر رجّع 401 → التوكن انتهى صلاحيته أو اتحذف
    // → اعمل logout تلقائي وودّي المستخدم لشاشة Login
    if (err.response?.statusCode == 401) {
      authCubit.logout();
    }
    handler.next(err);
  }
}
