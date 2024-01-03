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

  group("MonthView test", () {
    final now = DateTime(2024, DateTime.january, 3, 12, 0);
    final daysInCurrentMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final currentMonth = DateTime(now.year, now.month);
    final currentMonthEnd = DateTime(now.year, now.month, daysInCurrentMonth);
    final currentMonthDay = DateTime(now.year, now.month, now.day);
    final nextMonth = DateTime(now.year, now.month + 1);
    final daysInNextMonth =
        DateUtils.getDaysInMonth(nextMonth.year, nextMonth.month);
    final nextMonthEnd =
        DateTime(nextMonth.year, nextMonth.month, daysInNextMonth);

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

        when(() => controller.initialDate).thenReturn(DateTime(year, month));
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

    // testWidgets(
    //   'Change event date',
    //   (widgetTester) async {
    //     SimpleEvent event = SimpleEvent(
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
    //       onEventUpdated: (updatedEvent) {
    //         event = updatedEvent;
    //       },
    //     );
    //
    //     print(view.events);
    //
    //     when(() => controller.initialDate).thenReturn(currentMonth);
    //     when(() => controller.endDate).thenReturn(currentMonthEnd);
    //     when(() => controller.state).thenReturn(initialStateWithDate(now));
    //
    //     await widgetTester.pumpWidget(runTestApp(view));
    //     await widgetTester.pumpAndSettle();
    //
    //     print(MonthViewKeys.events);
    //     print(MonthViewKeys.events[event.id]);
    //     final eventKey = MonthViewKeys.events[event.id];
    //     final eventFinder = find.byKey(eventKey!);
    //
    //     final eventPosition = widgetTester.getCenter(eventFinder);
    //     // await widgetTester.longPressAt(eventPosition);
    //
    //     // final seventhDayPosition = widgetTester.getCenter(find.text('7'));
    //     //
    //     // await widgetTester.drag(
    //     //     find.bySubtype<Draggable>(), seventhDayPosition);
    //     //
    //     // final saverPosition = widgetTester.getCenter(eventFinder);
    //     // await widgetTester.tapAt(saverPosition);
    //     //
    //     // expect(
    //     //   event.start,
    //     //   DateTime(now.year, now.month, 7),
    //     // );
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
