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

        /// The number of days to be displayed in the week view.
        assert(visibleDays > 0, 'visibleDays must be greater than 0'),
        assert(visibleDays <= 7, 'visibleDays must be less or equal to 7'),
        super(WeekViewInitial());

  /// The number of days to be displayed in the week view.
  final int visibleDays;

  @override
  final DateTime initialDate;

  DateTimeRange weekRange() {
    return DateUtils.addDaysToDate(
      initialDate,
      (state.focusedDate.difference(initialDate).inDays ~/ visibleDays) *
          visibleDays,
    ).weekRange(visibleDays);
  }

  @override
  final DateTime? endDate;

  /// The offset of the timeline.
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

  @override
  void prev() {
    final prevWeek = DateUtils.addDaysToDate(
      state.focusedDate,
      -visibleDays,
    );

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

  @override
  void next() {
    final nextWeek = DateUtils.addDaysToDate(
      state.focusedDate,
      visibleDays,
    );

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

  /// Sets the displayed date.
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
    final focusedDate = initialDate.addWeeks(
      visibleDays,
      page,
    );
    emit(
      WeekViewCurrentWeekIsSet(
        focusedDate: focusedDate,
        reverseAnimation: state.focusedDate.isAfter(focusedDate),
      ),
    );
  }
}
