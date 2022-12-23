import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';

class MonthView<T extends CalendarEvent> extends StatelessWidget {
  /// Creates a Month view. Parameter [initialDate] is required.
  const MonthView({
    super.key,
    // required this.initialDate,
    // this.events = const [],
  });

  /// Calendar initial date
  // final DateTime initialDate;

  /// Events list to display
  // final List<T> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // _monthPicker(),
        const SizedBox(height: 16),
      ],
    );
  }
}
