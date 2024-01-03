import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("WeekViewController test", () {
    final now = DateTime(2024, DateTime.january, 3, 12, 0);
    final mockClock = Clock.fixed(now);
    final prevWeek = DateUtils.addDaysToDate(now, -7);
    final nextWeek = DateUtils.addDaysToDate(now, 7);

    late WeekViewController controller;

    setUp(() {
      controller = withClock(
        mockClock,
        () => WeekViewController(
          initialDate: prevWeek,
          endDate: nextWeek,
        ),
      );
    });

    tearDown(() async {
      await controller.close();
    });

    test(
      'Controller initial state shows current time',
      () => expect(
        controller.state,
        withClock(mockClock, WeekViewInitial.new),
      ),
    );

    blocTest<WeekViewController, WeekViewState>(
      'Controller returns to current time if reset is called',
      build: () => controller,
      act: (bloc) => withClock(mockClock, bloc.reset),
      expect: () => <WeekViewState>[
        withClock(
          mockClock,
          () => WeekViewCurrentWeekIsSet(
            focusedDate: clock.now(),
            reverseAnimation: false,
          ),
        ),
      ],
    );

    blocTest<WeekViewController, WeekViewState>(
      'Controller returns to current time if reset is called',
      build: () => controller,
      act: (bloc) => withClock(mockClock, bloc.reset),
      expect: () => <WeekViewState>[
        withClock(
          mockClock,
          () => WeekViewCurrentWeekIsSet(
            focusedDate: clock.now(),
            reverseAnimation: false,
          ),
        ),
      ],
    );

    blocTest<WeekViewController, WeekViewState>(
      'Controller correctly goes to the previous month',
      build: () => controller,
      act: (bloc) => withClock(mockClock, bloc.prev),
      expect: () => <WeekViewState>[
        withClock(
          mockClock,
          () => WeekViewPrevWeekSelected(
            focusedDate: prevWeek,
          ),
        ),
      ],
    );

    blocTest<WeekViewController, WeekViewState>(
      'Controller correctly goes to the next month',
      build: () => controller,
      act: (bloc) => withClock(mockClock, bloc.next),
      expect: () => <WeekViewState>[
        withClock(
          mockClock,
          () => WeekViewNextWeekSelected(
            focusedDate: nextWeek,
          ),
        ),
      ],
    );
  });
}
