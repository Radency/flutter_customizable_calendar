import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:example/common/event_with_label/event_label.dart';
import 'package:example/common/event_with_label/event_with_label.dart';
import 'package:meta/meta.dart';

part 'events_with_label_state.dart';

class EventsWithLabelCubit extends Cubit<EventsWithLabelState> {
  EventsWithLabelCubit() : super(EventsWithLabelInitial());

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
    var current = DateTime(
      start.year,
      start.month,
      start.day,
      7,
    );
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

        final duration = Duration(
          hours: max(
            1,
            random.nextInt(6),
          ),
        );

        events.add(
          EventWithLabel(
            id: "${current.millisecondsSinceEpoch}_${element.index}",
            start: current,
            duration: duration,
            title: title,
            label: element,
          ),
        );
        current = current.add(duration).subtract(
              Duration(
                hours: min(
                  duration.inHours - 1,
                  random.nextInt(3),
                ),
              ),
            );
      });
      current = current.add(
        Duration(hours: (24 - current.hour) + 7),
      );
    }

    emit(EventsWithLabelInitialized(events: events));
  }

  void updateEvent(EventWithLabel value) {
    final state = this.state;
    if (state is EventsWithLabelInitialized) {
      final events = state.events;
      final index = events.indexWhere((element) => element.id == value.id);
      if (index != -1) {
        events[index] = value;
        emit(EventsWithLabelInitialized(events: events));
      }
    }
  }

  void addEvent(EventWithLabel value) {
    final state = this.state;
    if (state is EventsWithLabelInitialized) {
      final events = state.events;
      events.add(value);
      emit(EventsWithLabelInitialized(events: events));
    }
  }
}
