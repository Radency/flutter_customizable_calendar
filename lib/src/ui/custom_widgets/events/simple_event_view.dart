import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class SimpleEventView extends StatelessWidget {
  const SimpleEventView(
    this.event, {
    required this.theme,
    required this.viewType,
    super.key,
  });

  final CalendarView viewType;
  final SimpleEvent event;
  final ViewEventTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _getPadding(),
      child: Text(
        event.title,
        overflow: TextOverflow.ellipsis,
        style: theme.titleStyle,
        maxLines: _getTextMaxLines(),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (viewType) {
      case CalendarView.days:
        return const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        );
      case CalendarView.week:
        return const EdgeInsets.symmetric(
          vertical: 4,
        );
      case CalendarView.month:
        return const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 4,
        );
      case CalendarView.scheduleList:
        return const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 4,
        );
    }
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
