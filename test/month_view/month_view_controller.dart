import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:mocktail/mocktail.dart';

/// Initial state with date for [MockMonthViewController]
MonthViewInitial initialStateWithDate(DateTime date) => withClock(
      Clock.fixed(date), // It's needed to mock clock.now() return value
      MonthViewInitial.new,
    );

/// Setup [MonthViewController] mock
class MockMonthViewController extends MockCubit<MonthViewState>
    implements MonthViewController {}

/// Setup [MonthViewController] mock
void setupMonthViewController({
  required MonthViewController controller,
  required DateTime now,
  required DateTime currentMonth,
  required DateTime currentMonthEnd,
}) {
  when(() => controller.initialDate).thenReturn(currentMonth);
  when(() => controller.endDate).thenReturn(currentMonthEnd);
  when(() => controller.state).thenReturn(initialStateWithDate(now));
}
