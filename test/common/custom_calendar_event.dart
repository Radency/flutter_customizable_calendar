import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class CustomCalendarEvent extends EditableCalendarEvent {
  const CustomCalendarEvent({
    required super.id,
    required super.start,
    required super.duration,
    required super.color,
    required this.title,
  });

  final String title;

  @override
  EditableCalendarEvent copyWith({DateTime? start, Duration? duration}) {
    return CustomCalendarEvent(
      id: id,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      color: color,
      title: title,
    );
  }
}
