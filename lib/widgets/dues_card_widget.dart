import 'package:captain_app/core/constants.dart';
import 'package:flutter/material.dart';

class DuesCardWidget extends StatelessWidget {
  const DuesCardWidget({
    super.key,
    required this.title,
    required this.text,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
  });

  final String title;
  final String text;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconForegroundColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: iconBackgroundColor,
                radius: 24,
                child: Icon(
                  icon,
                  fontWeight: FontWeight.bold,
                  color: iconForegroundColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                "$text ج.م",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
