import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/controllers/days_view_controller.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/custom_widgets.dart';
import 'package:flutter_customizable_calendar/src/ui/views/days_view.dart';

class MockDaysViewController extends MockCubit<DaysViewState>
    implements DaysViewController {}

void main() {
  MaterialApp runTestApp(Widget view) => MaterialApp(home: view);

  group(
    'DaysView test',
    () {
      final now = DateTime(2022, DateTime.november, 10, 9, 45);
      final today = DateUtils.dateOnly(now);
      final daysInCurrentMonth = DateUtils.getDaysInMonth(now.year, now.month);
      final currentMonth = DateTime(now.year, now.month);
      final currentMonthEnd = DateTime(now.year, now.month, daysInCurrentMonth);
      final currentHour = DateTime(now.year, now.month, now.day, now.hour);
      final nextMonth = DateTime(now.year, now.month + 1);
      final daysInNextMonth =
          DateUtils.getDaysInMonth(nextMonth.year, nextMonth.month);
      final nextMonthEnd =
          DateTime(nextMonth.year, nextMonth.month, daysInNextMonth);

      late DaysViewController controller;

      DaysViewInitial initialStateWithDate(DateTime date) => withClock(
            Clock.fixed(date), // It's needed to mock clock.now() return value
            DaysViewInitial.new,
          );

      setUp(() {
        controller = MockDaysViewController();
      });

      tearDown(() async {
        await controller.close();
      });

      testWidgets(
        'Month picker displays current month',
        (widgetTester) async {
          const year = 2022;
          const month = DateTime.june;
          final daysInMonth = DateUtils.getDaysInMonth(year, month);
          final view = DaysView(controller: controller);

          when(() => controller.initialDate).thenReturn(DateTime(year, month));
          when(() => controller.endDate)
              .thenReturn(DateTime(year, month, daysInMonth));
          when(() => controller.state)
              .thenReturn(initialStateWithDate(DateTime(year, month, 10)));

          await widgetTester.pumpWidget(runTestApp(view));

          expect(
            find.widgetWithText(DisplayedPeriodPicker, 'June 2022'),
            findsOneWidget,
            reason: 'Month picker must display current month name and year',
          );
        },
        skip: false,
      );

      testWidgets(
        'Current day is focused',
        (widgetTester) async {
          final view = DaysView(controller: controller);

          when(() => controller.initialDate).thenReturn(currentMonth);
          when(() => controller.endDate).thenReturn(currentMonthEnd);
          when(() => controller.state).thenReturn(initialStateWithDate(now));

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
            onDateLongPress: (date) => pressedDate = date,
          );

          when(() => controller.initialDate).thenReturn(currentMonth);
          when(() => controller.endDate).thenReturn(currentMonthEnd);
          when(() => controller.state).thenReturn(initialStateWithDate(now));

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

          when(() => controller.initialDate).thenReturn(currentMonth);
          when(() => controller.endDate).thenReturn(currentMonthEnd);
          when(() => controller.state)
              .thenReturn(initialStateWithDate(event.start));

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

          when(() => controller.initialDate).thenReturn(currentMonth);
          when(() => controller.endDate).thenReturn(currentMonthEnd);
          when(() => controller.state)
              .thenReturn(initialStateWithDate(event.start));

          await widgetTester.pumpWidget(runTestApp(view));

          final eventKey = DaysViewKeys.events[event]!;

          expect(find.byKey(DaysViewKeys.elevatedEvent), findsNothing);

          await widgetTester.longPress(find.byKey(eventKey));

          expect(find.byKey(DaysViewKeys.elevatedEvent), findsOneWidget);
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

          when(() => controller.initialDate).thenReturn(currentMonth);
          when(() => controller.endDate).thenReturn(currentMonthEnd);
          when(() => controller.state)
              .thenReturn(initialStateWithDate(event.start));

          await widgetTester.pumpWidget(runTestApp(view));

          final eventKey = DaysViewKeys.events[event]!;
          final eventFinder = find.byKey(eventKey);
          final eventRect = widgetTester.getRect(eventFinder);
          final layoutKey = DaysViewKeys.layouts[today]!;
          final layoutFinder = find.byKey(layoutKey);
          final layoutRect = widgetTester.getRect(layoutFinder);
          final elevatedEventFinder = find.byKey(DaysViewKeys.elevatedEvent);

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

          when(() => controller.initialDate).thenReturn(currentMonth);
          when(() => controller.endDate).thenReturn(currentMonthEnd);
          when(() => controller.state)
              .thenReturn(initialStateWithDate(event.start));

          await widgetTester.pumpWidget(runTestApp(view));

          final eventKey = DaysViewKeys.events[event]!;

          await widgetTester.longPress(find.byKey(eventKey));
          await widgetTester.pumpAndSettle();

          final elevatedEventFinder = find.byKey(DaysViewKeys.elevatedEvent);

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
          final view = DaysView(controller: controller);

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

          when(() => controller.initialDate).thenReturn(currentMonth);
          when(() => controller.endDate).thenReturn(currentMonthEnd);
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
    },
    skip: false,
  );
}
