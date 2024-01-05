import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class ImageCalendarEvent extends EditableCalendarEvent {
  ImageCalendarEvent(
      {required super.id,
      required super.start,
      required super.duration,
      required super.color,
      required this.title,
      required this.imgAsset});

  final String title;
  final String imgAsset;

  @override
  EditableCalendarEvent copyWith({DateTime? start, Duration? duration}) {
    return ImageCalendarEvent(
        id: id,
        start: start ?? this.start,
        duration: duration ?? this.duration,
        color: color,
        title: title,
        imgAsset: imgAsset);
  }
}
