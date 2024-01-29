import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

import 'days_view_controller.dart';

void main() {
  MaterialApp runTestApp(Widget view) => MaterialApp(home: view);

  group(
    'DaysView test',
    () {
      final now = DateTime(2022, DateTime.november, 10, 9, 45);
      final daysInCurrentMonth = DateUtils.getDaysInMonth(now.year, now.month);
      final currentMonth = DateTime(now.year, now.month);
      final currentMonthEnd = DateTime(now.year, now.month, daysInCurrentMonth);
      final currentHour = DateTime(now.year, now.month, now.day, now.hour);
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
        'Month picker displays current month',
        (widgetTester) async {
          final view = DaysView(
            controller: controller,
          );

          await widgetTester.pumpWidget(runTestApp(view));

          expect(
            find.widgetWithText(
              DisplayedPeriodPicker,
              DateFormat('MMMM yyyy').format(now),
            ),
            findsOneWidget,
            reason: 'Month picker must display current month name and year',
          );
        },
        skip: false,
      );

      testWidgets(
        'Current day is focused',
        (widgetTester) async {
          final view = DaysView(
            controller: controller,
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final todayFinder = find.widgetWithText(
            DaysListItem,
            now.day.toString(),
          );

          expect(todayFinder, findsOneWidget);

          final todayItem = widgetTester.widget<DaysListItem>(todayFinder);

          expect(todayItem.isFocused, isTrue);
        },
        skip: false,
      );

      testWidgets(
        'Long press a time point on the timeline returns the time point',
        (widgetTester) async {
          DateTime? pressedDate;

          final view = DaysView(
            controller: controller,
            onDateLongPress: (date) {
              pressedDate = date;
              return Future.value();
            },
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final padding = view.timelineTheme.padding;
          final currentHourOrigin = Offset(padding.left, padding.top);
          final currentHourPosition =
              widgetTester.getTopLeft(find.byKey(DaysViewKeys.timeline)) +
                  currentHourOrigin;

          await widgetTester.longPressAt(currentHourPosition);

          expect(pressedDate, currentHour);
        },
        skip: false,
      );

      testWidgets(
        'Tap on an event view returns the event',
        (widgetTester) async {
          FloatingCalendarEvent? tappedEvent;

          final event = SimpleEvent(
            id: 'SimpleEvent1',
            start: now,
            duration: const Duration(hours: 1),
            title: '',
          );
          final view = DaysView<FloatingCalendarEvent>(
            controller: controller,
            onEventTap: (event) => tappedEvent = event,
            events: [event],
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final eventKey = DaysViewKeys.events[event]!;

          await widgetTester.tap(find.byKey(eventKey));

          expect(tappedEvent, event);
        },
        skip: false,
      );

      testWidgets(
        'Create an elevated event view on the event long press',
        (widgetTester) async {
          final event = SimpleEvent(
            id: 'SimpleEvent1',
            start: now,
            duration: const Duration(hours: 1),
            title: '',
          );
          final view = DaysView(
            controller: controller,
            events: [event],
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final eventKey = DaysViewKeys.events[event]!;

          expect(
            find.byKey(DraggableEventOverlayKeys.elevatedEvent),
            findsNothing,
          );

          await widgetTester.longPress(find.byKey(eventKey));

          expect(
            find.byKey(DraggableEventOverlayKeys.elevatedEvent),
            findsOneWidget,
          );
        },
        skip: false,
      );

      testWidgets(
        'Does not create an elevated event view on the event long press'
        ' when onLongPress is overridden',
        (widgetTester) async {
          final event = SimpleEvent(
            id: 'SimpleEvent1',
            start: now,
            duration: const Duration(hours: 1),
            title: '',
            color: Colors.black,
          );
          FloatingCalendarEvent? tappedEvent;
          final view = DaysView(
            controller: controller,
            events: [event],
            overrideOnEventLongPress: (
              details,
              event,
            ) {
              tappedEvent = event;
            },
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final eventKey = DaysViewKeys.events[event]!;

          expect(
            find.byKey(DraggableEventOverlayKeys.elevatedEvent),
            findsNothing,
          );

          await widgetTester.longPress(find.byKey(eventKey));

          expect(
            find.byKey(DraggableEventOverlayKeys.elevatedEvent),
            findsNothing,
          );
          expect(tappedEvent, event);
        },
        skip: false,
      );

      testWidgets(
        'The elevated event rect is expanded to the layout area rect',
        (widgetTester) async {
          final event = SimpleEvent(
            id: 'SimpleEvent1',
            start: now,
            duration: const Duration(hours: 1),
            title: '',
          );
          final view = DaysView(
            controller: controller,
            events: [event],
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
        'The elevated event is disappeared after it is dropped',
        (widgetTester) async {
          final event = SimpleEvent(
            id: 'SimpleEvent1',
            start: now,
            duration: const Duration(hours: 1),
            title: '',
          );
          final view = DaysView(
            controller: controller,
            events: [event],
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
        'Switching to another month changes the days list',
        (widgetTester) async {
          final view = DaysView(
            controller: controller,
          );

          when(() => controller.initialDate).thenReturn(currentMonth);
          when(() => controller.endDate).thenReturn(nextMonthEnd);
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

          final todayItemFinder = find.widgetWithText(
            DaysListItem,
            now.day.toString(),
          );

          expect(todayItemFinder, findsOneWidget);

          final todayItemDate =
              widgetTester.widget<DaysListItem>(todayItemFinder).dayDate;
          final nextButtonChild = view.monthPickerTheme.nextButtonTheme.child;
          final nextMonthButtonFinder = find.byWidget(nextButtonChild);

          expect(nextMonthButtonFinder, findsOneWidget);

          await widgetTester.tap(nextMonthButtonFinder);
          await widgetTester.pumpAndSettle();

          final nextMonthItemFinder = find.widgetWithText(
            DaysListItem,
            nextMonth.day.toString(),
          );

          expect(nextMonthItemFinder, findsOneWidget);

          final nextMonthItemDate =
              widgetTester.widget<DaysListItem>(nextMonthItemFinder).dayDate;

          expect(DateUtils.monthDelta(todayItemDate, nextMonthItemDate), 1);
          verify(controller.next).called(1);
        },
        skip: false,
      );

      testWidgets(
        'Switching to another day scrolls the timeline',
        (widgetTester) async {
          final oneEvent = SimpleEvent(
            id: 'SimpleEvent1',
            start: currentMonth.add(const Duration(days: 5, hours: 12)),
            duration: const Duration(minutes: 45),
            title: '',
          );
          final otherEvent = SimpleEvent(
            id: 'SimpleEvent2',
            start: oneEvent.start.add(const Duration(days: 2, hours: 9)),
            duration: const Duration(hours: 1),
            title: '',
          );
          final view = DaysView(
            controller: controller,
            events: [oneEvent, otherEvent],
          );

          whenListen(
            controller,
            Stream<DaysViewState>.fromIterable([
              initialStateWithDate(oneEvent.start),
              DaysViewDaySelected(displayedDate: otherEvent.start),
            ]),
            initialState: initialStateWithDate(oneEvent.start),
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final oneEventKey = DaysViewKeys.events[oneEvent]!;

          expect(find.byKey(oneEventKey), findsOneWidget);
          expect(DaysViewKeys.events[otherEvent], isNull); // Doesn't exist

          final otherDayItemFinder = find.widgetWithText(
            DaysListItem,
            otherEvent.start.day.toString(),
          );

          expect(otherDayItemFinder, findsOneWidget);

          await widgetTester.tap(otherDayItemFinder);
          await widgetTester.pumpAndSettle();

          final otherEventKey = DaysViewKeys.events[otherEvent]!;

          expect(find.byKey(oneEventKey), findsNothing);
          expect(find.byKey(otherEventKey), findsOneWidget);
          verify(() => controller.selectDay(any())).called(1);
        },
        skip: false,
      );

      testWidgets(
        'Clicking on all day events triggers the callback',
        (widgetTester) async {
          final oneEvent = SimpleAllDayEvent(
            id: 'SimpleEvent1',
            start: today,
            duration: const Duration(days: 1),
            title: 'All-Day Event 1',
          );
          AllDayCalendarEvent? allDayEvent;
          final view = DaysView(
            controller: controller,
            events: [oneEvent],
            allDayEventsTheme: const AllDayEventsTheme(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(),
            ),
            onAllDayEventTap: (event) {
              allDayEvent = event;
            },
          );

          await widgetTester.pumpWidget(runTestApp(view));

          await widgetTester.tapAt(
            widgetTester.getCenter(
              find.text(
                'All-Day Event 1',
              ),
            ),
          );

          expect(allDayEvent, oneEvent);
        },
        skip: false,
      );

      testWidgets(
        'Clicking on all day events show more button triggers the callback',
        (widgetTester) async {
          final oneEvent = SimpleAllDayEvent(
            id: 'SimpleEvent1',
            start: today,
            duration: const Duration(days: 1),
            title: 'All-Day Event 1',
          );
          final otherEvent = SimpleAllDayEvent(
            id: 'SimpleEvent2',
            start: today,
            duration: const Duration(days: 1),
            title: 'All-Day Event 2',
          );

          var visible = <AllDayCalendarEvent>[];
          var all = <AllDayCalendarEvent>[];
          final view = Material(
            child: DaysView(
              controller: controller,
              events: [oneEvent, otherEvent],
              allDayEventsTheme: const AllDayEventsTheme(
                elevation: 0,
                margin: EdgeInsets.zero,
                listMaxRowsVisible: 1,
              ),
              onAllDayEventsShowMoreTap: (v, a) {
                visible = v;
                all = a;
              },
            ),
          );

          await widgetTester.pumpWidget(runTestApp(view));

          await widgetTester.tapAt(
            widgetTester.getCenter(
              find.text(
                '+1',
              ),
            ),
          );

          expect(all, [oneEvent, otherEvent]);
          expect(visible, [oneEvent]);
        },
        skip: false,
      );

      testWidgets(
        'Switching to another day scrolls the '
        'timeline and changes all day events',
        (widgetTester) async {
          final oneEvent = SimpleAllDayEvent(
            id: 'SimpleEvent1',
            start: today,
            duration: const Duration(days: 1),
            title: 'All-Day Event 1',
          );
          final otherEvent = SimpleAllDayEvent(
            id: 'SimpleEvent2',
            start: today.add(const Duration(days: 1)),
            duration: const Duration(days: 1),
            title: 'All-Day Event 2',
          );
          final view = DaysView(
            controller: controller,
            events: [oneEvent, otherEvent],
          );

          whenListen(
            controller,
            Stream<DaysViewState>.fromIterable([
              initialStateWithDate(oneEvent.start),
              DaysViewDaySelected(displayedDate: otherEvent.start),
            ]),
            initialState: initialStateWithDate(oneEvent.start),
          );

          await widgetTester.pumpWidget(runTestApp(view));

          final oneEventKey = DaysViewKeys.events[oneEvent]!;
          expect(find.byKey(oneEventKey), findsOneWidget);
          expect(DaysViewKeys.events[otherEvent], isNull); // Doesn't exist

          final otherDayItemFinder = find.widgetWithText(
            DaysListItem,
            otherEvent.start.day.toString(),
          );

          expect(otherDayItemFinder, findsOneWidget);

          await widgetTester.tap(otherDayItemFinder);
          await widgetTester.pumpAndSettle();

          final otherEventKey = DaysViewKeys.events[otherEvent]!;

          expect(find.byKey(oneEventKey), findsNothing);
          expect(find.byKey(otherEventKey), findsOneWidget);
          verify(() => controller.selectDay(any())).called(1);
        },
        skip: false,
      );

      testWidgets(
        'shore more button does not show when there is no more events',
        (widgetTester) async {
          final oneEvent = SimpleAllDayEvent(
            id: 'SimpleEvent1',
            start: today,
            duration: const Duration(days: 1),
            title: 'All-Day Event 1',
          );
          final otherEvent = SimpleAllDayEvent(
            id: 'SimpleEvent2',
            start: today,
            duration: const Duration(days: 1),
            title: 'All-Day Event 2',
          );
          final otherEvent2 = SimpleAllDayEvent(
            id: 'SimpleEvent3',
            start: today,
            duration: const Duration(days: 1),
            title: 'All-Day Event 3',
          );

          const showMoreKey = Key('showMore');
          final view = Material(
            child: DaysView(
              controller: controller,
              events: [oneEvent, otherEvent, otherEvent2],
              allDayEventsTheme: const AllDayEventsTheme(
                elevation: 0,
                margin: EdgeInsets.zero,
                listMaxRowsVisible: 3,
              ),
              allDayEventsShowMoreBuilder: (context, v, a) {
                return Container(
                  key: showMoreKey,
                  child: const Text('+'),
                );
              },
            ),
          );

          await widgetTester.pumpWidget(runTestApp(view));

          expect(find.byKey(showMoreKey), findsNothing);
        },
        skip: false,
      );

      testWidgets(
        'On release long press on an event, event is updated',
            (widgetTester) async {
          final event = SimpleEvent(
            id: const ValueKey('event1'),
            title: 'Event 1',
            start: now,
            duration: const Duration(hours: 3),
            color: Colors.black,
          );

          SimpleEvent? updatedEvent;
          final view = DaysView<SimpleEvent>(
            controller: controller,
            events: [event],
            onEventUpdated: (event) {
              updatedEvent = event;
            },
            enableFloatingEvents: false,
            eventBuilders: {
              SimpleEvent: (context, e) {
                final event = e as SimpleEvent;
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
