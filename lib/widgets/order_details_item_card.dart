import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';

class OrderDetailsItemCard extends StatelessWidget {
  final OrderItem item;

  const OrderDetailsItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final marketColors = _marketPlaceColors(item.marketPlace);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.marketPlace.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: marketColors.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.marketPlace,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: marketColors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  item.details.isEmpty ? 'بدون تفاصيل إضافية' : item.details,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
      ),
    );
  }

  ({Color background, Color foreground}) _marketPlaceColors(
    String marketPlace,
  ) {
    final index = marketPlace.trim().isEmpty
        ? 0
        : marketPlace.codeUnits.fold<int>(0, (sum, unit) => sum + unit) %
              AppConstants.marketPalette.length;
    return AppConstants.marketPalette[index];
  }
}
