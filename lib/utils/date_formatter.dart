// Date formatting helpers used by screens and widgets.
import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static String readableDate(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  static String fullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  static String compactDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String databaseDay(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
