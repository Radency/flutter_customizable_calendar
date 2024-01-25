import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class CustomAllDayEvent extends AllDayCalendarEvent {
  const CustomAllDayEvent({
    required super.id,
    required super.start,
    required super.duration,
    required this.title,
  });

  final String title;

  @override
  EditableCalendarEvent copyWith({DateTime? start, Duration? duration}) {
    return CustomAllDayEvent(
      id: id,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      title: title,
    );
  }
}
