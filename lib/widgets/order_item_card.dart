import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderItemCard extends StatelessWidget {
  const OrderItemCard({super.key, required this.item});
  final OrderItem item;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Center(
          child: Text(
            '${item.quantity}x',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.accentOrange,
            ),
          ),
        ),
        SizedBox(width: 18.w),
        Expanded(
          child: Text(
            item.productName,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 18.w),
        Text(
          'ج ${item.totalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
