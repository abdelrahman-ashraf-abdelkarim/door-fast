import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionCard extends StatelessWidget {
  // final int id;
  final int logId;
  final String date;
  final String note;
  final double? debit;
  final double? credit;
  final double balance;

  const TransactionCard({
    super.key,
    // required this.id,
    required this.date,
    required this.note,
    this.debit,
    this.credit,
    required this.balance,
    required this.logId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔸 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$logId",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// 🔸 Note
          Text(
            note,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          ),

          SizedBox(height: 16.h),

          /// 🔸 Divider
          Container(height: 1.h, color: Colors.grey.shade200),

          SizedBox(height: 12.h),

          /// 🔸 Values Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _valueColumn(title: "مدين", value: debit, color: Colors.green),
              _valueColumn(title: "دائن", value: credit, color: Colors.red),
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
        Text(
          title,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 6.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value != null ? value.toStringAsFixed(0) : "—",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
