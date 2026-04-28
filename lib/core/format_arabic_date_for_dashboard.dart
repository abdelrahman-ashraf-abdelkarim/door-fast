import 'package:intl/intl.dart';

String formatArabicDateDashboard(DateTime date) {
  final DateFormat formatter = DateFormat('EEEE، d MMMM', 'ar');
  return formatter.format(date);
}
