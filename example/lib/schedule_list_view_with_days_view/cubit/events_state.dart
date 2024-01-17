part of 'events_cubit.dart';

@immutable
abstract class EventsState {}

class EventsInitial extends EventsState {}

class EventsInitialized extends EventsState {
  EventsInitialized({
    required this.events,
  });

  final List<EventWithLabel> events;

  EventsInitialized copyWith({
    List<EventWithLabel>? events,
  }) {
    return EventsInitialized(
      events: events ?? this.events,
    );
  }
}
