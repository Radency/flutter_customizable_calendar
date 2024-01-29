import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

/// Custom [CalendarEvent] class for testing
/// custom builders for [EditableCalendarEvent]
class CustomCalendarEvent extends EditableCalendarEvent {
  /// Create [CustomCalendarEvent] with [title]
  const CustomCalendarEvent({
    required super.id,
    required super.start,
    required super.duration,
    required super.color,
    required this.title,
  });

  /// Title of event
  final String title;

  /// Create a copy of [CustomCalendarEvent] with new [start] and [duration]
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
