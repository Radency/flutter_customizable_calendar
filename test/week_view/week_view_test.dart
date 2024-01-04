import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekViewController extends MockCubit<WeekViewState>
    implements WeekViewController {}

void main() {
  MaterialApp runTestApp(Widget view) => MaterialApp(home: view);

  group('WeekView test', () {
    final now = DateTime(2024, DateTime.january, 3, 12);

    final currentWeek = DateTime(now.year, now.month);
    final currentWeekEnd = DateTime(now.year, now.month, 7);
    final nextWeek = DateTime(now.year, now.month, 14);
    final currentMonth = DateTime(now.year, now.month);
    final daysInCurrentMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final currentMonthEnd = DateTime(now.year, now.month, daysInCurrentMonth);

    late WeekViewController controller;

    WeekViewInitial initialStateWithDate(DateTime date) => withClock(
          Clock.fixed(date), // It's needed to mock clock.now() return value
          WeekViewInitial.new,
        );

    setUp(() {
      controller = MockWeekViewController();
    });

    tearDown(() {
      controller.close();
    });

    testWidgets('Week picker displays current week', (widgetTester) async {
      const year = 2024;
      const month = DateTime.january;
      const day = 3;
      final view = WeekView(
        controller: controller,
        saverConfig: _saverConfig(),
      );

      when(() => controller.initialDate).thenReturn(DateTime(year, month, day));
      when(() => controller.endDate).thenReturn(DateTime(year, month, day));
      when(() => controller.state)
          .thenReturn(initialStateWithDate(DateTime(year, month, day)));

      await widgetTester.pumpWidget(runTestApp(view));

      expect(
        find.widgetWithText(DisplayedPeriodPicker, '1 - 7 Jan, 2024'),
        findsOneWidget,
        reason: 'Week picker should display ‘current week',
      );
    });

    testWidgets(
      'Long press a time point on the timeline returns the time point',
      (widgetTester) async {
        DateTime? pressedDate;

        final view = WeekView(
          controller: controller,
          saverConfig: _saverConfig(),
          onDateLongPress: (date) {
            pressedDate = date;
            return Future.value();
          },
        );

        when(() => controller.initialDate).thenReturn(currentWeek);
        when(() => controller.endDate).thenReturn(currentWeekEnd);
        when(() => controller.state).thenReturn(initialStateWithDate(now));

        await widgetTester.pumpWidget(runTestApp(view));

        final padding = view.timelineTheme.padding;
        final currentHourOrigin = Offset(padding.left, padding.top);
        final currentHourPosition =
            widgetTester.getTopLeft(find.byKey(WeekViewKeys.timeline!)) +
                currentHourOrigin;

        await widgetTester.longPressAt(currentHourPosition);

        expect(
          DateTime(pressedDate!.year, pressedDate!.month, pressedDate!.day),
          DateTime(now.year, now.month),
        );
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
        final view = WeekView<FloatingCalendarEvent>(
          controller: controller,
          saverConfig: _saverConfig(),
          onEventTap: (event) => tappedEvent = event,
          events: [event],
        );

        when(() => controller.initialDate).thenReturn(currentWeek);
        when(() => controller.endDate).thenReturn(currentWeekEnd);
        when(() => controller.state)
            .thenReturn(initialStateWithDate(event.start));

        await widgetTester.pumpWidget(runTestApp(view));

        final eventKey = WeekViewKeys.events[event]!;

        await widgetTester.tap(find.byKey(eventKey));

        expect(tappedEvent, event);
      },
      skip: false,
    );

    testWidgets(
      'Switching to another week changes period picker text',
      (widgetTester) async {
        final view = WeekView(
          controller: controller,
          saverConfig: _saverConfig(),
        );

        when(() => controller.initialDate).thenReturn(currentMonth);
        when(() => controller.endDate).thenReturn(currentMonthEnd);
        when(() => controller.state).thenReturn(
          withClock(
            clock,
                () => WeekViewNextWeekSelected(focusedDate: nextWeek),
          ),
        );

        await widgetTester.pumpWidget(runTestApp(view));

        await widgetTester.pumpAndSettle();

        expect(
          find.widgetWithText(DisplayedPeriodPicker, '8 - 14 Jan, 2024'),
          findsOneWidget,
          reason: 'Week picker should display ‘next week',
        );
      },
      skip: false,
    );
  });
}

SaverConfig _saverConfig() => SaverConfig(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: const Icon(Icons.done),
      ),
    );
