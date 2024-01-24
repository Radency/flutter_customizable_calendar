import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:mocktail/mocktail.dart';

MonthViewInitial initialStateWithDate(DateTime date) => withClock(
      Clock.fixed(date), // It's needed to mock clock.now() return value
      MonthViewInitial.new,
    );

class MockMonthViewController extends MockCubit<MonthViewState>
    implements MonthViewController {}

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
