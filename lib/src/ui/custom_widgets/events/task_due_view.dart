import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class TaskDueView extends StatelessWidget {
  const TaskDueView(
    this.event, {
    required this.theme,
    required this.viewType,
    super.key,
  });

  final TaskDue event;

  final ViewEventTheme theme;

  final CalendarView viewType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: viewType == CalendarView.month
          ? const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 8,
            )
          : const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        'Task Due',
        style: theme.titleStyle,
        overflow: viewType == CalendarView.month ? TextOverflow.ellipsis : null,
      ),
    );
  }
}
