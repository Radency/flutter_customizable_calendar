import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

/// A widget which allows to display a [SimpleAllDayEvent] event
class SimpleAllDayEventView extends StatelessWidget {
  /// Creates a [SimpleAllDayEventView] widget
  const SimpleAllDayEventView(
    this.event, {
    required this.theme,
    required this.viewType,
    super.key,
  });

  /// The [CalendarView] type
  final CalendarView viewType;

  /// The [SimpleAllDayEvent] event to display
  final SimpleAllDayEvent event;

  /// The [ViewEventTheme] theme
  final AllDayEventsTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: theme.eventMargin,
      child: Text(
        event.title,
        overflow: TextOverflow.ellipsis,
        style: theme.textStyle,
        maxLines: _getTextMaxLines(),
      ),
    );
  }

  int? _getTextMaxLines() {
    final difference = event.end.difference(event.start);
    switch (viewType) {
      case CalendarView.days:
        return max(1, difference.inHours * 4);
      case CalendarView.week:
        return max(1, difference.inHours * 4);
      case CalendarView.month:
        return 1;
      case CalendarView.scheduleList:
        return null;
    }
  }
}
