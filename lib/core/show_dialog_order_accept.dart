import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/views/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showOrderAcceptedDialog(BuildContext context, Order order, String token) {
  final parentContext = context;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!dialogContext.mounted || !parentContext.mounted) return;

        Navigator.of(dialogContext).pop();
        Navigator.push(
          parentContext,
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(order: order, token: token),
          ),
        );
      });

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            width: 260.w,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 60.r),
                SizedBox(height: 12.h),
                Text(
                  'تم قبول الطلب',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
