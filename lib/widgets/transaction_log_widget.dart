import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:captain_app/core/constants.dart';
import 'package:flutter/material.dart';

class TransactionLogWidget extends StatelessWidget {
  const TransactionLogWidget({
    super.key,
    required this.icon,
    required this.foregraoundIconColor,
    required this.backgraoundIconColor,
    required this.title,
    required this.day,
    required this.month,
    required this.yearAndHour,
    required this.price,
    this.isEntry =true
  });

  final FaIconData icon;
  final Color foregraoundIconColor;
  final Color backgraoundIconColor;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: backgraoundIconColor,
              radius: 32,
              child: FaIcon(icon, color: foregraoundIconColor, size: 32),
            ),
            const SizedBox(width: 8),
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      month,
                      style: TextStyle(
                        // fontWeight: FontWeight.w100,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      yearAndHour,
                      style: TextStyle(
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
                color: isEntry ?AppColors.primaryTeal : AppColors.accentOrange,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatArabicDateTransaction(DateTime date) {
    final day = DateFormat('d').format(date);
    final month = DateFormat('MMMM', 'ar').format(date);
    final year = DateFormat('yyyy').format(date);

    final hour = (date.hour % 12 == 0 ? 12 : date.hour % 12).toString().padLeft(
      2,
      '0',
    );
    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'م' : 'ص';

    return '$day $month $year . $hour:$minute $period';
  }
}
