import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/app_version_model.dart';
import 'package:dio/dio.dart';

class AppVersionService {
  final Dio _dio;

  AppVersionService({Dio? dio}) : _dio = dio ?? Dio();

  Future<AppVersionModel> checkVersion() async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/app/version');
      return AppVersionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception(
        'there is a problem with status code $statusCode with body $body',
      );
    } catch (e) {
      throw Exception('there is a problem checking app version: $e');
    }
  }
}
