import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowModelSheetBottomWidget extends StatelessWidget {
  const ShowModelSheetBottomWidget({super.key, this.contact});

  Future<void> _callPhone({required String phone}) async {
    final url = Uri.parse('tel:$phone');
    await launchUrl(url);
  }

  Future<void> _openWhatsApp({
    required String phone,
    String message = '',
  }) async {
    final whatsappUrl = Uri.parse(
      'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}',
    );

    final webUrl = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  final OrderContact? contact;
  String get contactPhone => contact?.phoneOne ?? '';
  String get contactPhoneTwo => contact?.phoneTwo ?? '';
  bool get canCall => contactPhone.isNotEmpty;
  bool get canCallTwo => contactPhoneTwo.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "بيانات التواصل",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff25D366),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _callPhone(phone: contactPhone),
              icon: const Icon(
                Icons.call,
                color: Colors.white,
                size: 24,
                fontWeight: FontWeight.w900,
              ),
              label: Text(
                contactPhone,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff25D366),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                _openWhatsApp(
                  phone: "2$contactPhone",
                  message: 'السلام عليكم، معاك مندوب التوصيل',
                );
              },
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.white,
                size: 24,
                fontWeight: FontWeight.w900,
              ),
              label: const Text(
                "تواصل واتساب",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          if (canCallTwo) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff128C7E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _callPhone(phone: contactPhoneTwo),
                icon: const Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 24,
                  fontWeight: FontWeight.w900,
                ),
                label: Text(
                  contactPhoneTwo,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff128C7E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  _openWhatsApp(
                    phone: "2$contactPhoneTwo",
                    message: 'السلام عليكم، معاك مندوب التوصيل',
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 24,
                  fontWeight: FontWeight.w900,
                ),
                label: const Text(
                  "تواصل واتساب",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          // call phone two Button
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
