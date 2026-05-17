import 'package:captain_app/core/constants.dart';
import 'package:captain_app/core/show_confirmation_dialog.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/views/order_details_screen.dart';
import 'package:captain_app/widgets/order_timer_widget.dart';
import 'package:captain_app/widgets/order_small_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.itemsCount,
    required this.order,
    required this.token,
  });

  final int itemsCount;
  final Order order;
  final String token;

  bool get _isPendingOrder {
    return order.status == OrderStatus.newOrder ||
        order.status == OrderStatus.waiting;
  }

  bool get _isDeliveredOrder {
    return order.status == OrderStatus.delivered;
  }

  void _handleTap(BuildContext context) {
    if (_isPendingOrder) {
      showConfirmationDialog(
        context,
        title: 'تأكيد القبول',
        message: 'هل أنت متأكد من قبول هذا الطلب؟',
        onConfirm: (_) {
          context.read<OrdersCubit>().acceptOrder(
            order.id,
            token,
          ); // إغلاق الديالوج
        },
        colorContainer: AppColors.buttonOrderDialog,
        buttonText: 'تأكيد القبول',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order, token: token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "#${order.orderNumber}",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.pickupMarkerOrange,
                    ),
                  ),
                  if (!_isDeliveredOrder)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        // color: Colors.tealAccent[100],
                      ),
                      child: OrderTimerWidget(
                        order: order,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),

              Divider(
                color: Colors.grey.withValues(alpha: 0.2),
                thickness: 1,
                indent: 16.w,
                endIndent: 16.w,
              ),

              OrderContainer(order: order),
              SizedBox(height: 8.h),
              if (order.status != OrderStatus.cancelled)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: GestureDetector(
                    onTap: () => _handleTap(context),
                    child: Container(
                      width: double.infinity,
                      height: 48.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: Color.fromARGB(255, 13, 155, 108),
                      ),
                      child: ButtonCard(text: _getButtonText(order.status)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _getButtonText(OrderStatus status) {
  switch (status) {
    case OrderStatus.newOrder:
      return 'قبول الطلب';
    case OrderStatus.waiting:
      return 'قبول الطلب';
    case OrderStatus.accepted:
      return 'تفاصيل الطلب';
    case OrderStatus.delivered:
      return '📋 عرض تفاصيل الطلب';
    case OrderStatus.cancelled:
      return 'تم الإلغاء';
  }
}
