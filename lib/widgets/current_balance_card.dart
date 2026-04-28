import 'package:captain_app/cubits/order_cubit/order_cubit.dart';
import 'package:flutter/material.dart';

class CurrentBalanceCard extends StatelessWidget {
  const CurrentBalanceCard({super.key, required this.order});

  final OrdersCubit order;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(16),
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB85C00), // غامق
            Color(0xFFFF8C00), // فاتح
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          /// 🔸 الأيقونة الخلفية (شفافة)
          Positioned(
            left: -30,
            top: -5,
            bottom: 0,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.account_balance_wallet,
                size: 160,
                color: Colors.white,
              ),
            ),
          ),

          /// 🔸 النصوص
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "الرصيد الحالي",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${order.totalDeliveryEarnings}",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "ج.م",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
