import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class SimpleAllDayEventView extends StatelessWidget {
  const SimpleAllDayEventView(
    this.event, {
    required this.theme,
    required this.viewType,
    super.key,
  });

  final CalendarView viewType;

  final SimpleAllDayEvent event;

  final AllDayEventsTheme theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: theme.eventMargin,
        child: Text(
          event.title,
          overflow: TextOverflow.ellipsis,
          style: theme.textStyle,
          maxLines: _getTextMaxLines(),
        ),
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
    }
  }
}
