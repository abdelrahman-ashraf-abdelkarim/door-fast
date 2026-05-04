// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';

// class PdfService {
//   static Future<File> loadFakePdf(String orderId) async {
//     final dir = await getTemporaryDirectory();
//     final file = File("${dir.path}/invoice_$orderId.pdf");

//     // ✅ cache
//     if (await file.exists()) return file;

//     // 📥 load from assets
//     final data = await rootBundle.load("assets/pdfs/invoice.pdf");

//     await file.writeAsBytes(data.buffer.asUint8List());

//     return file;
//   }

//   static Future<File> downloadInvoicePdf({
//     required String url,
//     required String orderId,
//   }) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final invoicesDir = Directory("${dir.path}/invoices");
//     if (!await invoicesDir.exists()) {
//       await invoicesDir.create(recursive: true);
//     }

//     final filePath = "${invoicesDir.path}/invoice_$orderId.pdf";
//     final file = File(filePath);

//     // Cache by orderId so we don't re-download unnecessarily.
//     if (await file.exists()) return file;

//     // await Dio().download(
//     //   url,
//     //   filePath,
//     //   options: Options(
//     //     // Helps servers that require explicit binary accept.
//     //     headers: const {
//     //       'Accept': 'application/pdf',
//     //     },
//     //     responseType: ResponseType.bytes,
//     //   ),
//     // );
//     final response = await Dio().get(
//       url,
//       options: Options(
//         responseType: ResponseType.bytes,
//         headers: {'Accept': 'application/pdf'},
//       ),
//     );
//     print(response.headers);
//     print("CONTENT TYPE: ${response.headers.value('content-type')}");
//     print("FIRST BYTES: ${response.data.sublist(0, 10)}");

//     final contentType = response.headers.value('content-type');

//     if (contentType == null || !contentType.contains('pdf')) {
//       throw Exception("السيرفر لم يرجع PDF");
//     }

//     await file.writeAsBytes(response.data);

//     return file;
//   }
// }
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  // 🔥 switch بين fake و real
  static bool isFakeMode = true;

  /// 📥 Main entry point
  static Future<File> getInvoicePdf({
    required String orderId,
    String? url,
  }) async {
    if (isFakeMode) {
      return loadFakePdf(orderId);
    } else {
      if (url == null) {
        throw Exception("URL is required in real mode");
      }
      return _downloadInvoicePdf(url: url, orderId: orderId);
    }
  }

  // ==========================
  // 🧪 FAKE MODE (Assets)
  // ==========================
  static Future<File> loadFakePdf(String orderId) async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/invoice_$orderId.pdf");

    // ✅ cache
    if (await file.exists()) return file;

    final data = await rootBundle.load(
      "assets/pdfs/Invoice_ORD-ORD-000105.pdf",
    );

    await file.writeAsBytes(data.buffer.asUint8List());

    return file;
  }

  // ==========================
  // 🌐 REAL MODE (API)
  // ==========================
  static Future<File> _downloadInvoicePdf({
    required String url,
    required String orderId,
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
        headers: {'Accept': 'application/pdf'},
      ),
    );

    // // 🔍 Debug (تشيله بعد ما تتأكد)
    // print("HEADERS: ${response.headers}");
    // print("CONTENT TYPE: ${response.headers.value('content-type')}");
    // print("FIRST BYTES: ${response.data.sublist(0, 10)}");

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
