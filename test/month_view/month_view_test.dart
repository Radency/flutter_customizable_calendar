import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

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
      'Month picker displays current month',
      (widgetTester) async {
        final view = MonthView(
          controller: controller,
        );
        await widgetTester.pumpWidget(runTestApp(view));

        expect(
          find.widgetWithText(DisplayedPeriodPicker, 'January 2024'),
          findsOneWidget,
          reason: 'Month picker must display current month name and year',
        );
      },
      skip: false,
    );

    testWidgets(
      'Long press a time point on the timeline returns the time point',
      (widgetTester) async {
        DateTime? pressedDate;

        final view = MonthView(
          controller: controller,
          onDateLongPress: (date) {
            pressedDate = date;
            return Future.value();
          },
        );

        await widgetTester.pumpWidget(runTestApp(view));

        final fifthDayPosition = widgetTester.getCenter(find.text('5'));

        await widgetTester.longPressAt(fifthDayPosition);
        expect(
          DateTime(pressedDate!.year, pressedDate!.month, pressedDate!.day),
          DateTime(now.year, now.month, 5),
        );
      },
      skip: false,
    );

    testWidgets(
      'Tap on an event view returns the event',
      (widgetTester) async {
        FloatingCalendarEvent? tappedEvent;

        final event = SimpleEvent(
          id: const ValueKey('event1'),
          title: 'Event 1',
          start: DateTime(now.year, now.month, 5),
          duration: const Duration(days: 1),
        );

        final view = MonthView<SimpleEvent>(
          controller: controller,
          events: [event],
          onEventTap: (event) {
            tappedEvent = event;
          },
        );

        await widgetTester.pumpWidget(runTestApp(view));

        final eventWidget =
            find.widgetWithText(SimpleEventView, 'Event 1').first;

        await widgetTester.tap(eventWidget);

        expect(tappedEvent, event);
      },
      skip: false,
    );

    testWidgets(
      'Long press on an event creates overlay entry',
      (widgetTester) async {
        final event = SimpleEvent(
          id: const ValueKey('event1'),
          title: 'Event 1',
          start: DateTime(now.year, now.month, 5),
          duration: const Duration(days: 1),
          color: Colors.black,
        );

        final view = MonthView<SimpleEvent>(
          controller: controller,
          events: [event],
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
      'Long press on an event creates saver',
      (widgetTester) async {
        final saverKey = GlobalKey();
        final event = SimpleEvent(
          id: const ValueKey('event1'),
          title: 'Event 1',
          start: DateTime(now.year, now.month, 5),
          duration: const Duration(days: 1),
          color: Colors.black,
        );

        final view = MonthView<SimpleEvent>(
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
      'On click saver on an event, event is updated',
      (widgetTester) async {
        final saverKey = GlobalKey();
        final event = SimpleEvent(
          id: const ValueKey('event1'),
          title: 'Event 1',
          start: DateTime(now.year, now.month, 5),
          duration: const Duration(days: 1),
          color: Colors.black,
        );

        SimpleEvent? updatedEvent;
        final view = MonthView<SimpleEvent>(
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
            SimpleEvent: (context, e) {
              final event = e as SimpleEvent;
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
  });
}
