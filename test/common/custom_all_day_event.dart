import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

/// Custom [CalendarEvent] class for testing
/// custom builder for [AllDayCalendarEvent]
class CustomAllDayEvent extends AllDayCalendarEvent {
  /// Create [CustomAllDayEvent] with [title]
  const CustomAllDayEvent({
    required super.id,
    required super.start,
    required super.duration,
    required this.title,
  });

  /// Title of event
  final String title;

  /// Create [CustomAllDayEvent] from [AllDayCalendarEvent]
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
