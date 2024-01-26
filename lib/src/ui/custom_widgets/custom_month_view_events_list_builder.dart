import 'package:flutter/cupertino.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

/// A widget which allows to display a [FloatingCalendarEvent] event
class CustomMonthViewEventsListBuilder<T extends FloatingCalendarEvent> {
  /// Creates a [CustomMonthViewEventsListBuilder] builder
  const CustomMonthViewEventsListBuilder({
    required this.builder,
    required this.event,
  });

  /// The builder function
  final Widget Function(BuildContext) builder;

  /// The [FloatingCalendarEvent] event to display
  final T event;
}
