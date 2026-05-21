import 'package:captain_app/core/app_logger.dart';
import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowModelSheetBottomWidget extends StatelessWidget {
  const ShowModelSheetBottomWidget({super.key, this.contact});

  Future<void> _callPhone({required String phone}) async {
    // [FIX-10] double-check before launching
    if (phone.trim().isEmpty) return;

    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
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

  Future<void> _openMapLink(BuildContext context, String? url) async {
    try {
      if (url == null || url.trim().isEmpty) return;

      final uri = Uri.parse(url);

      // [FIX-11] handle invalid map URL gracefully instead of throwing
      if (!await canLaunchUrl(uri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذّر فتح الخريطة'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      AppLogger.e('MapLink', 'Map launch error', error: error);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء فتح الخريطة')),
        );
      }
    }
  }

  final OrderContact? contact;
  String get contactPhone => contact?.phoneOne ?? '';
  String get contactPhoneTwo => contact?.phoneTwo ?? '';
  String get contactAddress => contact?.linkAddress ?? '';
  bool get canAddress => contactAddress.isNotEmpty;
  bool get canCall => contactPhone.isNotEmpty;
  bool get canCallTwo => contactPhoneTwo.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 50.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            "بيانات التواصل",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10.h),

          if (canCall) ...[
            // [FIX-10] only show call button if phone number exists
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whatsAppGreen,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onPressed: () => _callPhone(phone: contactPhone),
                icon: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 24.r,
                  fontWeight: FontWeight.w900,
                ),
                label: Text(
                  contactPhone,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whatsAppGreen,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onPressed: () {
                _openWhatsApp(
                  phone: "2$contactPhone",
                  message: 'السلام عليكم، معاك مندوب التوصيل',
                );
              },
              icon: FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.white,
                size: 24.r,
                fontWeight: FontWeight.w900,
              ),
              label: Text(
                "تواصل واتساب",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          if (canCallTwo) ...[
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whatsAppDarkGreen,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onPressed: () => _callPhone(phone: contactPhoneTwo),
                icon: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 24.r,
                  fontWeight: FontWeight.w900,
                ),
                label: Text(
                  contactPhoneTwo,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whatsAppDarkGreen,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onPressed: () {
                  _openWhatsApp(
                    phone: "2$contactPhoneTwo",
                    message: 'السلام عليكم، معاك مندوب التوصيل',
                  );
                },
                icon: FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 24.r,
                  fontWeight: FontWeight.w900,
                ),
                label: Text(
                  "تواصل واتساب",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (canAddress) ...[
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mapButtonOrange,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onPressed: () {
                  _openMapLink(context, contactAddress);
                },
                icon: FaIcon(
                  FontAwesomeIcons.mapLocation,
                  color: Colors.white,
                  size: 24.r,
                  fontWeight: FontWeight.w900,
                ),
                label: Text(
                  "موقع العميل",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
