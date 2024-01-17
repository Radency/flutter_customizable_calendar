import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:example/schedule_list_view_with_days_view/event_with_label/event_label.dart';
import 'package:example/schedule_list_view_with_days_view/event_with_label/event_with_label.dart';
import 'package:meta/meta.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit() : super(EventsInitial());

  static const Map<String, EventLabel> titles = {
    "Project Meeting": EventLabel.work,
    "Meeting with Client": EventLabel.work,
    "Team Meeting": EventLabel.work,
    "Meeting with Manager": EventLabel.work,
    "Sprint Planning": EventLabel.work,
    "Sprint Retrospective": EventLabel.work,
    "Daily Scrum": EventLabel.work,
    "Flight to London": EventLabel.travel,
    "Flight to Paris": EventLabel.travel,
    "Flight to New York": EventLabel.travel,
    "Flight to Tokyo": EventLabel.travel,
    "Flight to Berlin": EventLabel.travel,
    "Flight to Amsterdam": EventLabel.travel,
    "Flight to Madrid": EventLabel.travel,
    "Flight to Rome": EventLabel.travel,
    "Return the books": EventLabel.personal,
    "Buy a new phone": EventLabel.personal,
    "Buy a new car": EventLabel.personal,
    "Buy a new house": EventLabel.personal,
    "Buy a new laptop": EventLabel.personal,
    "Buy a new bike": EventLabel.personal,
    "Buy a new watch": EventLabel.personal,
    "Buy a new TV": EventLabel.personal,
    "Buy a new chair": EventLabel.personal,
    "Send work report": EventLabel.work,
    "Send email to boss": EventLabel.work,
    "Send email to client": EventLabel.work,
    "Send email to manager": EventLabel.work,
    "Send email to team": EventLabel.work,
    "Send email to HR": EventLabel.work,
    "Send email to CEO": EventLabel.work,
    "Medical checkup": EventLabel.personal,
    "Dentist appointment": EventLabel.personal,
    "Buy groceries": EventLabel.personal,
    "Buy vegetables": EventLabel.personal,
    "Buy fruits": EventLabel.personal,
    "Buy meat": EventLabel.personal,
    "Buy fish": EventLabel.personal,
    "Buy milk": EventLabel.personal,
    "Buy eggs": EventLabel.personal,
    "Buy bread": EventLabel.personal,
    "Dinner with family": EventLabel.family,
    "Dinner with friends": EventLabel.friends,
    "Dinner with colleagues": EventLabel.work,
    "Birthday party": EventLabel.birthday,
    "Party with friends": EventLabel.friends,
    "EDM Festival": EventLabel.friends,
    "Go to the gym": EventLabel.personal,
    "Go to the park": EventLabel.family,
    "Take the dog for a walk": EventLabel.family,
    "Hardstyle Festival": EventLabel.friends,
    "Play the guitar": EventLabel.personal,
    "Play the piano": EventLabel.personal,
    "Play the drums": EventLabel.personal,
  };

  void init() {
    final List<EventWithLabel> events = [];
    final random = Random.secure();

    final start = DateTime.now().subtract(const Duration(days: 90));
    final end = DateTime.now().add(const Duration(days: 365));
    var current = start;
    while (current.isBefore(end)) {
      final addEvents = random.nextBool() || current.day == DateTime.now().day;
      if (!addEvents) {
        current = current.add(const Duration(days: 1));
        continue;
      }

      final number = random.nextInt(5);

      final labels = titles.values.toSet().toList()..shuffle();
      final randomLabels = labels.sublist(0, number);

      randomLabels.forEach((element) {
        final shuffled = titles.entries.toList()..shuffle();
        final title = shuffled.firstWhere((e) => e.value == element).key;
        events.add(
          EventWithLabel(
            id: "${current.millisecondsSinceEpoch}_${element.index}",
            start: current,
            duration: const Duration(hours: 4),
            title: title,
            label: element,
          ),
        );
      });
      current = current.add(const Duration(days: 1));
    }

    emit(EventsInitialized(events: events));
  }

  void addEvent(EventWithLabel value) {
    final state = this.state;
    if (state is EventsInitialized) {
      final events = state.events;
      events.add(value);
      emit(EventsInitialized(events: events));
    }
  }
}
