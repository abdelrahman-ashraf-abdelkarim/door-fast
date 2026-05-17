import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TotalOrderSmallDetails extends StatelessWidget {
  const TotalOrderSmallDetails({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xffBAE6FD)),
        color: Color(0xffBAE6FD).withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "الإجمالى المطلوب",
            style: TextStyle(
              color: Color(0xff0369A1),
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "${order.totalPrice.toString()} ج",
            style: TextStyle(
              color: Color(0xff0369A1),
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
