part of 'events_cubit.dart';

@immutable
abstract class EventsState {}

class EventsInitial extends EventsState {}

class EventsInitialized extends EventsState {
  EventsInitialized({
    required this.events,
  });

  final List<DeliveryEvent<EventAttachment>> events;

  EventsInitialized copyWith({
    List<DeliveryEvent<EventAttachment>>? events,
  }) {
    return EventsInitialized(
      events: events ?? this.events,
    );
  }
}
