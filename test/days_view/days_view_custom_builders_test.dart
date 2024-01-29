import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

import '../common/custom_calendar_event.dart';
import 'days_view_controller.dart';

void main() {
  MaterialApp runTestApp(Widget view) => MaterialApp(home: view);

  group(
    'DaysView custom builders test',
    () {
      final now = DateTime(2022, DateTime.november, 10, 9, 45);
      final daysInCurrentMonth = DateUtils.getDaysInMonth(now.year, now.month);
      final currentMonth = DateTime(now.year, now.month);
      final currentMonthEnd = DateTime(now.year, now.month, daysInCurrentMonth);
      final nextMonth = DateTime(now.year, now.month + 1);
      final today = DateTime(now.year, now.month, now.day);
      final daysInNextMonth =
          DateUtils.getDaysInMonth(nextMonth.year, nextMonth.month);
      final nextMonthEnd =
          DateTime(nextMonth.year, nextMonth.month, daysInNextMonth);

      late DaysViewController controller;

      setUp(() {
        controller = MockDaysViewController();
        setupDaysViewController(
          controller: controller,
          currentMonth: currentMonth,
          currentMonthEnd: currentMonthEnd,
          now: now,
        );
      });

      tearDown(() async {
        await controller.close();
      });

      testWidgets(
        'Custom Month picker displays current month',
        (widgetTester) async {
          final view = DaysView(
            controller: controller,
            monthPickerBuilder: (context, date, events) {
              return Text(
                DateFormat.yMMMEd().format(date),
              );
            },
          );

          await widgetTester.pumpWidget(runTestApp(view));

          expect(
            find.text(
              DateFormat.yMMMEd().format(now),
            ),
            findsOneWidget,
            reason: 'Month picker must display current month name and year',
          );
        },
        skip: false,
      );

      testWidgets(
        'Custom days row builder',
        (widgetTester) async {
          final view = DaysView(
            controller: controller,
            daysListBuilder: (context, day, events) {
              return Column(
                children: [
                  Text(
                    DateFormat.Md().format(day),
                  ),
                  Text(
                    'Events: ${events.length}',
                  ),
                ],
              );
            },
          );

          await widgetTester.pumpWidget(runTestApp(view));

          expect(
            find.text(
              DateFormat.Md().format(today),
            ),
            findsOneWidget,
          );

          expect(find.text('Events: 0'), findsOneWidget);
        },
        skip: false,
      );

      testWidgets(
        'Tap on an custom event view returns the event',
        (widgetTester) async {
          FloatingCalendarEvent? tappedEvent;
          FloatingCalendarEvent? tappedCustomEvents;

          final event = CustomCalendarEvent(
            id: 'SimpleEvent1',
            start: now,
            duration: const Duration(hours: 1),
            title: '',
            color: Colors.redAccent,
          );
          final view = DaysView<FloatingCalendarEvent>(
            controller: controller,
            onEventTap: (event) => tappedEvent = event,
            events: [event],
            eventBuilders: {
              CustomCalendarEvent: (context, e) {
                final event = e as CustomCalendarEvent;
                return InkWell(
                  onTap: () => tappedCustomEvents = event,
                  child: Text('${event.title}_custom'),
                );
              },
            },
          );
          await widgetTester.pumpWidget(runTestApp(view));

          final eventKey = DaysViewKeys.events[event]!;
          await widgetTester.tap(find.byKey(eventKey));
          expect(tappedEvent, null);
          expect(tappedCustomEvents, event);
          expect(find.text('${event.title}_custom'), findsOneWidget);
        },
        skip: false,
      );

      testWidgets(
        'Custom elevated event rect is expanded to the layout area rect',
        (widgetTester) async {
          final event = CustomCalendarEvent(
            id: 'SimpleEvent1',
            start: now,
            duration: const Duration(hours: 1),
            title: 'Custom Event',
            color: Colors.redAccent,
          );
          final view = DaysView(
            controller: controller,
            events: [event],
            eventBuilders: {
              CustomCalendarEvent: (context, e) {
                final event = e as CustomCalendarEvent;
                return InkWell(
                  onTap: () => print('${event.title}_custom'),
                  child: Text('${event.title}_custom'),
                );
              },
            },
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final eventKey = DaysViewKeys.events[event]!;
          final eventFinder = find.byKey(eventKey);
          final eventRect = widgetTester.getRect(eventFinder);
          final layoutKey = DaysViewKeys.layouts[today]!;
          final layoutFinder = find.byKey(layoutKey);
          final layoutRect = widgetTester.getRect(layoutFinder);
          final elevatedEventFinder =
              find.byKey(DraggableEventOverlayKeys.elevatedEvent);

          await widgetTester.longPress(eventFinder);

          expect(widgetTester.getRect(elevatedEventFinder), eventRect);

          await widgetTester.pumpAndSettle();

          expect(
            widgetTester.getRect(elevatedEventFinder),
            Rect.fromLTWH(
              layoutRect.left,
              eventRect.top,
              layoutRect.width,
              eventRect.height,
            ),
            reason: "Elevated event width doesn't fill the layout width",
          );
        },
        skip: false,
      );

      testWidgets(
        'Custom elevated event is disappeared after it is dropped',
        (widgetTester) async {
          final event = CustomCalendarEvent(
            id: 'SimpleEvent1',
            start: now,
            duration: const Duration(hours: 1),
            title: '',
            color: Colors.redAccent,
          );
          final view = DaysView(
            controller: controller,
            events: [event],
            eventBuilders: {
              CustomCalendarEvent: (context, e) {
                final event = e as CustomCalendarEvent;
                return InkWell(
                  onTap: () => print('${event.title}_custom'),
                  child: Text('${event.title}_custom'),
                );
              },
            },
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final eventKey = DaysViewKeys.events[event]!;

          await widgetTester.longPress(find.byKey(eventKey));
          await widgetTester.pumpAndSettle();

          final elevatedEventFinder =
              find.byKey(DraggableEventOverlayKeys.elevatedEvent);

          expect(elevatedEventFinder, findsOneWidget);

          final tapLocation = widgetTester.getBottomLeft(elevatedEventFinder) +
              const Offset(1, 1);

          await widgetTester.tapAt(tapLocation);
          await widgetTester.pumpAndSettle();

          expect(elevatedEventFinder, findsNothing);
        },
        skip: false,
      );

      testWidgets(
        'Switching to another month changes the custom days list',
        (widgetTester) async {
          final view = DaysView<FloatingCalendarEvent>(
            controller: controller,
            daysListBuilder: (context, day, events) {
              return Material(
                child: Column(
                  children: [
                    Text(
                      DateFormat.Md().format(day),
                    ),
                    Text(
                      'Events: ${events.length}',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          );

          when(() => controller.initialDate).thenReturn(currentMonth);
          when(() => controller.endDate).thenReturn(
            nextMonthEnd,
          );
          whenListen(
            controller,
            Stream<DaysViewState>.fromIterable([
              initialStateWithDate(now),
              DaysViewNextMonthSelected(
                displayedDate: nextMonth,
                focusedDate: nextMonth,
              ),
            ]),
            initialState: initialStateWithDate(now),
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final todayItemFinder = find.text(
            DateFormat.Md().format(today),
          );

          expect(todayItemFinder, findsOneWidget);
        },
        skip: false,
      );

      testWidgets(
        'Switching to another month changes the custom month picker',
        (widgetTester) async {
          final view = DaysView<FloatingCalendarEvent>(
            controller: controller,
            monthPickerBuilder: (context, date, events) {
              return Material(
                child: Column(
                  children: [
                    Text(
                      DateFormat.Md().format(date),
                    ),
                    Text(
                      'Events: ${events.length}',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          );

          when(() => controller.initialDate).thenReturn(currentMonth);
          when(() => controller.endDate).thenReturn(
            nextMonthEnd,
          );
          whenListen(
            controller,
            Stream<DaysViewState>.fromIterable([
              initialStateWithDate(now),
              DaysViewNextMonthSelected(
                displayedDate: nextMonth,
                focusedDate: nextMonth,
              ),
            ]),
            initialState: initialStateWithDate(now),
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final todayItemFinder = find.text(
            DateFormat.Md().format(today),
          );

          expect(todayItemFinder, findsOneWidget);
        },
        skip: false,
      );

      testWidgets(
        'On release long press on an custom event, event is updated',
        (widgetTester) async {
          final event = CustomCalendarEvent(
            id: const ValueKey('event1'),
            title: 'Event 1',
            start: now,
            duration: const Duration(hours: 3),
            color: Colors.black,
          );

          CustomCalendarEvent? updatedEvent;
          final view = DaysView<CustomCalendarEvent>(
            controller: controller,
            events: [event],
            onEventUpdated: (event) {
              updatedEvent = event;
            },
            enableFloatingEvents: false,
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
          await widgetTester.pumpAndSettle();

          final eventKey = DaysViewKeys.events[event]!;
          expect(
            find.byKey(DraggableEventOverlayKeys.elevatedEvent),
            findsNothing,
          );

          await widgetTester.pumpAndSettle();

          final start = widgetTester.getCenter(
            find.byKey(eventKey).first,
          );
          final end = start + const Offset(50, 0);
          await widgetTester.timedDragFrom(
            start,
            start - end,
            const Duration(seconds: 2),
          );

          await widgetTester.pump();
          await widgetTester.pumpAndSettle();

          final gesture2 = await widgetTester.startGesture(
            start,
          );
          await widgetTester.pump();

          await gesture2.moveTo(
            end,
          );

          await widgetTester.pumpAndSettle();

          await gesture2.up();

          await widgetTester.pumpAndSettle();

          expect(updatedEvent, event);
        },
        skip: false,
      );
    },
    skip: false,
  );
}
