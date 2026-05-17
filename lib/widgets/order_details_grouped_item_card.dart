import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderDetailsGroupedItemCard extends StatelessWidget {
  final String marketPlace;
  final List<OrderItem> items;

  const OrderDetailsGroupedItemCard({
    super.key,
    required this.marketPlace,
    required this.items,
  });

  ({Color background, Color foreground}) get _marketColors {
    final index = marketPlace.trim().isEmpty
        ? 0
        : marketPlace.codeUnits.fold<int>(0, (sum, u) => sum + u) %
              AppConstants.marketPalette.length;
    return AppConstants.marketPalette[index];
  }

  double get _groupTotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    final colors = _marketColors;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header المحل ──
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 16.r,
                        color: colors.foreground,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        marketPlace,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: colors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'ج ${_groupTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: colors.foreground,
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            child: Divider(color: Colors.grey.shade200, height: 1.h),
          ),

          // ── Items ──
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 4.h),
                  child: Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}x',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (item.details.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                item.details,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'ج ${item.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Divider(color: Colors.grey.shade100, height: 1.h),
                  ),
              ],
            );
          }),

          SizedBox(height: 14.h),
        ],
      ),
    );
  }
}
