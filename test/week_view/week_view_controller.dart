import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
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
  required DateTime initialDate,
  required DateTime endDate,
}) {
  const visibleDays = 7;

  when(() => controller.initialDate).thenReturn(initialDate);
  when(() => controller.visibleDays).thenReturn(visibleDays);
  when(() => controller.endDate).thenReturn(endDate);
  when(() => controller.state).thenReturn(initialStateWithDate(now));
  when(() => controller.weekRange()).thenAnswer((a) {
    return DateUtils.addDaysToDate(
      initialDate,
      (now.difference(initialDate).inDays ~/ visibleDays) * visibleDays,
    ).weekRange(visibleDays);
  });
}
