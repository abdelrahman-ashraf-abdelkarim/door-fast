import 'package:captain_app/services/pdf_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  InvoiceCubit() : super(InvoiceInitial());

  Future<void> downloadAndShare({
    required String url,
    required String orderNumber,
    required String token,
    required String customerPhone,
  }) async {
    try {
      emit(InvoiceLoading());

      
      final file = await PdfService.getInvoicePdf(
        orderNumber: orderNumber,
        url: url,
        token: token
      );

      final message = "فاتورة الطلب رقم $orderNumber";

      // Share the PDF file (user can choose WhatsApp, SMS, etc.)
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: message),
      );

      // Best-effort: open WhatsApp chat for the customer's phone number.
      // Note: WhatsApp doesn't allow attaching a file via URL schemes; the actual file share happens above.
      final normalized = _normalizePhoneForWa(customerPhone);
      if (normalized != null) {
        final wa = Uri.parse(
          "https://wa.me/$normalized?text=${Uri.encodeComponent(message)}",
        );
        await launchUrl(wa, mode: LaunchMode.externalApplication);
      }

      emit(InvoiceSuccess());
    } catch (e) {
      emit(InvoiceError("فشل تحميل الفاتورة"));
    }
  }

  String? _normalizePhoneForWa(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return null;
    if (digitsOnly.startsWith('01') && digitsOnly.length == 11) {
      return "2$digitsOnly";
    }
    // keep it as-is and let the backend/team decide format consistency.
    return digitsOnly;
  }
}
