import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:mocktail/mocktail.dart';

/// Mock [ScheduleListViewController] class
class MockScheduleLisViewController
    extends MockCubit<ScheduleListViewControllerState>
    implements ScheduleListViewController {}



/// Setup [ScheduleListViewController] mock
void setupScheduleListViewController({
  required ScheduleListViewController controller,
  required DateTime now,
  required DateTime prevMonth,
  required DateTime nextMonthEnd,
}) {
  final mockClock = Clock.fixed(now);

  /// initial state with date for [MockScheduleListViewController]
  ScheduleListViewControllerInitial initial() =>
      withClock(mockClock, ScheduleListViewControllerInitial.new);


  when(
    () => controller.initialDate,
  ).thenReturn(
    prevMonth,
  );
  when(
    () => controller.endDate,
  ).thenReturn(nextMonthEnd);

  when(
    () => controller.state,
  ).thenReturn(
    initial(),
  );
  when(
    () => controller.grouped,
  ).thenReturn(
    Map.fromEntries(
      DateTimeRange(
        start: prevMonth,
        end: nextMonthEnd,
      ).days.map(
            (e) => MapEntry(e, <CalendarEvent>[]),
          ),
    ),
  );

  when(
    () => controller.animateToGroupIndex(
      events: any(named: 'events'),
      ignoreEmpty: any(named: 'ignoreEmpty'),
    ),
  ).thenAnswer((a) {
    final events = a.namedArguments[const Symbol('events')]
        as Map<DateTime, List<CalendarEvent>>;
    final ignoreEmpty = a.namedArguments[const Symbol('ignoreEmpty')] as bool;

    final entries = events.entries;
    late final List<DateTime> keys;

    if (ignoreEmpty) {
      keys =
          entries.where((e) => e.value.isNotEmpty).map((e) => e.key).toList();
    } else {
      keys = entries.map((e) => e.key).toList();
    }

    late final DateTime targetDate;
    final state = controller.state;

    if (state is ScheduleListViewControllerCurrentDateIsSet) {
      final animateTo = state.animateTo;
      targetDate = DateTime(
        animateTo.year,
        animateTo.month,
        animateTo.day,
      );
    } else {
      targetDate = DateTime(
        state.displayedDate.year,
        state.displayedDate.month,
        state.displayedDate.day,
      );
    }

    final index = keys.indexOf(targetDate);
    if (index != -1) {
      return index;
    }

    // return closest target date or closes
    final closest = keys.sorted((a, b) {
      final aDiff = a.difference(targetDate).abs();
      final bDiff = b.difference(targetDate).abs();
      return aDiff.compareTo(bDiff);
    });
    return keys.indexOf(closest.first);
  });
}
