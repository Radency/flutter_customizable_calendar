import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

import '../common/custom_calendar_event.dart';
import 'schedule_list_view_controller.dart';

void main() {
  group(
    'ScheduleListView custom builders tests',
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
          now: now,
          controller: controller,
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
          final formatter1 = DateFormat.y();
          final formatter2 = DateFormat.MMMMEEEEd();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ScheduleListView<FloatingCalendarEvent>(
                  controller: controller,
                  dayBuilder: (context, events, day) {
                    return Column(
                      children: [
                        Text(
                          formatter1.format(day),
                        ),
                        Text(
                          formatter2.format(day),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(
            find.text(formatter1.format(now)),
            findsWidgets,
          );

          expect(
            find.text(formatter2.format(now)),
            findsOneWidget,
          );
        },
      );

      testWidgets('ScheduleListView shows custom event with image correctly',
          (widgetTester) async {
        final event = CustomCalendarEvent(
          id: 'Task1',
          title: 'Workout',
          start: now.add(const Duration(hours: 13)),
          duration: const Duration(hours: 1),
          color: Colors.black,
        );
        CalendarEvent? tappedEvent;

        final view = ScheduleListView<CalendarEvent>(
          controller: controller,
          events: [event],
          eventBuilders: {
            CustomCalendarEvent: (context, e) {
              final event = e as CustomCalendarEvent;
              return InkWell(
                onTap: () {
                  tappedEvent = event;
                },
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      event.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                          ),
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          },
        );
        await widgetTester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: view,
            ),
          ),
        );

        await widgetTester.pumpAndSettle();

        expect(find.text('Workout'), findsOneWidget);

        await widgetTester.tap(find.text('Workout'));

        expect(tappedEvent, event);
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
          monthPickerBuilder: (
            context,
            next,
            prev,
            setDate,
            date,
          ) {
            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    prev();
                  },
                  icon: const Icon(CupertinoIcons.arrow_left),
                ),
                Text(
                  DateFormat.yMMMM().format(date),
                ),
                IconButton(
                  onPressed: () {
                    next();
                  },
                  icon: const Icon(CupertinoIcons.arrow_right),
                ),
              ],
            );
          },
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

        await widgetTester.tap(find.byIcon(CupertinoIcons.arrow_right));

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
            monthPickerBuilder: (
              context,
              next,
              prev,
              setDate,
              date,
            ) {
              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      prev();
                    },
                    icon: const Icon(CupertinoIcons.arrow_left),
                  ),
                  Text(
                    DateFormat.yMMMM().format(date),
                  ),
                  IconButton(
                    onPressed: () {
                      next();
                    },
                    icon: const Icon(CupertinoIcons.arrow_right),
                  ),
                ],
              );
            },
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

          await widgetTester.tap(find.byIcon(CupertinoIcons.arrow_left));

          await widgetTester.pumpAndSettle();

          expect(find.text('Previous month'), findsOneWidget);
          expect(find.text('Today'), findsNothing);
        },
      );
    },
    skip: false,
  );
}
