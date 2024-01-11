import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'ScheduleListViewController tests',
    () {
      final now = DateTime(2024, DateTime.january, 11, 9, 30);
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

      late ScheduleListViewController controller;

      setUp(() {
        controller = withClock(
          mockClock,
          () => ScheduleListViewController(
            initialDate: prevMonth,
            endDate: nextMonthEnd,
          ),
        );
      });

      tearDown(() async {
        await controller.close();
      });

      test('Controller initial state shows current time', () {
        expect(
          controller.state,
          withClock(mockClock, ScheduleListViewControllerInitial.new),
        );
      });

      blocTest<ScheduleListViewController, ScheduleListViewControllerState>(
        'Controller returns to current time if reset is called',
        build: () => controller,
        act: (bloc) => withClock(mockClock, bloc.reset),
        expect: () => <ScheduleListViewControllerState>[
          withClock(
            mockClock,
            () => ScheduleListViewControllerCurrentDateIsSet(
              displayedDate: controller.state.displayedDate,
              reverseAnimation: false,
              animateTo: DateTime(
                now.year,
                now.month,
                now.day,
              ),
            ),
          ),
        ],
      );

      blocTest<ScheduleListViewController, ScheduleListViewControllerState>(
        'Controller correctly goes to the previous month',
        build: () => controller,
        act: (bloc) => withClock(mockClock, bloc.prev),
        expect: () => <ScheduleListViewControllerState>[
          withClock(
            mockClock,
            () => ScheduleListViewControllerCurrentDateIsSet(
              displayedDate: controller.state.displayedDate,
              reverseAnimation: true,
              animateTo: DateTime(
                prevMonth.year,
                prevMonth.month,
                2,
              ),
            ),
          ),
        ],
      );

      blocTest<ScheduleListViewController, ScheduleListViewControllerState>(
        'Controller correctly goes to the next month',
        build: () => controller,
        act: (bloc) => withClock(mockClock, bloc.next),
        expect: () => <ScheduleListViewControllerState>[
          withClock(
            mockClock,
            () => ScheduleListViewControllerCurrentDateIsSet(
              displayedDate: controller.state.displayedDate,
              reverseAnimation: false,
              animateTo: DateTime(
                nextMonth.year,
                nextMonth.month,
                2,
              ),
            ),
          ),
        ],
      );

      blocTest<ScheduleListViewController, ScheduleListViewControllerState>(
        'displayedDate equals to current time if current day is selected',
        build: () => controller,
        act: (bloc) => withClock(
          mockClock,
          () => bloc.setDisplayedDate(
            now,
          ),
        ),
        expect: () => <ScheduleListViewControllerState>[
          withClock(
            mockClock,
            () => ScheduleListViewControllerCurrentDateIsSet(
              displayedDate: controller.state.displayedDate,
              reverseAnimation: false,
              animePicker: false,
              animateTo: DateTime(
                now.year,
                now.month,
                now.day,
              ),
            ),
          ),
        ],
      );

      blocTest<ScheduleListViewController, ScheduleListViewControllerState>(
        'displayedDate equals to current time if current day is selected',
        build: () => controller,
        act: (bloc) => withClock(
          mockClock,
          () => bloc.setDisplayedDate(
            tomorrow,
          ),
        ),
        expect: () => <ScheduleListViewControllerState>[
          withClock(
            mockClock,
            () => ScheduleListViewControllerCurrentDateIsSet(
              displayedDate: controller.state.displayedDate,
              reverseAnimation: false,
              animePicker: false,
              animateTo: DateTime(
                tomorrow.year,
                tomorrow.month,
                tomorrow.day,
              ),
            ),
          ),
        ],
      );

      blocTest<ScheduleListViewController, ScheduleListViewControllerState>(
        'Controller sets a displayed date correctly',
        build: () => controller,
        act: (bloc) => bloc.setDisplayedDateByGroupIndex(0),
        expect: () => <ScheduleListViewControllerState>[
          ScheduleListViewControllerCurrentDateIsSet(
            displayedDate: controller.state.displayedDate,
            animateTo: DateTime(
              prevMonth.year,
              prevMonth.month,
            ),
            animeList: false,
            reverseAnimation: true,
          ),
        ],
      );
    },
    skip: false,
  );
}
