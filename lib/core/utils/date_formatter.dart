import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _full = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _short = DateFormat('dd MMM yyyy');

  static String full(DateTime dateTime) => _full.format(dateTime);

  static String short(DateTime dateTime) => _short.format(dateTime);
}
