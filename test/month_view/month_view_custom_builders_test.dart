import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../common/custom_calendar_event.dart';
import 'month_view_controller.dart';

void main() {
  MaterialApp runTestApp(Widget view) => MaterialApp(
        home: Scaffold(
          body: view,
        ),
      );

  group('MonthView test', () {
    final now = DateTime(2024, DateTime.january, 3, 12);
    final daysInCurrentMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final currentMonth = DateTime(now.year, now.month);
    final currentMonthEnd = DateTime(now.year, now.month, daysInCurrentMonth);

    late MonthViewController controller;

    setUp(() {
      controller = MockMonthViewController();
      setupMonthViewController(
        controller: controller,
        now: now,
        currentMonth: currentMonth,
        currentMonthEnd: currentMonthEnd,
      );
    });

    tearDown(() {
      controller.close();
    });

    testWidgets(
      'custom Month picker displays current month',
      (widgetTester) async {
        final formatter = DateFormat('MMMM yyyy dd');
        final view = MonthView(
          controller: controller,
          monthPickerBuilder: (context, prev, next, date) {
            return Text(
              formatter.format(date),
            );
          },
        );
        await widgetTester.pumpWidget(runTestApp(view));

        expect(
          find.text(formatter.format(now)),
          findsOneWidget,
          reason: 'Month picker must display current month name and year',
        );
      },
      skip: false,
    );

    testWidgets(
      'Tap on an custom event view returns the event',
      (widgetTester) async {
        FloatingCalendarEvent? tappedEvent;

        final event = CustomCalendarEvent(
          id: const ValueKey('event1'),
          title: 'Event 1',
          start: DateTime(now.year, now.month, 5),
          duration: const Duration(days: 1),
          color: Colors.black,
        );

        final view = MonthView<CustomCalendarEvent>(
          controller: controller,
          events: [event],
          onEventTap: (event) {
            tappedEvent = event;
          },
          eventBuilders: {
            CustomCalendarEvent: (context, e) {
              final event = e as CustomCalendarEvent;
              return Container(
                key: ValueKey(event.id),
                child: Text('${event.title}_custom'),
              );
            },
          },
        );

        await widgetTester.pumpWidget(runTestApp(view));

        final eventWidget = find.text('${event.title}_custom').first;

        await widgetTester.tap(eventWidget);

        expect(tappedEvent, event);
      },
      skip: false,
    );

    testWidgets(
      'Long press on an custom event creates overlay entry',
      (widgetTester) async {
        final event = CustomCalendarEvent(
          id: const ValueKey('event1'),
          title: 'Event 1',
          start: DateTime(now.year, now.month, 5),
          duration: const Duration(days: 1),
          color: Colors.black,
        );

        final view = MonthView<CustomCalendarEvent>(
          controller: controller,
          events: [event],
          eventBuilders: {
            CustomCalendarEvent: (context, e) {
              final event = e as CustomCalendarEvent;
              return Container(
                key: ValueKey(event.id),
                child: Text('${event.title}_custom'),
              );
            },
          },
        );

        await widgetTester.pumpWidget(runTestApp(view));

        final eventKey = MonthViewKeys.events[event]!;
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
      'Long press on an custom event creates saver',
      (widgetTester) async {
        final saverKey = GlobalKey();
        final event = CustomCalendarEvent(
          id: const ValueKey('event1'),
          title: 'Event 1',
          start: DateTime(now.year, now.month, 5),
          duration: const Duration(days: 1),
          color: Colors.black,
        );

        final view = MonthView<CustomCalendarEvent>(
          controller: controller,
          events: [event],
          saverConfig: SaverConfig(
            child: Container(
              key: saverKey,
              child: const Icon(
                Icons.check,
              ),
            ),
          ),
          eventBuilders: {
            CustomCalendarEvent: (context, e) {
              final event = e as CustomCalendarEvent;
              return Container(
                key: ValueKey(event.id),
                child: Text('${event.title}_custom'),
              );
            },
          },
        );

        await widgetTester.pumpWidget(runTestApp(view));

        final eventKey = MonthViewKeys.events[event]!;
        expect(
          find.byKey(DraggableEventOverlayKeys.elevatedEvent),
          findsNothing,
        );

        await widgetTester.longPress(find.byKey(eventKey));
        await widgetTester.pumpAndSettle();

        final gesture = await widgetTester.startGesture(
          widgetTester.getCenter(
            find.byKey(DraggableEventOverlayKeys.elevatedEvent).first,
          ),
        );
        await widgetTester.pump();

        await gesture.moveTo(
          widgetTester.getCenter(find.text('19')),
        );

        await widgetTester.pumpAndSettle();

        await gesture.up();

        await widgetTester.pumpAndSettle();

        expect(
          find.byKey(saverKey),
          findsOneWidget,
        );
      },
      skip: false,
    );

    testWidgets(
      'On click saver on an custom event, event is updated',
      (widgetTester) async {
        final saverKey = GlobalKey();
        final event = CustomCalendarEvent(
          id: const ValueKey('event1'),
          title: 'Event 1',
          start: DateTime(now.year, now.month, 5),
          duration: const Duration(days: 1),
          color: Colors.black,
        );

        CustomCalendarEvent? updatedEvent;
        final view = MonthView<CustomCalendarEvent>(
          controller: controller,
          events: [event],
          saverConfig: SaverConfig(
            child: Container(
              key: saverKey,
              child: const Icon(
                Icons.check,
              ),
            ),
          ),
          onEventUpdated: (event) {
            updatedEvent = event;
          },
          eventBuilders: {
            CustomCalendarEvent: (context, e) {
              final event = e as CustomCalendarEvent;
              return Container(
                key: ValueKey(event.id),
                child: Text('${event.title}_custom'),
              );
            },
          },
        );

        await widgetTester.pumpWidget(runTestApp(view));

        final eventKey = MonthViewKeys.events[event]!;
        expect(
          find.byKey(DraggableEventOverlayKeys.elevatedEvent),
          findsNothing,
        );

        await widgetTester.longPress(find.byKey(eventKey));
        await widgetTester.pumpAndSettle();

        final gesture = await widgetTester.startGesture(
          widgetTester.getCenter(
            find.byKey(DraggableEventOverlayKeys.elevatedEvent).first,
          ),
        );
        await widgetTester.pump();

        await gesture.moveTo(
          widgetTester.getCenter(find.text('19')),
        );

        await widgetTester.pumpAndSettle();

        await gesture.up();

        await widgetTester.pumpAndSettle();

        expect(
          find.byKey(saverKey),
          findsOneWidget,
        );

        await widgetTester.tapAt(
          widgetTester.getCenter(
            find.byKey(saverKey),
          ),
        );
        await widgetTester.pumpAndSettle();

        expect(updatedEvent, event);
      },
      skip: false,
    );

    testWidgets(
      'Long press on an custom event view returns the event',
      (widgetTester) async {
        final event = CustomCalendarEvent(
          id: const ValueKey('event1'),
          title: 'Event 1',
          start: DateTime(now.year, now.month, 5),
          duration: const Duration(days: 1),
          color: Colors.black,
        );

        CustomCalendarEvent? tappedEvent;
        final view = MonthView<CustomCalendarEvent>(
          controller: controller,
          events: [event],
          overrideOnEventLongPress: (details, event) {
            tappedEvent = event;
          },
          eventBuilders: {
            CustomCalendarEvent: (context, e) {
              final event = e as CustomCalendarEvent;
              return Container(
                key: ValueKey(event.id),
                child: Text('${event.title}_custom'),
              );
            },
          },
        );

        await widgetTester.pumpWidget(runTestApp(view));

        final eventWidget = find.text('${event.title}_custom').first;

        await widgetTester.longPress(eventWidget);

        await widgetTester.pumpAndSettle();

        expect(tappedEvent, event);
      },
      skip: false,
    );

    testWidgets(
      'On release long press on an custom event, event is updated',
      (widgetTester) async {
        final saverKey = GlobalKey();
        final event = CustomCalendarEvent(
          id: const ValueKey('event1'),
          title: 'Event 1',
          start: DateTime(now.year, now.month, 5),
          duration: const Duration(days: 1),
          color: Colors.black,
        );

        CustomCalendarEvent? updatedEvent;
        final view = MonthView<CustomCalendarEvent>(
          controller: controller,
          events: [event],
          saverConfig: SaverConfig(
            child: Container(
              key: saverKey,
              child: const Icon(
                Icons.check,
              ),
            ),
          ),
          onEventUpdated: (event) {
            updatedEvent = event;
          },
          enableFloatingEvents: false,
          eventBuilders: {
            CustomCalendarEvent: (context, e) {
              final event = e as CustomCalendarEvent;
              return Container(
                key: ValueKey(event.id),
                child: Text('${event.title}_custom'),
              );
            },
          },
        );

        await widgetTester.pumpWidget(runTestApp(view));

        expect(
          find.byKey(DraggableEventOverlayKeys.elevatedEvent),
          findsNothing,
        );

        await widgetTester.pumpAndSettle();

        final start = widgetTester.getCenter(
          find.byKey(ValueKey(event.id)),
        );
        final end = widgetTester.getCenter(find.text('19'));

        await widgetTester.timedDragFrom(
          start,
          end - start,
          const Duration(seconds: 5),
          pointer: 7,
        );

        await widgetTester.pump();
        await widgetTester.pumpAndSettle();
        expect(
          find.byKey(saverKey),
          findsNothing,
        );

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

        expect(updatedEvent?.id, event.id);
      },
      skip: false,
    );
  });
}
