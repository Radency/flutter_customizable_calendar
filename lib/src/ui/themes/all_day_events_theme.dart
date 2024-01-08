import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/all_day_events_show_more_button_theme.dart';

/// Theme which allows to customize all day events
class AllDayEventsTheme {
  /// Creates a theme which allows to customize all day events
  const AllDayEventsTheme({
    this.textStyle,
    this.containerPadding = const EdgeInsets.symmetric(
      horizontal: 4,
      vertical: 4,
    ),
    this.eventPadding = const EdgeInsets.symmetric(
      vertical: 2,
    ),
    this.eventMargin = const EdgeInsets.symmetric(
      vertical: 2,
      horizontal: 8,
    ),
    this.borderRadius,
    this.listMaxVisible = 1,
    this.eventHeight = 28,
    this.showMoreButtonTheme = const AllDayEventsShowMoreButtonTheme(),
    this.elevation,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    this.margin = const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  });

  final AllDayEventsShowMoreButtonTheme showMoreButtonTheme;

  /// Max number of events to show
  final int listMaxVisible;

  /// Event height
  final double eventHeight;

  /// Text style of the all day events
  final TextStyle? textStyle;

  /// Padding of container of the all day events
  final EdgeInsets containerPadding;

  /// Padding of the all day events
  final EdgeInsets eventPadding;

  /// Margin of the all day events
  final EdgeInsetsGeometry? eventMargin;

  /// Height of the all day events
  final double? borderRadius;

  /// Elevation over a day view
  final double? elevation;

  /// Shape and border of the views
  final ShapeBorder? shape;

  /// Paddings between the views
  final EdgeInsetsGeometry? margin;

  /// Creates a copy of this theme but with the given fields replaced with the
  AllDayEventsTheme copyWith({
    AllDayEventsShowMoreButtonTheme? showMoreButtonTheme,
    int? listMaxVisible,
    double? eventHeight,
    TextStyle? textStyle,
    EdgeInsets? containerPadding,
    EdgeInsets? eventPadding,
    EdgeInsetsGeometry? eventMargin,
    double? borderRadius,
    double? elevation,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
  }) {
    return AllDayEventsTheme(
      showMoreButtonTheme: showMoreButtonTheme ?? this.showMoreButtonTheme,
      listMaxVisible: listMaxVisible ?? this.listMaxVisible,
      eventHeight: eventHeight ?? this.eventHeight,
      textStyle: textStyle ?? this.textStyle,
      containerPadding: containerPadding ?? this.containerPadding,
      eventPadding: eventPadding ?? this.eventPadding,
      eventMargin: eventMargin ?? this.eventMargin,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
      margin: margin ?? this.margin,
    );
  }
}
