import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';

class OrderTimerWidget extends StatelessWidget {
  const OrderTimerWidget({super.key, required this.order, this.style});

  final Order order;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(minutes: 1), (tick) => tick),
      builder: (context, snapshot) {
        return Text(_formatDuration(order.activeDuration), style: style);
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString();
    return '$minutes دقيقة'; // يمكنك تعديل النص حسب الحاجة، مثلاً "5 دقائق" أو "1 دقيقة"
  }
}
