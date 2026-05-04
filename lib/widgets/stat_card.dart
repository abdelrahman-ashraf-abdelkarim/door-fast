import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    this.value,
    this.icon,
    this.color,
    this.valueWidget,
  });
  final String title;
  final String? value;
  final Widget? valueWidget;
  final IconData? icon;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (icon != null) Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey)),
            ],
          ),
          valueWidget ??
              Text(
                value ?? "",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black,
                ),
              ),
        ],
      ),
    );
  }
}
