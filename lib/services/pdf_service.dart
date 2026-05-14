import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  /// 📥 Main entry point
  static Future<File> getInvoicePdf({
    required String orderId,
    required String url,
    required String token,
  }) async {
    return _downloadInvoicePdf(url: url, orderId: orderId, token: token);
  }

  // ==========================
  // 🌐 REAL MODE (API)
  // ==========================
  static Future<File> _downloadInvoicePdf({
    required String url,
    required String orderId,
    required String token,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final invoicesDir = Directory("${dir.path}/invoices");

    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }

    final filePath = "${invoicesDir.path}/invoice_$orderId.pdf";
    final file = File(filePath);

    // ✅ cache
    if (await file.exists()) return file;

    final response = await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': 'application/pdf',
        'Authorization': 'Bearer $token'
        },
      ),
    );

    final contentType = response.headers.value('content-type');

    // ❌ مش PDF
    if (contentType == null || !contentType.contains('pdf')) {
      throw Exception("السيرفر لم يرجع PDF");
    }

    // ❌ ملف فاضي أو غلط
    if (response.data.length < 100) {
      throw Exception("الملف غير صالح");
    }

    await file.writeAsBytes(response.data);

    return file;
  }
}
