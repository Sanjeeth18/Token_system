import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../error/app_exception.dart';

/// Utility functions for meal date and scheduling calculations.
///
/// The mess operates on the following schedule:
/// - Non-veg available on Sunday, Wednesday, Friday
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

  /// Checks if non-veg is served on the given meal date (available every day).
  static bool isNonVegAvailable(DateTime date) => true;

  /// Checks if today is a Non-Veg purchase day (available every day).
  static bool isNonVegPurchaseDay([DateTime? now]) => true;

  /// Checks if the student purchase window is open (after 6:00 AM each day).
  static bool isStudentPurchaseWindowOpen([DateTime? now]) {
    final target = now ?? DateTime.now();
    return target.hour >= 6;
  }

  /// Checks if a manager is allowed to update Veg token counts (only until 6:00 AM).
  static bool canManagerUpdateVeg([DateTime? now]) {
    final target = now ?? DateTime.now();
    return target.hour < 6;
  }

  /// Checks if a manager is allowed to update Non-Veg token counts (only until 6:00 AM).
  static bool canManagerUpdateNonVeg([DateTime? now]) {
    final target = now ?? DateTime.now();
    return target.hour < 6;
  }

  /// Parses a Date of Joining string in ISO, dd-MM-yyyy, or year format.
  static DateTime? parseDojDate(String dojStr) {
    final str = dojStr.trim();
    final iso = DateTime.tryParse(str);
    if (iso != null) return iso;

    final parts = str.split(RegExp(r'[-/.]'));
    if (parts.length == 3) {
      final first = int.tryParse(parts[0]);
      final second = int.tryParse(parts[1]);
      final third = int.tryParse(parts[2]);
      if (first != null && second != null && third != null) {
        if (third > 1000) {
          return DateTime(third, second, first);
        } else if (first > 1000) {
          return DateTime(first, second, third);
        }
      }
    } else if (parts.length == 1) {
      final year = int.tryParse(parts[0]);
      if (year != null && year > 1000) {
        return DateTime(year, 1, 1);
      }
    }
    return null;
  }

  /// Validates a student's Date of Joining (DOJ) based on their course.
  static void validateStudentDoj(Map<String, dynamic> studentData) {
    final dojStr = studentData['doj'] as String?;
    final course = (studentData['course'] ?? studentData['department']) as String? ?? '';

    if (dojStr == null || dojStr.trim().isEmpty) return;

    final dojDate = parseDojDate(dojStr);
    if (dojDate == null) return;

    final now = DateTime.now();
    final maxYears = AppConstants.getMaxDojYearsForCourse(course);

    final maxAllowedDate = DateTime(
      dojDate.year + maxYears,
      dojDate.month,
      dojDate.day,
      23,
      59,
      59,
    );

    if (now.isAfter(maxAllowedDate)) {
      throw StudentValidationException(
        'Student Date of Joining (DOJ) exceeds the allowed limit of $maxYears years for ${course.isNotEmpty ? course : "this course"}.',
      );
    }
  }
}
