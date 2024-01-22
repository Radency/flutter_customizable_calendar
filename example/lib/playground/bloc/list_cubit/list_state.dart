part of 'list_cubit.dart';

class ListState {
  final Map<Object, FloatingCalendarEvent> events;
  final Map<Object, Break> breaks;

  ListState({required this.events, required this.breaks});

  ListState copyWith(
          {Map<Object, FloatingCalendarEvent>? events,
          Map<Object, Break>? breaks}) =>
      ListState(
        events: events ?? this.events,
        breaks: breaks ?? this.breaks,
      );
}
