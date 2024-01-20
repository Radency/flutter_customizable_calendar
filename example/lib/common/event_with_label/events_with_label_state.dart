part of 'events_with_label_cubit.dart';

@immutable
abstract class EventsWithLabelState {}

class EventsWithLabelInitial extends EventsWithLabelState {}

class EventsWithLabelInitialized extends EventsWithLabelState {
  EventsWithLabelInitialized({
    required this.events,
  });

  final List<EventWithLabel> events;

  EventsWithLabelInitialized copyWith({
    List<EventWithLabel>? events,
  }) {
    return EventsWithLabelInitialized(
      events: events ?? this.events,
    );
  }
}
