import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _full = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _short = DateFormat('dd MMM yyyy');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _monthDay = DateFormat('MMM d');

  static String full(DateTime dateTime) => _full.format(dateTime);

  static String short(DateTime dateTime) => _short.format(dateTime);

  static String relative(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(date).inDays;
    final time = _time.format(dateTime);
    if (diff == 0) return 'Today, $time';
    if (diff == 1) return 'Yesterday, $time';
    return '${_monthDay.format(dateTime)}, $time';
  }
}
