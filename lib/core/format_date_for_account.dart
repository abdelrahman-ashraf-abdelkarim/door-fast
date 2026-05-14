import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  const months = [
    '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
  final month = months[date.month];
  final time = DateFormat('hh:mm a').format(date);
  return '${date.day} $month ${date.year} . $time';
}