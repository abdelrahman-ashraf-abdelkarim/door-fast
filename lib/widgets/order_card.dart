import 'package:captain_app/core/constants.dart';
import 'package:captain_app/core/show_confirmation_dialog.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/views/order_details_screen.dart';
import 'package:captain_app/widgets/order_small_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.itemsCount, required this.order});

  final int itemsCount;
  final Order order;

  bool get _isPendingOrder {
    return order.status == OrderStatus.newOrder ||
        order.status == OrderStatus.waiting;
  }

  void _handleTap(BuildContext context) {
    if (_isPendingOrder) {
      showConfirmationDialog(
        context,
        title: 'تأكيد القبول',
        message: 'هل تريد قبول هذا الطلب؟',
        onConfirm: (_) {
          context.read<OrdersCubit>().updateOrderStatus(
            order.id,
            OrderStatus.accepted,
          );
        },
        gradientColors: AppConstants.acceptButtonGradientColors,
        buttonText: 'تأكيد القبول',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: const Border(
            right: BorderSide(color: Colors.orange, width: 5),
          ),
        ),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'رقم الطلب',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE59E0B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          order.formattedId,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.tealAccent[100],
                      ),
                      child: const Text(
                        'منذ قليل',
                        style: TextStyle(fontSize: 16, color: Colors.teal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OrderContainer(itemsCount: itemsCount, order: order),
                const SizedBox(height: 16),
                if (order.status != OrderStatus.cancelled)
                  GestureDetector(
                    onTap: () => _handleTap(context),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xff00796B),
                            Color(0xff00796B),
                            Color(0xff26A69A),
                          ],
                        ),
                      ),
                      child: ButtonCard(text: _getButtonText(order.status)),
                    ),
                  ),
              ],
            ),
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
      return 'عرض تفاصيل الرحله';
    case OrderStatus.cancelled:
      return 'تم الإلغاء';
  }
}
