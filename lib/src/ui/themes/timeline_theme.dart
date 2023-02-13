import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';
import 'package:intl/intl.dart';

part 'draggable_event_theme.dart';
part 'floating_events_theme.dart';
part 'sizer_theme.dart';
part 'time_mark_theme.dart';
part 'time_scale_theme.dart';

/// Wrapper for the Timeline view customization parameters
class TimelineTheme extends Equatable {
  /// Customize the Timeline with the parameters
  const TimelineTheme({
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.cellExtent = 15,
    this.timeScaleTheme = const TimeScaleTheme(),
    this.floatingEventsTheme = const FloatingEventsTheme(),
    this.draggableEventTheme = const DraggableEventTheme(),
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

  /// Customization parameters of all the floating events views
  final FloatingEventsTheme floatingEventsTheme;

  /// Customization parameters of all the draggable event view
  final DraggableEventTheme draggableEventTheme;

  @override
  List<Object?> get props => [
        padding,
        cellExtent,
        timeScaleTheme,
        floatingEventsTheme,
        draggableEventTheme,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  TimelineTheme copyWith({
    EdgeInsets? padding,
    int? cellExtent,
    TimeScaleTheme? timeScaleTheme,
    FloatingEventsTheme? floatingEventsTheme,
    DraggableEventTheme? draggableEventTheme,
  }) {
    return TimelineTheme(
      padding: padding ?? this.padding,
      cellExtent: cellExtent ?? this.cellExtent,
      timeScaleTheme: timeScaleTheme ?? this.timeScaleTheme,
      floatingEventsTheme: floatingEventsTheme ?? this.floatingEventsTheme,
      draggableEventTheme: draggableEventTheme ?? this.draggableEventTheme,
    );
  }
}
