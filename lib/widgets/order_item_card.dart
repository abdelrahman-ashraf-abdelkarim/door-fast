import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';

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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.accentOrange,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            item.productName,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Text(
          'ج ${item.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
