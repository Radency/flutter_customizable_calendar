import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

String _defaultWeekdayFormatter(DateTime dayDate) =>
    DateFormat.E().format(dayDate).capitalized();

String _defaultNumberFormatter(DateTime dayDate) =>
    DateFormat.d().format(dayDate);

/// Wrapper for the days row customization parameters
class DaysRowTheme extends Equatable {
  /// Customize the days row with the parameters
  const DaysRowTheme({
    this.height = 40,
    this.hideWeekday = false,
    this.weekdayFormatter = _defaultWeekdayFormatter,
    this.weekdayStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    this.hideNumber = false,
    this.numberFormatter = _defaultNumberFormatter,
    this.numberStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  });

  /// The row height
  final double height;

  /// Whether weekday is need to show
  final bool hideWeekday;

  /// Weekday string formatter
  final DateFormatter weekdayFormatter;

  /// Weekday text style
  final TextStyle weekdayStyle;

  /// Whether number is need to show
  final bool hideNumber;

  /// Number string formatter
  final DateFormatter numberFormatter;

  /// Number text style
  final TextStyle numberStyle;

  @override
  List<Object?> get props => [
        height,
        hideWeekday,
        weekdayFormatter,
        weekdayStyle,
        hideNumber,
        numberFormatter,
        numberStyle,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  DaysRowTheme copyWith({
    double? height,
    bool? hideWeekday,
    DateFormatter? weekdayFormatter,
    TextStyle? weekdayStyle,
    bool? hideNumber,
    DateFormatter? numberFormatter,
    TextStyle? numberStyle,
  }) {
    return DaysRowTheme(
      height: height ?? this.height,
      hideWeekday: hideWeekday ?? this.hideWeekday,
      weekdayFormatter: weekdayFormatter ?? this.weekdayFormatter,
      weekdayStyle: weekdayStyle ?? this.weekdayStyle,
      hideNumber: hideNumber ?? this.hideNumber,
      numberFormatter: numberFormatter ?? this.numberFormatter,
      numberStyle: numberStyle ?? this.numberStyle,
    );
  }
}
