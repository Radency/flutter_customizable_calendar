import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("MonthViewController test", () {
    final now = DateTime(2022, DateTime.november, 10, 9, 45);
    final mockClock = Clock.fixed(now);
    final currentMonth = DateTime(now.year, now.month);
    final prevMonth = DateUtils.addMonthsToMonthDate(currentMonth, -1);
    final nextMonth = DateUtils.addMonthsToMonthDate(currentMonth, 1);
    final nextMonthEnd = DateUtils.addDaysToDate(
      nextMonth,
      DateUtils.getDaysInMonth(nextMonth.year, nextMonth.month),
    );

    late MonthViewController controller;

    setUp(() {
      controller = withClock(
        mockClock,
        () => MonthViewController(
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
        withClock(mockClock, MonthViewInitial.new),
      ),
    );

    blocTest<MonthViewController, MonthViewState>(
      'Controller returns to current time if reset is called',
      build: () => controller,
      act: (bloc) => withClock(mockClock, bloc.reset),
      expect: () => <MonthViewState>[
        withClock(
          mockClock,
          () => MonthViewCurrentMonthIsSet(
            focusedDate: clock.now(),
            reverseAnimation: false,
          ),
        ),
      ],
    );

    blocTest<MonthViewController, MonthViewState>(
      'Controller returns to current time if reset is called',
      build: () => controller,
      act: (bloc) => withClock(mockClock, bloc.reset),
      expect: () => <MonthViewState>[
        withClock(
          mockClock,
          () => MonthViewCurrentMonthIsSet(
            focusedDate: clock.now(),
            reverseAnimation: false,
          ),
        ),
      ],
    );

    blocTest<MonthViewController, MonthViewState>(
      'Controller correctly goes to the previous month',
      build: () => controller,
      act: (bloc) => withClock(mockClock, bloc.prev),
      expect: () => <MonthViewState>[
        withClock(
          mockClock,
          () => MonthViewPrevMonthSelected(
            focusedDate: prevMonth,
          ),
        ),
      ],
    );

    blocTest<MonthViewController, MonthViewState>(
      'Controller correctly goes to the next month',
      build: () => controller,
      act: (bloc) => withClock(mockClock, bloc.next),
      expect: () => <MonthViewState>[
        withClock(
          mockClock,
          () => MonthViewNextMonthSelected(
            focusedDate: nextMonth,
          ),
        ),
      ],
    );
  });
}
