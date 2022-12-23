import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_customizable_calendar/src/ui/controllers/controllers.dart';

void main() {
  group(
    'DaysViewController test',
    () {
      final now = DateTime(2022, DateTime.november, 10, 9, 45);
      final mockClock = Clock.fixed(now);
      final today = DateUtils.dateOnly(now);
      final tomorrow = DateUtils.addDaysToDate(today, 1);
      final currentMonth = DateTime(now.year, now.month);
      final prevMonth = DateUtils.addMonthsToMonthDate(currentMonth, -1);
      final nextMonth = DateUtils.addMonthsToMonthDate(currentMonth, 1);
      final nextMonthEnd = DateUtils.addDaysToDate(
        nextMonth,
        DateUtils.getDaysInMonth(nextMonth.year, nextMonth.month),
      );

      late DaysViewController controller;

      setUp(() {
        controller = withClock(
          mockClock,
          () => DaysViewController(
            initialDate: prevMonth,
            endDate: nextMonthEnd,
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
          withClock(mockClock, DaysViewInitial.new),
        ),
      );

      blocTest<DaysViewController, DaysViewState>(
        'Controller returns to current time if reset is called',
        build: () => controller,
        act: (bloc) => withClock(mockClock, bloc.reset),
        expect: () => <DaysViewState>[
          withClock(
            mockClock,
            () => DaysViewCurrentDateIsSet(
              displayedDate: clock.now(),
              reverseAnimation: false,
            ),
          ),
        ],
      );

      blocTest<DaysViewController, DaysViewState>(
        'Controller correctly goes to the previous month',
        build: () => controller,
        act: (bloc) => withClock(mockClock, bloc.prev),
        expect: () => <DaysViewState>[
          withClock(
            mockClock,
            () => DaysViewPrevMonthSelected(
              displayedDate: prevMonth,
              focusedDate: now,
            ),
          ),
        ],
      );

      blocTest<DaysViewController, DaysViewState>(
        'Controller correctly goes to the next month',
        build: () => controller,
        act: (bloc) => withClock(mockClock, bloc.next),
        expect: () => <DaysViewState>[
          withClock(
            mockClock,
            () => DaysViewNextMonthSelected(
              displayedDate: nextMonth,
              focusedDate: now,
            ),
          ),
        ],
      );

      blocTest<DaysViewController, DaysViewState>(
        'displayedDate equals to current time if current day is selected',
        build: () => controller,
        act: (bloc) => withClock(
          mockClock,
          () => bloc.selectDay(today),
        ),
        expect: () => <DaysViewState>[
          DaysViewDaySelected(displayedDate: now),
        ],
      );

      blocTest<DaysViewController, DaysViewState>(
        'Controller sets a focused date correctly',
        build: () => controller,
        act: (bloc) => bloc.setFocusedDate(tomorrow),
        expect: () => <DaysViewState>[
          DaysViewFocusedDateIsSet(
            tomorrow,
            reverseAnimation: false,
          ),
        ],
      );
    },
  );
}
