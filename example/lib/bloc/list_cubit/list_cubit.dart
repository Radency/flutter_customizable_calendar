import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

part 'list_state.dart';

class ListCubit extends Cubit<ListState> {
  ListCubit() : super(ListState(events: {}, breaks: {}));

  void save(CalendarEvent event) {
    if (event is Break) {
      emit(state.copyWith(breaks: state.breaks..[event.id] = event));
    }
    if (event is FloatingCalendarEvent) {
      emit(state.copyWith(events: state.events..[event.id] = event));
    }
  }

  void saveAll({List<FloatingCalendarEvent>? events, List<Break>? breaks}) {
    if (events != null) {
      emit(state.copyWith(
          events: state.events
            ..addEntries(events.map((e) => MapEntry(e.id, e)))));
    }
    if (breaks != null) {
      emit(state.copyWith(
          breaks: state.breaks
            ..addEntries(breaks.map((e) => MapEntry(e.id, e)))));
    }
  }
}
