import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';
import 'package:intl/intl.dart';

part 'time_mark_theme.dart';
part 'time_scale_theme.dart';

/// Wrapper for the Timeline view customization parameters
class TimelineTheme extends Equatable {
  /// Customize the Timeline with the parameters
  const TimelineTheme({
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.cellExtent = 15,
    this.timeScaleTheme = const TimeScaleTheme(),
  }) : assert(
          cellExtent >= 1 && cellExtent <= 60,
          'cellExtent must be between 1m and 60m',
        );

  /// [SliverPadding] of the scrollable view
  final EdgeInsets padding;

  /// In minutes, is used to render and position events on the timeline
  final int cellExtent;

  /// Customization parameters of the time scale
  final TimeScaleTheme timeScaleTheme;

  @override
  List<Object?> get props => [
        padding,
        cellExtent,
        timeScaleTheme,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  TimelineTheme copyWith({
    EdgeInsets? padding,
    TimeScaleTheme? timeScaleTheme,
    int? cellExtent,
  }) {
    return TimelineTheme(
      padding: padding ?? this.padding,
      cellExtent: cellExtent ?? this.cellExtent,
      timeScaleTheme: timeScaleTheme ?? this.timeScaleTheme,
    );
  }
}
