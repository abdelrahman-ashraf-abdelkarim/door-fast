import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';

class TotalOrderSmallDetails extends StatelessWidget {
  const TotalOrderSmallDetails({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffBAE6FD)),
        color: Color(0xffBAE6FD).withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "الإجمالى المطلوب",
            style: TextStyle(
              color: Color(0xff0369A1),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "${order.totalPrice.toString()} ج",
            style: TextStyle(
              color: Color(0xff0369A1),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
