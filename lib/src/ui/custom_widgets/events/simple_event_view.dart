import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';

class SimpleEventView extends StatelessWidget {
  const SimpleEventView(
    this.event, {
    super.key,
  });

  final SimpleEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      child: Text(
        event.title,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
