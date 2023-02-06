import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/src/ui/controllers/calendar_controller.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

part 'week_view_state.dart';

/// A specific controller which controls the WeekView state.
class WeekViewController extends Cubit<WeekViewState> with CalendarController {
  /// Creates WeekView controller instance.
  WeekViewController({
    DateTime? initialDate,
    this.endDate,
  })  : initialDate = initialDate ?? DateTime(1970),
        super(WeekViewInitial());

  @override
  final DateTime initialDate;

  @override
  final DateTime? endDate;

  @override
  void dispose() => close();

  @override
  void reset() {
    final now = clock.now();
    emit(
      WeekViewCurrentWeekIsSet(
        focusedDate: now,
        reverseAnimation: state.focusedDate.isAfter(now),
      ),
    );
  }

  /// Switches calendar to shows the previous week
  @override
  void prev() {
    final prevWeek = DateUtils.addDaysToDate(state.focusedDate, -7);

    if (!initialDate.isAfter(prevWeek)) {
      final now = clock.now();
      final isCurrentWeek = prevWeek.isSameWeekAs(now);
      emit(
        WeekViewPrevWeekSelected(
          focusedDate: isCurrentWeek ? now : prevWeek,
        ),
      );
    }
  }

  /// Switches calendar to shows the next week
  @override
  void next() {
    final nextWeek = DateUtils.addDaysToDate(state.focusedDate, 7);

    if (!(endDate?.isBefore(nextWeek) ?? false)) {
      final now = clock.now();
      final isCurrentWeek = nextWeek.isSameWeekAs(now);
      emit(
        WeekViewNextWeekSelected(
          focusedDate: isCurrentWeek ? now : nextWeek,
        ),
      );
    }
  }
}
