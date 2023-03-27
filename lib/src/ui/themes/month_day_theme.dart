import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Wrapper for the DaysList view customization parameters
class MonthDayTheme extends Equatable {
  /// Customize the DaysList with the parameters
  const MonthDayTheme({
    this.dayColor,
    this.currentDayColor,
    this.dayNumberBackgroundColor = Colors.transparent,
    this.currentDayNumberBackgroundColor = Colors.blue,
    this.dayNumberTextStyle = const TextStyle(),
    this.currentDayNumberTextStyle = const TextStyle(),
  });

  /// The color of day card
  final Color? dayColor;

  /// The color of current day card
  final Color? currentDayColor;

  /// The background color of day number
  final Color dayNumberBackgroundColor;

  /// The background color of current day number
  final Color currentDayNumberBackgroundColor;

  /// The TextStyle of day number
  final TextStyle dayNumberTextStyle;

  /// The TextStyle of current day number
  final TextStyle currentDayNumberTextStyle;

  @override
  List<Object?> get props => [
    dayColor,
    currentDayColor,
    dayNumberBackgroundColor,
    currentDayNumberBackgroundColor,
    dayNumberTextStyle,
    currentDayNumberTextStyle,
  ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  MonthDayTheme copyWith({
    Color? dayColor,
    Color? currentDayColor,
    Color? dayNumberBackgroundColor,
    Color? currentDayNumberBackgroundColor,
    TextStyle? dayNumberTextStyle,
    TextStyle? currentDayNumberTextStyle,
  }) {
    return MonthDayTheme(
      dayColor: dayColor ?? this.dayColor,
      currentDayColor: currentDayColor ?? this.currentDayColor,
      dayNumberBackgroundColor: dayNumberBackgroundColor ?? this.dayNumberBackgroundColor,
      currentDayNumberBackgroundColor: currentDayNumberBackgroundColor ?? this.currentDayNumberBackgroundColor,
      dayNumberTextStyle: dayNumberTextStyle ?? this.dayNumberTextStyle,
      currentDayNumberTextStyle: currentDayNumberTextStyle ?? this.currentDayNumberTextStyle,
    );
  }
}
