import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

import 'schedule_list_view_controller.dart';

void main() {
  group(
    'ScheduleListView tests',
    () {
      final now = DateTime(2024, DateTime.january, 11, 9, 30);
      final currentMonth = DateTime(now.year, now.month);
      final prevMonth = DateUtils.addMonthsToMonthDate(currentMonth, -1);
      final nextMonth = DateUtils.addMonthsToMonthDate(currentMonth, 1);
      final nextMonthEnd = DateUtils.addDaysToDate(
        nextMonth,
        DateUtils.getDaysInMonth(nextMonth.year, nextMonth.month),
      );

      late ScheduleListViewController controller;

      setUp(() {
        controller = MockScheduleLisViewController();
        setupScheduleListViewController(
          controller: controller,
          now: now,
          nextMonthEnd: nextMonthEnd,
          prevMonth: prevMonth,
        );
      });

      tearDown(() async {
        await controller.close();
      });

      testWidgets(
        'ScheduleListView initial state shows current time',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ScheduleListView<FloatingCalendarEvent>(
                  controller: controller,
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          final weekDayFormatter = DateFormat('EEE');
          final dayFormatter = DateFormat('d');

          expect(
            find.text(weekDayFormatter.format(now)),
            findsOneWidget,
          );

          expect(
            find.text(dayFormatter.format(now)),
            findsOneWidget,
          );
        },
      );

      testWidgets('ScheduleListView shows event correctly',
          (widgetTester) async {
        final event = SimpleEvent(
          id: '1',
          title: 'Test',
          start: now,
          duration: const Duration(hours: 1),
        );

        final view = ScheduleListView<SimpleEvent>(
          controller: controller,
          events: [event],
        );
        await widgetTester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: view,
            ),
          ),
        );

        await widgetTester.pumpAndSettle();

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('ScheduleListView switches to the next month',
          (widgetTester) async {
        final todayEvent = SimpleEvent(
          id: '1',
          title: 'Today',
          start: now,
          duration: const Duration(hours: 1),
        );

        final nextMonthEvent = SimpleEvent(
          id: '2',
          title: 'Next month',
          start: nextMonth,
          duration: const Duration(hours: 1),
        );

        final events = [todayEvent, nextMonthEvent];

        final view = ScheduleListView(
          controller: controller,
          events: events,
        );

        whenListen(
          controller,
          Stream<ScheduleListViewControllerState>.fromIterable(
            [
              ScheduleListViewControllerCurrentDateIsSet(
                displayedDate: nextMonth,
                reverseAnimation: false,
                animateTo: nextMonth,
              ),
            ],
          ),
        );

        await widgetTester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: view,
            ),
          ),
        );

        await widgetTester.pumpAndSettle();

        await widgetTester.tap(find.byIcon(CupertinoIcons.chevron_right));

        await widgetTester.pumpAndSettle();

        expect(find.text('Next month'), findsOneWidget);
        expect(find.text('Today'), findsNothing);
      });

      testWidgets(
        'ScheduleListView switches to the previous month',
        (widgetTester) async {
          final todayEvent = SimpleEvent(
            id: '1',
            title: 'Today',
            start: now,
            duration: const Duration(hours: 1),
          );

          final prevMonthEvent = SimpleEvent(
            id: '2',
            title: 'Previous month',
            start: prevMonth,
            duration: const Duration(hours: 1),
          );

          final view = ScheduleListView(
            controller: controller,
            events: [todayEvent, prevMonthEvent],
          );

          when(() => controller.state).thenReturn(
            ScheduleListViewControllerCurrentDateIsSet(
              displayedDate: DateTime(
                prevMonth.year,
                prevMonth.month,
                2,
              ),
              reverseAnimation: true,
              animateTo: DateTime(
                prevMonth.year,
                prevMonth.month,
                2,
              ),
            ),
          );

          await widgetTester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: view,
              ),
            ),
          );

          await widgetTester.pumpAndSettle();

          await widgetTester.tap(find.byIcon(CupertinoIcons.chevron_left));

          await widgetTester.pumpAndSettle();

          expect(find.text('Previous month'), findsOneWidget);
          expect(find.text('Today'), findsNothing);
        },
      );
    },
    skip: false,
  );
}
