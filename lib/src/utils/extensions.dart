import 'package:flutter/material.dart';

///
extension CapitalizedString on String {
  /// Returns new [String] which has the first letter in upper case.
  String capitalized() => '${this[0].toUpperCase()}${substring(1)}';
}

///
extension DurationInWeeks on Duration {
  /// The number of entire weeks spanned by this Duration.
  int get inWeeks => inDays ~/ 7;
}

///
extension WeekUtils on DateTime {
  /// Returns all day dates of current week from Monday (1) to Sunday (7).
  DateTimeRange get weekRange => DateTimeRange(
        start: DateUtils.addDaysToDate(this, 1 - weekday),
        end: DateUtils.addDaysToDate(this, 8 - weekday),
      );

  /// Returns result of check whether both dates are in the same week range.
  bool isSameWeekAs(DateTime? other) {
    if (other == null) return false;
    final week = weekRange;
    return !other.isBefore(week.start) && other.isBefore(week.end);
  }
}

///
extension MonthUtils on DateTime {
  /// Returns day dates of 6 weeks which include current month.
  DateTimeRange monthViewRange({bool weekStartsOnSunday = false}) {
    final first = DateUtils.addDaysToDate(
      this,
      1 - day,
    );
    final startDate = DateUtils.addDaysToDate(
      first,
      1 - first.weekday - (weekStartsOnSunday ? 1 : 0),
    );

    /// In case of clock change, set end day to 12:00
    return DateTimeRange(
      start: startDate,
      end:
          DateUtils.addDaysToDate(startDate, 35).add(const Duration(hours: 12)),
    );
  }
}

///
extension DaysList on DateTimeRange {
  /// Returns all days dates between [start] and [end] values.
  List<DateTime> get days => List.generate(
        duration.inDays,
        (index) => DateUtils.addDaysToDate(start, index),
      );
}
