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
              radius: 24,
              child: FaIcon(icon, color: foregroundIconColor, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4,
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
            ),
            Text(
              price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isEntry ? AppColors.primaryTeal : AppColors.accentOrange,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
