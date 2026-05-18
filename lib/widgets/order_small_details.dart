import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/widgets/order_details_reciver_card.dart';
import 'package:captain_app/widgets/total_order_small_details.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderContainer extends StatelessWidget {
  const OrderContainer({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final bool isSender = order.isPersonToPerson && order.sender != null
        ? true
        : false;
    final isCustomerHidden =
        order.status == OrderStatus.waiting ||
        order.status == OrderStatus.newOrder;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        // color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: isCustomerHidden
          ? Center(
              child: Icon(Icons.lock, color: Colors.black54, size: 28.r),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                isSender
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.blueGrey.withValues(alpha: 0.1),
                          ),
                          color: Colors.blueGrey.withValues(alpha: 0.05),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "العميل",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_2_sharp,
                                  color: Colors.blueGrey,
                                  size: 24.r,
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    order.senderName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 24.r,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    order.senderAddress,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Roboto",
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Center(
                              child: Icon(
                                Icons.arrow_downward_sharp,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),

                            DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                color: AppColors.successText,
                                strokeWidth: 1,
                                strokeCap: StrokeCap.round,
                                padding: EdgeInsets.all(0),
                                dashPattern: [4, 3], // ----
                                radius: Radius.circular(8.r),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: AppColors.successLight.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "المستلم",
                                      style: TextStyle(
                                        color: AppColors.successGreen,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 24.r,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            order.receiverAddress,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w800,
                                              fontFamily: "Roboto",
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : OrderDetailsReciverCard(order: order),
                SizedBox(height: 16.h),
                TotalOrderSmallDetails(order: order),
              ],
            ),
    );
  }
}

class ButtonCard extends StatelessWidget {
  const ButtonCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 18.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
