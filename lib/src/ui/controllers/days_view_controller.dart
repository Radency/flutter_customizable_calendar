import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/src/ui/controllers/calendar_controller.dart';

part 'days_view_state.dart';

/// A specific controller which controls the DaysView state.
class DaysViewController extends Cubit<DaysViewState> with CalendarController {
  /// Creates DaysView controller instance.
  DaysViewController({
    DateTime? initialDate,
    this.endDate,
  })  : initialDate = initialDate ?? DateTime(1970),
        super(DaysViewInitial());

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
      DaysViewCurrentDateIsSet(
        displayedDate: now,
        reverseAnimation: state.displayedDate.isAfter(now),
      ),
    );
  }

  /// Switches calendar to shows the previous month
  @override
  void prev() {
    final prevMonth = DateUtils.addMonthsToMonthDate(state.displayedDate, -1);

    if (!initialDate.isAfter(prevMonth)) {
      final now = clock.now();
      final isCurrentMonth = DateUtils.isSameMonth(prevMonth, now);
      emit(
        DaysViewPrevMonthSelected(
          displayedDate: isCurrentMonth ? now : prevMonth,
          focusedDate: now, // Reset focused date
        ),
      );
    }
  }

  /// Switches calendar to shows the next month
  @override
  void next() {
    final nextMonth = DateUtils.addMonthsToMonthDate(state.displayedDate, 1);

    if (!(endDate?.isBefore(nextMonth) ?? false)) {
      final now = clock.now();
      final isCurrentMonth = DateUtils.isSameMonth(nextMonth, now);
      emit(
        DaysViewNextMonthSelected(
          displayedDate: isCurrentMonth ? now : nextMonth,
          focusedDate: now, // Reset focused date
        ),
      );
    }
  }

  /// Switches calendar to shows a specific day
  void selectDay(DateTime dayDate) {
    final now = clock.now();
    final isCurrentDay = DateUtils.isSameDay(dayDate, now);
    emit(
      DaysViewDaySelected(
        displayedDate: isCurrentDay ? now : dayDate,
      ),
    );
  }

  /// Set a specific date as focused
  void setFocusedDate(DateTime date) => emit(
        DaysViewFocusedDateIsSet(
          date,
          reverseAnimation: state.displayedDate.isAfter(date),
        ),
      );

  /// Switches calendar to shows a specific day
  @override
  void setPage(int page) {
    final now = clock.now();
    final displayedDate = DateUtils.addMonthsToMonthDate(initialDate, page);
    final isCurrentMonth = DateUtils.isSameMonth(displayedDate, now);
    emit(
      DaysViewCurrentDateIsSet(
        displayedDate: isCurrentMonth ? now : displayedDate,
        reverseAnimation: state.displayedDate.isAfter(displayedDate),
      ),
    );
  }
}
