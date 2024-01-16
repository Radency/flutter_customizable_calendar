import 'package:flutter/cupertino.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class CustomMonthViewEventsListBuilder<T extends FloatingCalendarEvent> {
  const CustomMonthViewEventsListBuilder({
    required this.builder,
    required this.event,
  });

  final Widget Function(BuildContext) builder;
  final T event;
}
