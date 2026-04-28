import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final int id;
  final String date;
  final String note;
  final double? debit;
  final double? credit;
  final double balance;

  const TransactionCard({
    super.key,
    required this.id,
    required this.date,
    required this.note,
    this.debit,
    this.credit,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// 🔸 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "#$id",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// 🔸 Note
          Text(
            note,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 16),

          /// 🔸 Divider
          Container(height: 1, color: Colors.grey.shade200),

          const SizedBox(height: 12),

          /// 🔸 Values Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _valueColumn(title: "مدين", value: debit, color: Colors.red),
              _valueColumn(title: "دائن", value: credit, color: Colors.green),
              _valueColumn(title: "رصيد", value: balance, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueColumn({
    required String title,
    required double? value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(
          value != null ? value.toStringAsFixed(0) : "—",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
