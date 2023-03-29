import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/themes.dart';

class TaskDueView extends StatelessWidget {
  const TaskDueView(
    this.event, {
    required this.theme,
    super.key,
  });

  final TaskDue event;

  final ViewEventTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        'Task Due',
        style: theme.titleStyle,
      ),
    );
  }
}
