import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';

class OrderDetailsReciverCard extends StatelessWidget {
  const OrderDetailsReciverCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.person_2_sharp, color: Colors.blueGrey, size: 24),
            const SizedBox(width: 8),
            Text(
              order.receiverName,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(
              order.receiverAddress,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
