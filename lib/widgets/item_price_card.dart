import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemPriceCard extends StatelessWidget {
  const ItemPriceCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _priceRow(
              label: 'قيمة المنتجات',
              value: 'ج ${order.itemsTotalPrice.toStringAsFixed(2)}',
              color: Colors.grey[700]!,
            ),
            _priceRow(
              label: 'رسوم التوصيل',
              value: 'ج ${order.deliveryPrice.toStringAsFixed(2)}',
              color: Colors.grey[700]!,
            ),
            _priceRow(
              label: 'الخصم',
              value: 'ج ${order.discountValue.toStringAsFixed(2)}',
              color: Colors.grey[700]!,
            ),
            Divider(color: Colors.grey[200]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'ج ${order.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.accentOrange,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
