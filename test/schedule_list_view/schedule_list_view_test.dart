import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

class MockScheduleLisViewController
    extends MockCubit<ScheduleListViewControllerState>
    implements ScheduleListViewController {}

void main() {
  group(
    'ScheduleListView tests',
    () {
      final now = DateTime(2024, DateTime.january, 11, 9, 30);
      final mockClock = Clock.fixed(now);
      final currentMonth = DateTime(now.year, now.month);
      final prevMonth = DateUtils.addMonthsToMonthDate(currentMonth, -1);
      final nextMonth = DateUtils.addMonthsToMonthDate(currentMonth, 1);
      final nextMonthEnd = DateUtils.addDaysToDate(
        nextMonth,
        DateUtils.getDaysInMonth(nextMonth.year, nextMonth.month),
      );

      ScheduleListViewControllerInitial initial() =>
          withClock(mockClock, ScheduleListViewControllerInitial.new);

      late ScheduleListViewController controller;

      setUp(() {
        controller = MockScheduleLisViewController();

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
          final ignoreEmpty =
              a.namedArguments[const Symbol('ignoreEmpty')] as bool;

          final entries = events.entries;
          late final List<DateTime> keys;

          if (ignoreEmpty) {
            keys = entries
                .where((e) => e.value.isNotEmpty)
                .map((e) => e.key)
                .toList();
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
