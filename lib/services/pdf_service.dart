import 'dart:io';
import 'package:captain_app/core/constants.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  /// 📥 Main entry point
  static Future<File> getInvoicePdf({
    required String orderNumber,
    required String url,
    required String token,
  }) async {
    return _downloadInvoicePdf(
      url: url,
      orderNumber: orderNumber,
      token: token,
    );
  }

  // ==========================
  // 🌐 REAL MODE (API)
  // ==========================
  static Future<File> _downloadInvoicePdf({
    required String url,
    required String orderNumber,
    required String token,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final invoicesDir = Directory("${dir.path}/invoices");

    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }

    // final filePath = "${invoicesDir.path}/invoice_$orderId.pdf";
    final filePath = "${invoicesDir.path}/$orderNumber.pdf";
    final file = File(filePath);

    // [FIX-21] check cache validity - invalidate files older than 30 minutes
    if (await file.exists()) {
      final lastModified = await file.lastModified();
      final age = DateTime.now().difference(lastModified);

      if (age.inMinutes < AppConstants.pdfCacheValidityMinutes) {
        return file;
      }

      await file.delete();
    }

    final response = await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'application/pdf',
          'Authorization': 'Bearer $token',
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
