import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../common/custom_all_day_event.dart';
import '../common/custom_calendar_event.dart';
import 'week_view_controller.dart';

void main() {
  MaterialApp runTestApp(Widget view) => MaterialApp(home: view);

  group('WeekView custom builders tests', () {
    final now = DateTime(2024, DateTime.january, 3, 12);

    final currentWeek = DateTime(now.year, now.month);
    final currentWeekEnd = DateTime(now.year, now.month, 7);
    final nextWeek = DateTime(now.year, now.month, 14);
    final currentMonth = DateTime(now.year, now.month);
    final daysInCurrentMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final currentMonthEnd = DateTime(now.year, now.month, daysInCurrentMonth);

    late WeekViewController controller;

    setUp(() {
      controller = MockWeekViewController();

      setupWeekViewController(
        controller: controller,
        now: now,
        currentWeek: currentWeek,
        currentWeekEnd: currentWeekEnd,
      );
    });

    tearDown(() {
      controller.close();
    });

    testWidgets('Custom Week picker displays current week',
        (widgetTester) async {
      final view = WeekView(
        controller: controller,
        weekPickerBuilder: (context, events, week) {
          // day rage is not inclusive, so we need to subtract 1
          return Text('Week ${week.start.day} - ${week.end.day - 1}');
        },
      );

      await widgetTester.pumpWidget(runTestApp(view));
      expect(
        find.text('Week 1 - 7'),
        findsAny,
        reason: 'Week picker should display ‘current week',
      );
    });

    testWidgets(
      'Tap on an custom event view returns the event',
      (widgetTester) async {
        FloatingCalendarEvent? tappedEvent;

        final event = CustomCalendarEvent(
          id: 'SimpleEvent1',
          start: now,
          duration: const Duration(hours: 1),
          title: 'SimpleEvent1',
          color: Colors.red,
        );
        final view = WeekView<FloatingCalendarEvent>(
          controller: controller,
          onEventTap: (event) => tappedEvent = event,
          events: [event],
          eventBuilders: {
            CustomCalendarEvent: (context, e) {
              final event = e as CustomCalendarEvent;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                  ),
                ),
                child: Text('${event.title}_custom'),
              );
            },
          },
        );

        await widgetTester.pumpWidget(runTestApp(view));

        await widgetTester.tap(find.text('${event.title}_custom').first);

        expect(tappedEvent, event);
      },
      skip: false,
    );

    testWidgets(
      'Switching to another week changes custom period picker text',
      (widgetTester) async {
        final view = WeekView(
          controller: controller,
          weekPickerBuilder: (context, events, week) {
            // day rage is not inclusive, so we need to subtract 1
            return Text('Week ${week.start.day} - ${week.end.day - 1}');
          },
        );

        when(() => controller.state).thenReturn(
          withClock(
            clock,
            () => WeekViewNextWeekSelected(focusedDate: nextWeek),
          ),
        );

        await widgetTester.pumpWidget(runTestApp(view));

        await widgetTester.pumpAndSettle();

        expect(
          find.text('Week 8 - 14'),
          findsAny,
          reason: 'Week picker should display ‘next week',
        );
      },
      skip: false,
    );

    testWidgets(
      'Custom all-Day event is displayed',
      (widgetTester) async {
        final event = CustomAllDayEvent(
          id: 'All-Day Event 1',
          start: now,
          duration: const Duration(days: 1),
          title: 'All-Day Event 1',
        );

        final view = WeekView(
          controller: controller,
          events: [event],
          eventBuilders: {
            CustomAllDayEvent: (context, e) {
              final event = e as CustomAllDayEvent;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                  ),
                ),
                child: Text('${event.title}_custom'),
              );
            },
          },
        );

        await widgetTester.pumpWidget(runTestApp(view));

        await widgetTester.pumpAndSettle();

        expect(find.text('${event.title}_custom'), findsAny);
      },
      skip: false,
    );

    testWidgets(
      'custom All-Day event onTap callback is called',
      (widgetTester) async {
        final event = CustomAllDayEvent(
          id: 'All-Day Event 1',
          start: now,
          duration: const Duration(days: 1),
          title: 'All-Day Event 1',
        );

        AllDayCalendarEvent? tappedCustomEvent;
        AllDayCalendarEvent? tappedEvent;
        final view = WeekView(
          controller: controller,
          events: [event],
          onEventTap: (event) => tappedEvent = event,
          eventBuilders: {
            CustomAllDayEvent: (context, e) {
              final event = e as CustomAllDayEvent;
              return InkWell(
                onTap: () {
                  tappedCustomEvent = event;
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                    ),
                  ),
                  child: Text('${event.title}_custom'),
                ),
              );
            }
          },
        );

        when(() => controller.state)
            .thenReturn(initialStateWithDate(event.start));

        await widgetTester.pumpWidget(runTestApp(view));

        await widgetTester.pumpAndSettle();

        await widgetTester.tap(find.text('${event.title}_custom').first);

        expect(tappedCustomEvent, event);
        expect(tappedEvent, null);
      },
      skip: false,
    );

    testWidgets(
      'All-Day events custom show more button is displayed',
      (widgetTester) async {
        final event = CustomAllDayEvent(
          id: 'All-Day Event 1',
          start: now,
          duration: const Duration(days: 1),
          title: 'All-Day Event 1',
        );
        final otherEvent = CustomAllDayEvent(
          id: 'All-Day Event 2',
          start: now,
          duration: const Duration(days: 1),
          title: 'All-Day Event 2',
        );

        final view = Material(
          child: WeekView(
            controller: controller,
            events: [event, otherEvent],
            allDayEventsTheme: const AllDayEventsTheme(
              listMaxRowsVisible: 1,
            ),
            eventBuilders: {
              CustomAllDayEvent: (context, e) {
                final event = e as CustomAllDayEvent;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                    ),
                  ),
                  child: Text('${event.title}_custom'),
                );
              }
            },
            allDayEventsShowMoreBuilder: (visible, all) {
              return Text('+${all.length - visible.length}');
            },
          ),
        );

        await widgetTester.pumpWidget(runTestApp(view));

        await widgetTester.pumpAndSettle();

        expect(find.text('+1'), findsAny);
      },
      skip: false,
    );

    testWidgets(
      'Custom All-Day events show more button callback is called when tapped',
      (widgetTester) async {
        final event = CustomAllDayEvent(
          id: 'All-Day Event 1',
          start: now,
          duration: const Duration(days: 1),
          title: 'All-Day Event 1',
        );
        final otherEvent = CustomAllDayEvent(
          id: 'All-Day Event 2',
          start: now,
          duration: const Duration(days: 1),
          title: 'All-Day Event 2',
        );
        final otherEvent2 = CustomAllDayEvent(
          id: 'All-Day Event 3',
          start: now,
          duration: const Duration(days: 1),
          title: 'All-Day Event 3',
        );

        var visibleEvents = <AllDayCalendarEvent>[];
        var allEvents = <AllDayCalendarEvent>[];
        final view = Material(
          child: WeekView(
            controller: controller,
            events: [event, otherEvent, otherEvent2],
            eventBuilders: {
              CustomAllDayEvent: (context, e) {
                final event = e as CustomAllDayEvent;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                    ),
                  ),
                  child: Text('${event.title}_custom'),
                );
              }
            },
            onAllDayEventsShowMoreTap: (visible, all) {
              visibleEvents = visible;
              allEvents = all;
            },
          ),
        );

        when(() => controller.state)
            .thenReturn(initialStateWithDate(event.start));

        await widgetTester.pumpWidget(runTestApp(view));

        await widgetTester.pumpAndSettle();

        expect(find.text('${event.title}_custom'), findsAny);
        expect(find.text('${event.title}_custom'), findsAny);
        expect(find.text('${otherEvent2.title}_custom'), findsNothing);

        await widgetTester.tap(find.text('+1').first);

        expect(visibleEvents, [event, otherEvent]);
        expect(allEvents, [event, otherEvent, otherEvent2]);
      },
      skip: false,
    );

    testWidgets(
      'Custom All-Day events changes when switching to another week',
      (widgetTester) async {
        final event = CustomAllDayEvent(
          id: 'All-Day Event 1',
          start: now,
          duration: const Duration(days: 1),
          title: 'All-Day Event 1',
        );
        final otherEvent = CustomAllDayEvent(
          id: 'All-Day Event 2',
          start: now.add(const Duration(days: 7)),
          duration: const Duration(days: 1),
          title: 'All-Day Event 2',
        );
        final otherEvent2 = CustomAllDayEvent(
          id: 'All-Day Event 3',
          start: now.add(const Duration(days: 7)),
          duration: const Duration(days: 1),
          title: 'All-Day Event 3',
        );

        var visibleEvents = <AllDayCalendarEvent>[];
        var allEvents = <AllDayCalendarEvent>[];
        final view = Material(
          child: WeekView(
            controller: controller,
            events: [event, otherEvent, otherEvent2],
            allDayEventsTheme: const AllDayEventsTheme(
              listMaxRowsVisible: 1,
            ),
            eventBuilders: {
              CustomAllDayEvent: (context, e) {
                final event = e as CustomAllDayEvent;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                    ),
                  ),
                  child: Text('${event.title}_custom'),
                );
              },
            },
            onAllDayEventsShowMoreTap: (visible, all) {
              visibleEvents = visible;
              allEvents = all;
            },
          ),
        );

        when(() => controller.state).thenReturn(
          withClock(
            clock,
            () => WeekViewNextWeekSelected(focusedDate: nextWeek),
          ),
        );
        await widgetTester.pumpWidget(runTestApp(view));

        await widgetTester.pumpAndSettle();

        expect(find.text('${event.title}_custom'), findsNothing);
        expect(find.text('${otherEvent.title}_custom'), findsAny);
        expect(find.text('${otherEvent2.title}_custom'), findsNothing);

        await widgetTester.tap(find.text('+1').first);

        expect(visibleEvents, [otherEvent]);
        expect(allEvents, [otherEvent, otherEvent2]);
      },
      skip: false,
    );
  });
}
