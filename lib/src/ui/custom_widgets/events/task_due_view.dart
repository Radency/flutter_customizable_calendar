import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';

class TaskDueView extends StatelessWidget {
  const TaskDueView(
    this.event, {
    super.key,
  });

  final TaskDue event;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text('Task Due'),
    );
  }
}
