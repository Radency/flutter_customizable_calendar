import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Basic interface for all calendar events
abstract class CalendarEvent extends Equatable
    implements Comparable<CalendarEvent> {
  /// Create a calendar event with given unique [id] and params
  const CalendarEvent({
    required this.id,
    required this.start,
    required this.duration,
    required this.color,
  });

  /// Unique [Object] which allows to identify a specific event
  final Object id;

  /// The event [start] date
  final DateTime start;

  /// The event [duration]
  final Duration duration;

  /// Background color of the event view
  final Color color;

  /// The event [end] date
  DateTime get end => start.add(duration);

  @override
  List<Object?> get props => [id, start, duration];

  @override
  bool? get stringify => true;

  @override
  int compareTo(CalendarEvent other) {
    final cmp = start.compareTo(other.start);
    return (cmp != 0) ? cmp : -duration.compareTo(other.duration);
  }
}

/// Interface which allows to modify an event [start] date
abstract class FloatingCalendarEvent extends CalendarEvent {
  /// Create a calendar event which allows to modify
  /// it's [start] date with given unique [id] and params
  const FloatingCalendarEvent({
    required super.id,
    required super.start,
    required super.duration,
    required super.color,
  });

  /// Returns modified instance of the event with given params
  FloatingCalendarEvent copyWith({DateTime? start});
}

/// Function definition which allows to use custom [T] events builders
typedef EventBuilder<T extends CalendarEvent> = Widget Function(
  BuildContext context,
  T event,
);

/// Interface which allows to modify an event [start] date and it's [duration]
abstract class EditableCalendarEvent extends FloatingCalendarEvent {
  /// Create a calendar event which allows to modify
  /// it's [start] date and [duration] with given unique [id] and params
  const EditableCalendarEvent({
    required super.id,
    required super.start,
    required super.duration,
    required super.color,
  });

  @override
  EditableCalendarEvent copyWith({
    DateTime? start,
    Duration? duration,
  });
}

class Break extends CalendarEvent {
  const Break({
    required super.id,
    required super.start,
    required super.duration,
    super.color = Colors.grey,
  });
}

class TaskDue extends FloatingCalendarEvent {
  const TaskDue({
    required super.id,
    required super.start,
    super.color = Colors.cyan,
    this.wholeDay = false,
  }) : super(duration: wholeDay ? const Duration(days: 1) : Duration.zero);

  final bool wholeDay;

  @override
  TaskDue copyWith({
    DateTime? start,
    Color? color,
    bool? wholeDay,
  }) {
    return TaskDue(
      id: id,
      start: start ?? this.start,
      color: color ?? this.color,
      wholeDay: wholeDay ?? this.wholeDay,
    );
  }
}

class SimpleEvent extends EditableCalendarEvent {
  const SimpleEvent({
    required super.id,
    required super.start,
    required super.duration,
    required this.title,
    super.color = Colors.white,
  });

  final String title;

  @override
  SimpleEvent copyWith({
    DateTime? start,
    Duration? duration,
    Color? color,
    String? title,
  }) {
    return SimpleEvent(
      id: id,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      color: color ?? this.color,
      title: title ?? this.title,
    );
  }
}
