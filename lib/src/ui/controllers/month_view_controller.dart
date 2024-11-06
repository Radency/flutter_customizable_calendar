import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

part 'month_view_state.dart';

/// A specific controller which controls the MonthView state.
class MonthViewController extends Cubit<MonthViewState>
    with CalendarController {
  /// Creates MonthView controller instance.
  MonthViewController({
    DateTime? initialDate,
    this.endDate,
  })  : initialDate = initialDate ?? DateTime(1970),
        super(MonthViewInitial());

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
      MonthViewCurrentMonthIsSet(
        focusedDate: now,
        reverseAnimation: state.focusedDate.isAfter(now),
        updateTime: now,
      ),
    );
  }

  @override
  void prev() {
    final prevMonth = DateUtils.addMonthsToMonthDate(state.focusedDate, -1);

    if (!initialDate.isAfter(prevMonth)) {
      final now = clock.now();
      final isCurrentMonth = DateUtils.isSameMonth(prevMonth, now);
      emit(
        MonthViewPrevMonthSelected(
          focusedDate: isCurrentMonth ? now : prevMonth,
          updateTime: now,
        ),
      );
    }
  }

  @override
  void next() {
    final nextMonth = DateUtils.addMonthsToMonthDate(state.focusedDate, 1);

    if (!(endDate?.isBefore(nextMonth) ?? false)) {
      final now = clock.now();
      final isCurrentMonth = DateUtils.isSameMonth(nextMonth, now);
      emit(
        MonthViewNextMonthSelected(
          focusedDate: isCurrentMonth ? now : nextMonth,
          updateTime: now,
        ),
      );
    }
  }

  @override
  void setPage(int page) {
    final now = clock.now();
    final focusedDate = DateUtils.addMonthsToMonthDate(initialDate, page);
    final isCurrentMonth = DateUtils.isSameMonth(focusedDate, now);
    if (DateUtils.isSameMonth(focusedDate, state.focusedDate)) {
      return;
    }
    emit(
      MonthViewCurrentMonthIsSet(
        focusedDate: isCurrentMonth ? now : focusedDate,
        reverseAnimation: state.focusedDate.isAfter(now),
        updateTime: now,
      ),
    );
  }

  /// Sets the focused date to the given [date].
  void setFocusedDate(DateTime date) {
    emit(
      MonthViewCurrentMonthIsSet(
        focusedDate: date,
        reverseAnimation: state.focusedDate.isAfter(date),
        updateTime: clock.now(),
      ),
    );
  }
}
