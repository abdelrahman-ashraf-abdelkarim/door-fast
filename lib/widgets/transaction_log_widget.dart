import 'package:captain_app/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionLogWidget extends StatelessWidget {
  const TransactionLogWidget({
    super.key,
    required this.icon,
    required this.foregroundIconColor,
    required this.backgroundIconColor,
    required this.title,
    required this.day,
    required this.month,
    required this.yearAndHour,
    required this.price,
    this.isEntry = true,
  });

  final FaIconData icon;
  final Color foregroundIconColor;
  final Color backgroundIconColor;
  final String title;
  final String day;
  final String month;
  final String yearAndHour;
  final String price;
  final bool isEntry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: backgroundIconColor,
              radius: 32,
              child: FaIcon(icon, color: foregroundIconColor, size: 32),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.w100,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      month,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      yearAndHour,
                      style: const TextStyle(
                        fontWeight: FontWeight.w100,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              price,
              style: TextStyle(
                color: isEntry ? AppColors.primaryTeal : AppColors.accentOrange,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
