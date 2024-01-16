import 'package:example/complete_example/custom_events/event_attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class DeliveryEvent<T extends EventAttachment> extends EditableCalendarEvent {
  const DeliveryEvent({
    required this.attachments,
    required Object id,
    required DateTime start,
    required Duration duration,
    required this.location,
    required this.title,
    required this.iconAsset,
    Color color = Colors.transparent,
    this.completed = false,
  }) : super(
          id: id,
          start: start,
          duration: duration,
          color: color,
        );
  final List<T> attachments;
  final String location;
  final String title;
  final String iconAsset;

  final bool completed;

  @override
  EditableCalendarEvent copyWith({DateTime? start, Duration? duration}) {
    return DeliveryEvent(
      attachments: attachments,
      id: id,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      color: color,
      location: location,
      title: title,
      iconAsset: iconAsset,
      completed: completed,
    );
  }
}
