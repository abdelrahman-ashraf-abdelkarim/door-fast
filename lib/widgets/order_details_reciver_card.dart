import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderDetailsReciverCard extends StatelessWidget {
  const OrderDetailsReciverCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.person_2_sharp, color: Colors.blueGrey, size: 24.r),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                order.receiverName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 24.r),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                order.receiverAddress,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
