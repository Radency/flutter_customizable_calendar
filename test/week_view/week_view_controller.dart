import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_customizable_calendar/src/ui/controllers/controllers.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekViewController extends MockCubit<WeekViewState>
    implements WeekViewController {}

WeekViewInitial initialStateWithDate(DateTime date) => withClock(
      Clock.fixed(date), // It's needed to mock clock.now() return value
      WeekViewInitial.new,
    );
void setupWeekViewController({
  required WeekViewController controller,
  required DateTime now,
  required DateTime currentWeek,
  required DateTime currentWeekEnd,
}) {
  when(() => controller.initialDate).thenReturn(currentWeek);
  when(() => controller.visibleDays).thenReturn(7);
  when(() => controller.endDate).thenReturn(currentWeekEnd);
  when(() => controller.state).thenReturn(initialStateWithDate(now));
}
