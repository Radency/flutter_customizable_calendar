import 'package:example/schedule_list_view_with_days_view/event_with_label/event_label.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class EventWithLabel extends EditableCalendarEvent {
  EventWithLabel(
      {required super.id,
      required super.start,
      required super.duration,
      required this.title,
      required this.label});

  final String title;
  final EventLabel label;

  @override
  EditableCalendarEvent copyWith({DateTime? start, Duration? duration}) {
    return EventWithLabel(
      id: id,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      label: label,
      title: title,
    );
  }
}
