import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderDetailsItemCard extends StatelessWidget {
  final OrderItem item;

  const OrderDetailsItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final marketColors = _marketPlaceColors(item.marketPlace);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
          ),

          SizedBox(width: 18.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.marketPlace.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: marketColors.background,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      item.marketPlace,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: marketColors.foreground,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],

                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  item.details.isEmpty ? 'بدون تفاصيل إضافية' : item.details,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 18.w),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'ج ${item.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({Color background, Color foreground}) _marketPlaceColors(
    String marketPlace,
  ) {
    final index = marketPlace.trim().isEmpty
        ? 0
        : marketPlace.codeUnits.fold<int>(0, (sum, unit) => sum + unit) %
              AppConstants.marketPalette.length;
    return AppConstants.marketPalette[index];
  }
}
