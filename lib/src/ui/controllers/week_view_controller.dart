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
    this.visibleDays = 7,
    DateTime? initialDate,
    this.endDate,
  })  : initialDate = initialDate ?? DateTime(1970),
        assert(visibleDays > 0, 'visibleDays must be greater than 0'),
        assert(visibleDays <= 7, 'visibleDays must be less or equal to 7'),
        super(WeekViewInitial());

  final int visibleDays;
  @override
  final DateTime initialDate;

  @override
  final DateTime? endDate;
  double? timelineOffset;

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
      final isCurrentWeek = prevWeek.isSameWeekAs(visibleDays, now);
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
      final isCurrentWeek = nextWeek.isSameWeekAs(visibleDays, now);
      emit(
        WeekViewNextWeekSelected(
          focusedDate: isCurrentWeek ? now : nextWeek,
        ),
      );
    }
  }

  void setDisplayedDate(DateTime date) {
    emit(
      WeekViewCurrentWeekIsSet(
        focusedDate: DateTime(
          date.year,
          date.month,
          date.day,
        ),
        reverseAnimation: state.focusedDate.isAfter(date),
      ),
    );
  }

  @override
  void setPage(int page) {
    final now = clock.now();
    final focusedDate = initialDate.addWeeks(
      visibleDays,
      page,
    );
    final isCurrentWeek = focusedDate.isSameWeekAs(visibleDays, now);
    if (DateUtils.isSameMonth(focusedDate, state.focusedDate)) {
      return;
    }
    emit(
      WeekViewCurrentWeekIsSet(
        focusedDate: isCurrentWeek ? now : focusedDate,
        reverseAnimation: state.focusedDate.isAfter(now),
      ),
    );
  }
}
