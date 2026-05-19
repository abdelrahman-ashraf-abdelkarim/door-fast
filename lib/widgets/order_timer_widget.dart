import 'dart:async';

import 'package:captain_app/models/order_model.dart';
import 'package:captain_app/services/tick_service.dart';
import 'package:flutter/material.dart';

class OrderTimerWidget extends StatefulWidget {
  const OrderTimerWidget({super.key, required this.order, this.style});

  final Order order;
  final TextStyle? style;

  @override
  State<OrderTimerWidget> createState() => _OrderTimerWidgetState();
}

class _OrderTimerWidgetState extends State<OrderTimerWidget> {
  late StreamSubscription<int> _subscription;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _duration = widget.order.activeDuration;
    // [FIX-19] subscribe to shared stream instead of creating new Timer
    _subscription = TickService.tickStream.listen((_) {
      if (mounted) {
        setState(() => _duration = widget.order.activeDuration);
      }
    });
  }

  @override
  void didUpdateWidget(covariant OrderTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order) {
      _duration = widget.order.activeDuration;
    }
  }

  @override
  void dispose() {
    _subscription.cancel(); // [FIX-19] cancel subscription on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_formatDuration(_duration), style: widget.style);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    final second = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours < 1) {
      return '$minutes:$second'; // يمكنك تعديل النص حسب الحاجة، مثلاً "5 دقائق" أو "1 دقيقة"
    }
    return '${hours.toString().padLeft(2, '0')}:$minutes:$second';
  }
}
