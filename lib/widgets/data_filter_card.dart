import 'package:flutter/material.dart';

class DateFilterCard extends StatefulWidget {
  const DateFilterCard({
    super.key,
    this.onFilter,
  });

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
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: pickToDate,
                child: _dateField(format(toDate)),
              ),
            ),
          ],
        ),
        if (widget.onFilter != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onFilter!(fromDate, toDate),
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text(
                    'بحث',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (fromDate != null || toDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                    });
                    widget.onFilter!(null, null);
                  },
                  icon: const Icon(Icons.close, color: Colors.grey),
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
