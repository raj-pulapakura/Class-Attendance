import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Returns a list of values
  /// The first item in the list is a DateTime representing the current timestamp
  /// The second item in the list is a String representing the current date (e.g. 5-07-2023)
  static DateTime getCurrentTimeStamp() {
    return DateTime.now();
  }

  static String getDateWithDashes() {
    final now = DateTime.now();
    return "${now.day}-${now.month}-${now.year}";
  }

  static String getDateWithSlashes() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  static String getPrettyDate() {
    final now = DateTime.now();

    return "${DateFormat.EEEE().format(now)}, ${now.day} ${DateFormat.MMMM().format(now)}";
  }
}
