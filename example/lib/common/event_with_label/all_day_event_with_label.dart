import 'package:example/common/event_with_label/event_label.dart';
import 'package:example/common/event_with_label/event_with_label.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class AllDayEventWithLabel extends AllDayCalendarEvent
    implements EventWithLabel {
  final String _title;
  final EventLabel _label;

  @override
  EventLabel get label => _label;

  @override
  String get title => _title;

  AllDayEventWithLabel({
    required String title,
    required EventLabel label,
    required super.id,
    required super.start,
    required super.duration,
  })  : _title = title,
        _label = label;

  @override
  EditableCalendarEvent copyWith({DateTime? start, Duration? duration}) {
    return AllDayEventWithLabel(
      id: id,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      label: label,
      title: title,
    );
  }
}
