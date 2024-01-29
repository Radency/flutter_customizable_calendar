import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:mocktail/mocktail.dart';

/// Mock [DaysViewController] class
class MockDaysViewController extends MockCubit<DaysViewState>
    implements DaysViewController {}

/// Initial state with date for [MockDaysViewController]
DaysViewInitial initialStateWithDate(DateTime date) => withClock(
      Clock.fixed(date), // It's needed to mock clock.now() return value
      DaysViewInitial.new,
    );

/// Setup [DaysViewController] mock
void setupDaysViewController({
  required DaysViewController controller,
  required DateTime currentMonth,
  required DateTime currentMonthEnd,
  required DateTime now,
}) {
  when(() => controller.initialDate).thenReturn(currentMonth);
  when(() => controller.endDate).thenReturn(currentMonthEnd);
  when(() => controller.state).thenReturn(
    initialStateWithDate(now),
  );
}
