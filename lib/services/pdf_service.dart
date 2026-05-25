import 'dart:io';

import 'package:captain_app/core/constants.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ),
  );

  /// 📥 Main entry point
  static Future<File> getInvoicePdf({
    required String orderNumber,
    required String url,
    required String token,
  }) async {
    final dir = await getApplicationDocumentsDirectory();

    final invoicesDir = Directory("${dir.path}/invoices");

    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }

    final filePath = "${invoicesDir.path}/$orderNumber.pdf";

    final file = File(filePath);

    // ✅ Cache validation
    if (await file.exists()) {
      final lastModified = await file.lastModified();

      final age = DateTime.now().difference(lastModified);

      if (age.inMinutes < AppConstants.pdfCacheValidityMinutes) {
        return file;
      }

      await file.delete();
    }

    DioException? lastError;

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await _dio.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'Accept': 'application/pdf',
              'Authorization': 'Bearer $token',
            },
          ),
        );

        final statusCode = response.statusCode ?? 0;

        // ❌ Auth / Not found errors
        if (statusCode == 401 || statusCode == 403 || statusCode == 404) {
          throw Exception("فشل تحميل الفاتورة ($statusCode)");
        }

        final bytes = response.data;

        // ❌ Empty file
        if (bytes == null || bytes.isEmpty) {
          throw Exception("الملف فارغ");
        }

        // ✅ Verify PDF signature
        final isPdf =
            bytes.length > 4 &&
            bytes[0] == 0x25 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x44 &&
            bytes[3] == 0x46;

        if (!isPdf) {
          throw Exception("الملف ليس PDF صالح");
        }

        await file.writeAsBytes(bytes, flush: true);

        return file;
      } on SocketException {
        if (attempt < 3) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } on DioException catch (e) {
        lastError = e;

        if (attempt < 3) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    throw Exception(
      "فشل تحميل الفاتورة: ${lastError?.message ?? 'خطأ غير معروف'}",
    );
  }
}
  