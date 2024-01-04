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
    this.spacingColor,
    this.dayNumberTextStyle = const TextStyle(),
    this.currentDayNumberTextStyle = const TextStyle(),
    this.crossAxisSpacing = 1.0,
    this.mainAxisSpacing = 1.0,
    this.dayNumberPadding,
    this.dayNumberMargin,
    this.dayNumberHeight,
  });

  /// The color of day card
  final Color? dayColor;

  /// The color of current day card
  final Color? currentDayColor;

  /// The background color of day number
  final Color dayNumberBackgroundColor;

  /// The background color of current day number
  final Color currentDayNumberBackgroundColor;

  /// The color of spacing between day views
  final Color? spacingColor;

  /// The TextStyle of day number
  final TextStyle dayNumberTextStyle;

  /// The TextStyle of current day number
  final TextStyle currentDayNumberTextStyle;

  /// The cross axis spacing of spacing between day views
  final double crossAxisSpacing;

  /// The main axis spacing of spacing between day views
  final double mainAxisSpacing;

  /// The height of day number container
  final double? dayNumberHeight;

  /// The margin of day number container
  final EdgeInsets? dayNumberMargin;

  /// The padding of day number container
  final EdgeInsets? dayNumberPadding;

  @override
  List<Object?> get props => [
        dayColor,
        currentDayColor,
        dayNumberBackgroundColor,
        currentDayNumberBackgroundColor,
        dayNumberTextStyle,
        currentDayNumberTextStyle,
        spacingColor,
        crossAxisSpacing,
        mainAxisSpacing,
        dayNumberHeight,
        dayNumberMargin,
        dayNumberPadding,
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
    Color? spacingColor,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    double? dayNumberHeight,
    EdgeInsets? dayNumberMargin,
    EdgeInsets? dayNumberPadding,
  }) {
    return MonthDayTheme(
      dayColor: dayColor ?? this.dayColor,
      currentDayColor: currentDayColor ?? this.currentDayColor,
      dayNumberBackgroundColor:
          dayNumberBackgroundColor ?? this.dayNumberBackgroundColor,
      currentDayNumberBackgroundColor: currentDayNumberBackgroundColor ??
          this.currentDayNumberBackgroundColor,
      dayNumberTextStyle: dayNumberTextStyle ?? this.dayNumberTextStyle,
      currentDayNumberTextStyle:
          currentDayNumberTextStyle ?? this.currentDayNumberTextStyle,
      spacingColor: spacingColor ?? this.spacingColor,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      dayNumberHeight: dayNumberHeight ?? this.dayNumberHeight,
      dayNumberMargin: dayNumberMargin ?? this.dayNumberMargin,
      dayNumberPadding: dayNumberPadding ?? this.dayNumberPadding,
    );
  }
}
