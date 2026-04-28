import 'package:captain_app/core/constants.dart';
import 'package:captain_app/core/show_confirmation_dialog.dart';
import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/views/order_details_screen.dart';
import 'package:captain_app/widgets/order_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.itemsCount, required this.order});

  final int itemsCount;
  final Order order;

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
                    onTap: () {
                      if (order.status == OrderStatus.newOrder ||
                          order.status == OrderStatus.waiting) {
                        /// هنا تعديل
                        showConfirmationDialog(
                          context,
                          title: 'تأكيد القبول',
                          message: 'هل تريد قبول هذا الطلب؟',
                          onConfirm: (_) {
                            context.read<OrdersCubit>().updateOrderStatus(
                              order.id,
                              OrderStatus.accepted,
                            );
                            Navigator.pop(context);
                          },
                          gradientColors:
                              AppConstants.acceptButtonGradientColors,
                          buttonText: 'تأكيد القبول',
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailsScreen(order: order),
                          ),
                        );
                      }
                    },
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

class ButtonCard extends StatelessWidget {
  const ButtonCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class OrderContainer extends StatelessWidget {
  const OrderContainer({
    super.key,
    required this.itemsCount,
    required this.order,
  });

  final int itemsCount;
  final Order order;

  @override
  Widget build(BuildContext context) {
    final isCustomerHidden =
        order.status == OrderStatus.waiting ||
        order.status == OrderStatus.newOrder;

    if (isCustomerHidden) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, color: Colors.black54, size: 18),
            SizedBox(width: 8),
            Text(
              'تفاصيل العميل مخفية',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black54,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '$itemsCount صنف داخل الطلب',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OrderItemCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}
