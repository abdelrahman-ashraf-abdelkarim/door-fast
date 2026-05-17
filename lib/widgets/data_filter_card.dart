import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DateFilterCard extends StatefulWidget {
  const DateFilterCard({super.key, this.onFilter});

  final void Function(DateTime? from, DateTime? to)? onFilter;

  @override
  State<DateFilterCard> createState() => _DateFilterCardState();
}

class _DateFilterCardState extends State<DateFilterCard> {
  DateTime? fromDate;
  DateTime? toDate;

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked;
        if (toDate != null && toDate!.isBefore(picked)) {
          toDate = picked;
        }
      });
    }
  }

  Future<void> pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  String format(DateTime? date) {
    if (date == null) return "dd/mm/yyyy";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: pickFromDate,
                child: _dateField(format(fromDate)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: pickToDate,
                child: _dateField(format(toDate)),
              ),
            ),
          ],
        ),
        if (widget.onFilter != null) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onFilter!(fromDate, toDate),
                  icon: Icon(Icons.search, color: Colors.white),
                  label: Text(
                    'بحث',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              if (fromDate != null || toDate != null) ...[
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: () {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                    });
                    widget.onFilter!(null, null);
                  },
                  icon: Icon(Icons.close, color: Colors.grey),
                  tooltip: 'مسح الفلتر',
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _dateField(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
