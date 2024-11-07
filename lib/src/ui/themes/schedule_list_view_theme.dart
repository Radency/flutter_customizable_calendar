import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

/// Theme for [ScheduleListView]
class ScheduleListViewTheme {
  /// Creates a theme for the schedule list view
  const ScheduleListViewTheme({
    this.padding = EdgeInsets.zero,
    this.margin = const EdgeInsets.symmetric(
      horizontal: 4,
    ),
    this.firstElementMarginTop = 32,
    this.weekDayTextStyle = const TextStyle(
      fontSize: 14,
    ),
    this.monthDayTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    this.dateBackgroundColor = Colors.transparent,
    this.dateMargin = const EdgeInsets.all(2),
    this.dayPadding = const EdgeInsets.symmetric(vertical: 16),
    this.eventPadding = const EdgeInsets.symmetric(vertical: 4),
  });

  /// Padding of the day
  final EdgeInsets dayPadding;

  /// Padding of the event

  final EdgeInsets eventPadding;

  /// Padding of the list view
  final EdgeInsets padding;

  /// Margin of the list view
  final EdgeInsets margin;

  /// Margin top of the first element
  final double firstElementMarginTop;

  /// Week day text style
  final TextStyle? weekDayTextStyle;

  /// Month day text style
  final TextStyle? monthDayTextStyle;

  /// Date background color
  final Color dateBackgroundColor;

  /// Date margin
  final EdgeInsets dateMargin;
}

/// Enum for the schedule list view displayed date edge mode
enum EScheduleListViewDisplayedDateEdge {
  /// Leading edge
  leading,

  /// Trailing edge
  trailing,
}


