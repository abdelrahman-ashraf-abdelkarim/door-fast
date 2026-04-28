import 'package:flutter/material.dart';

class DateFilterCard extends StatefulWidget {
  const DateFilterCard({super.key});

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
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: pickToDate,
            child: _dateField(format(toDate)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: pickFromDate,
            child: _dateField(format(fromDate)),
          ),
        ),
      ],
    );
  }

  Widget _dateField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
