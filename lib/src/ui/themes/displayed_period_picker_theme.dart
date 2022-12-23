import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';
import 'package:intl/intl.dart';

part 'displayed_period_picker_button_theme.dart';

String _defaultPeriodFormatter(DisplayedPeriod period) {
  if (period.end == null) {
    return DateFormat.yMMMM().format(period.begin).capitalized();
  }

  const day = 'd';
  const month = 'MMM';
  const year = 'y';

  final beginPattern = [
    day,
    if (period.begin.month != period.end!.month) ' $month',
    if (period.begin.year != period.end!.year) ', $year',
  ].join();
  const endPattern = '$day $month, $year';

  return [
    DateFormat(beginPattern).format(period.begin),
    DateFormat(endPattern).format(period.end!),
  ].join(' - ');
}

/// Wrapper for the DisplayedPeriodPicker view customization parameters
class DisplayedPeriodPickerTheme extends Equatable {
  /// Customize the DisplayedPeriodPicker with the parameters
  const DisplayedPeriodPickerTheme({
    this.margin = const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 16,
    ),
    this.elevation,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.blue,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    this.width,
    this.height,
    this.periodFormatter = _defaultPeriodFormatter,
    this.textStyle = const TextStyle(fontWeight: FontWeight.w600),
    this.prevButtonTheme = const DisplayedPeriodPickerButtonTheme(
      child: Icon(CupertinoIcons.chevron_left),
    ),
    this.nextButtonTheme = const DisplayedPeriodPickerButtonTheme(
      child: Icon(CupertinoIcons.chevron_right),
    ),
  });

  /// External padding
  final EdgeInsetsGeometry margin;

  /// The z-coordinate at which to place the view
  final double? elevation;

  /// Background color
  final Color backgroundColor;

  /// Foreground color
  final Color foregroundColor;

  /// The view shape and border
  final ShapeBorder shape;

  /// The view width
  final double? width;

  /// The view height
  final double? height;

  /// Specify displayed period formatter
  final PeriodFormatter periodFormatter;

  /// The typographical style to use for text
  final TextStyle textStyle;

  /// Theme of the left button
  final DisplayedPeriodPickerButtonTheme prevButtonTheme;

  /// Theme of the right button
  final DisplayedPeriodPickerButtonTheme nextButtonTheme;

  @override
  List<Object?> get props => [
        margin,
        elevation,
        backgroundColor,
        foregroundColor,
        shape,
        width,
        height,
        periodFormatter,
        textStyle,
        prevButtonTheme,
        nextButtonTheme,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  DisplayedPeriodPickerTheme copyWith({
    EdgeInsetsGeometry? margin,
    double? elevation,
    Color? backgroundColor,
    Color? foregroundColor,
    ShapeBorder? shape,
    double? width,
    double? height,
    PeriodFormatter? periodFormatter,
    TextStyle? textStyle,
    DisplayedPeriodPickerButtonTheme? prevButtonTheme,
    DisplayedPeriodPickerButtonTheme? nextButtonTheme,
  }) {
    return DisplayedPeriodPickerTheme(
      margin: margin ?? this.margin,
      elevation: elevation ?? this.elevation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      shape: shape ?? this.shape,
      width: width ?? this.width,
      height: height ?? this.height,
      periodFormatter: periodFormatter ?? this.periodFormatter,
      textStyle: textStyle ?? this.textStyle,
      prevButtonTheme: prevButtonTheme ?? this.prevButtonTheme,
      nextButtonTheme: nextButtonTheme ?? this.nextButtonTheme,
    );
  }
}
