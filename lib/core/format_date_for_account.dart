import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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

  final egyptTime = _toCairoTime(date);

  final month = months[egyptTime.month];
  final time = DateFormat('hh:mm a').format(egyptTime);

  return '${egyptTime.day} $month ${egyptTime.year} . $time';
}

({String day, String month, String yearAndHour}) formatDateParts(
  DateTime date,
) {
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

  final egyptTime = _toCairoTime(date);

  return (
    day: egyptTime.day.toString(),
    month: months[egyptTime.month],
    yearAndHour:
        '${egyptTime.year} . ${DateFormat('hh:mm a').format(egyptTime)}',
  );
}

DateTime _toCairoTime(DateTime date) {
  // [FIX-07] Egypt timezone EET = UTC+2
  tz_data.initializeTimeZones();
  final cairo = tz.getLocation('Africa/Cairo');
  return tz.TZDateTime.from(date.toUtc(), cairo);
}
