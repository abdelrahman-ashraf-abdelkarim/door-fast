import 'package:intl/intl.dart';

/// يحوّل الـ DateTime إلى توقيت مصر (UTC+2) ثم يُنسّقه بالعربي
String formatDate(DateTime date) {
  const months = [
    '',
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  final egyptTime = date.toUtc().add(const Duration(hours: 3));

  final month = months[egyptTime.month];
  final time = DateFormat('hh:mm a').format(egyptTime);

  return '${egyptTime.day} $month ${egyptTime.year} . $time';
  
}


({String day, String month, String yearAndHour}) formatDateParts(DateTime date) {
  const months = [
    '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  final egyptTime = date.toUtc().add(const Duration(hours: 3));

  return (
    day: egyptTime.day.toString(),
    month: months[egyptTime.month],
    yearAndHour: '${egyptTime.year} . ${DateFormat('hh:mm a').format(egyptTime)}',
  );
}