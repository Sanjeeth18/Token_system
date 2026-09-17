import 'package:intl/intl.dart';

/// Utility functions for meal date and scheduling calculations.
///
/// The mess operates on the following schedule:
/// - Non-veg available on alternating days (not on weekends/certain days)
/// - Tokens can be purchased for the *next* meal date
abstract class MealDateUtils {
  static final DateFormat _displayFormat = DateFormat("dd-MM-yyyy\n(EEEE)");
  static final DateFormat _shortFormat = DateFormat('dd-MM-yyyy');
  static final DateFormat _dayFormat = DateFormat('EEEE');

  /// Returns the next valid meal date (when the token can first be used).
  /// Skips weekends per the hostel mess schedule.
  ///
  /// Schedule (same logic as original app):
  /// - Mon (1), Wed (3), Sat (6) → next day (+1)
  /// - Tue (2), Fri (5), Sun (7) → +2 days
  /// - Thu (4) → +3 days
  static DateTime nextMealDate() {
    DateTime now = DateTime.now();
    int day = now.weekday; // 1=Mon, 7=Sun
    int daysToAdd = _getDaysToAdd(day);
    return now.add(Duration(days: daysToAdd));
  }

  static int _getDaysToAdd(int weekday) {
    switch (weekday) {
      case DateTime.monday:
      case DateTime.wednesday:
      case DateTime.saturday:
        return 1;
      case DateTime.tuesday:
      case DateTime.friday:
      case DateTime.sunday:
        return 2;
      case DateTime.thursday:
        return 3;
      default:
        return 1;
    }
  }

  /// Returns formatted display string: "dd-MM-yyyy\n(EEEE)"
  static String formatDisplay(DateTime date) => _displayFormat.format(date);

  /// Returns short date string: "dd-MM-yyyy"
  static String formatShort(DateTime date) => _shortFormat.format(date);

  /// Returns day name: "Monday", "Tuesday", etc.
  static String formatDay(DateTime date) => _dayFormat.format(date);

  /// Returns both short date and day name for display.
  static ({String date, String day}) getNextMealInfo() {
    final next = nextMealDate();
    return (date: formatShort(next), day: formatDay(next));
  }

  /// Alias for nextMealDate()
  static DateTime getNextMealDate() => nextMealDate();

  /// Alias for formatShort()
  static String formatDate(DateTime date) => formatShort(date);

  /// Checks if non-veg is served on the given meal date.
  /// Standard hostel schedule serves non-veg on Sundays, Wednesdays, and Fridays.
  static bool isNonVegAvailable(DateTime date) {
    return date.weekday == DateTime.sunday ||
        date.weekday == DateTime.wednesday ||
        date.weekday == DateTime.friday;
  }
}
