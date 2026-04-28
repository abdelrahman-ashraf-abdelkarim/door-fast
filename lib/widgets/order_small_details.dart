import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/widgets/order_item_card.dart';
import 'package:flutter/material.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isCustomerHidden
          ? const Row(
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
            )
          : Column(
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
