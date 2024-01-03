import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMonthViewController extends MockCubit<MonthViewState>
    implements MonthViewController {}

void main() {
  MaterialApp runTestApp(Widget view) => MaterialApp(home: view);

  group('MonthView test', () {
    final now = DateTime(2024, DateTime.january, 3, 12);
    final daysInCurrentMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final currentMonth = DateTime(now.year, now.month);
    final currentMonthEnd = DateTime(now.year, now.month, daysInCurrentMonth);

    late MonthViewController controller;

    MonthViewInitial initialStateWithDate(DateTime date) => withClock(
          Clock.fixed(date), // It's needed to mock clock.now() return value
          MonthViewInitial.new,
        );

    setUp(() {
      controller = MockMonthViewController();
    });

    tearDown(() {
      controller.close();
    });

    testWidgets(
      'Month picker displays current month',
      (widgetTester) async {
        const year = 2024;
        const month = DateTime.january;
        final daysInMonth = DateUtils.getDaysInMonth(year, month);
        final view = MonthView(
          controller: controller,
          saverConfig: _saverConfig(),
        );

        when(() => controller.initialDate).thenReturn(DateTime(year));
        when(() => controller.endDate)
            .thenReturn(DateTime(year, month, daysInMonth));
        when(() => controller.state)
            .thenReturn(initialStateWithDate(DateTime(year, month, 10)));

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
          saverConfig: _saverConfig(),
          onDateLongPress: (date) {
            pressedDate = date;
            return Future.value();
          },
        );

        when(() => controller.initialDate).thenReturn(currentMonth);
        when(() => controller.endDate).thenReturn(currentMonthEnd);
        when(() => controller.state).thenReturn(initialStateWithDate(now));

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
      'On tap event',
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
          saverConfig: _saverConfig(),
          events: [event],
          onEventTap: (event) {
            tappedEvent = event;
          },
        );

        when(() => controller.initialDate).thenReturn(currentMonth);
        when(() => controller.endDate).thenReturn(currentMonthEnd);
        when(() => controller.state).thenReturn(initialStateWithDate(now));

        await widgetTester.pumpWidget(runTestApp(view));

        final eventWidget =
            find.widgetWithText(SimpleEventView, 'Event 1').first;

        await widgetTester.tap(eventWidget);

        expect(tappedEvent, event);
      },
      skip: false,
    );

    // testWidgets(
    //   'On event changed date',
    //   (widgetTester) async {
    //     FloatingCalendarEvent? updatedEvent;
    //
    //     final event = SimpleEvent(
    //       id: const ValueKey('event1'),
    //       title: 'Event 1',
    //       start: DateTime(now.year, now.month, 5),
    //       duration: const Duration(days: 1),
    //     );
    //
    //     final view = MonthView<SimpleEvent>(
    //       controller: controller,
    //       saverConfig: _saverConfig(),
    //       events: [event],
    //       breaks: [],
    //       onEventTap: (e) {
    //         print(e);
    //       },
    //       onEventUpdated: (event) {
    //         updatedEvent = event;
    //       },
    //     );
    //
    //     when(() => controller.initialDate).thenReturn(currentMonth);
    //     when(() => controller.endDate).thenReturn(currentMonthEnd);
    //     when(() => controller.state).thenReturn(initialStateWithDate(now));
    //
    //     await widgetTester.pumpWidget(runTestApp(view));
    //
    //     final eventWidget = find.widgetWithText(SimpleEventView, 'Event 1')
    //          .first;
    //
    //     print("before");
    //     final from = widgetTester.getCenter(eventWidget);
    //     print(from);
    //     print("to");
    //     final to = const Offset(0, 100) + from;
    //     print(to);
    //
    //     await widgetTester.longPressAt(widgetTester.getCenter(eventWidget));
    //
    //     await widgetTester.dragFrom(
    //       from,
    //       to,
    //     );
    //
    //     print("after");
    //     print(widgetTester.getCenter(eventWidget));
    //
    //     final saverWidget = find.byType(Saver);
    //
    //     await widgetTester.tapAt(widgetTester.getCenter(saverWidget));
    //
    //     expect(updatedEvent, event);
    //   },
    //   skip: false,
    // );
  });
}

SaverConfig _saverConfig() => SaverConfig(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: const Icon(Icons.done),
      ),
    );
