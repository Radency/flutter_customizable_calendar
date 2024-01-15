import 'dart:math';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

part 'schedule_list_view_controller_state.dart';

/// A specific controller which controls the ScheduleListView state.
class ScheduleListViewController extends Cubit<ScheduleListViewControllerState>
    with CalendarController {
  /// Creates ScheduleListView controller instance.
  ScheduleListViewController({DateTime? initialDate, this.endDate})
      : initialDate = initialDate ?? DateTime(1970),
        super(ScheduleListViewControllerInitial()) {
    initialDate = initialDate ?? DateTime(1970);
    final dateRange = DateTimeRange(
      start: initialDate,
      end: endDate ?? DateTime(2100),
    );
    grouped = Map.fromEntries(
      dateRange.days.map(
        (e) => MapEntry(e, <CalendarEvent>[]),
      ),
    );
  }

  /// The initial date of the calendar.
  @override
  final DateTime initialDate;

  /// The end date of the calendar.
  @override
  final DateTime? endDate;

  /// The list of dates which will be rendered in the schedule list view.
  late final Map<DateTime, List<CalendarEvent>> grouped;

  /// Returns the index of the group to which the current date belongs
  int animateToGroupIndex({
    required Map<DateTime, List<CalendarEvent>> events,
    bool ignoreEmpty = false,
  }) {
    final keys = events.keys.toList();

    late final DateTime targetDate;

    if (state is ScheduleListViewControllerCurrentDateIsSet) {
      final animateTo =
          (state as ScheduleListViewControllerCurrentDateIsSet).animateTo;
      targetDate = DateTime(
        animateTo.year,
        animateTo.month,
        animateTo.day,
      );
    } else {
      targetDate = DateTime(
        state.displayedDate.year,
        state.displayedDate.month,
        state.displayedDate.day,
      );
    }

    final index = keys.indexOf(targetDate);
    if (index != -1) {
      return index;
    }

    // return closest target date or closes
    final closest = keys.sorted((a, b) {
      final aDiff = a.difference(targetDate).abs();
      final bDiff = b.difference(targetDate).abs();
      return aDiff.compareTo(bDiff);
    });
    return keys.indexOf(closest.first);
  }

  @override
  void dispose() {
    close();
  }

  /// Switches calendar to shows the next month
  @override
  void next() {
    final displayedDate =
        DateUtils.addMonthsToMonthDate(state.displayedDate, 1);
    emit(
      ScheduleListViewControllerCurrentDateIsSet(
        displayedDate: state.displayedDate,
        animateTo: DateTime(
          displayedDate.year,
          displayedDate.month,
          2,
        ),
        reverseAnimation: false,
      ),
    );
  }

  /// Switches calendar to shows the previous month
  @override
  void prev() {
    final displayedDate =
        DateUtils.addMonthsToMonthDate(state.displayedDate, -1);
    emit(
      ScheduleListViewControllerCurrentDateIsSet(
        displayedDate: state.displayedDate,
        animateTo: DateTime(
          displayedDate.year,
          displayedDate.month,
          2,
        ),
        reverseAnimation: true,
      ),
    );
  }

  /// Resets the calendar to the current date.
  @override
  void reset() {
    final now = clock.now();
    final day = DateTime(
      now.year,
      now.month,
      now.day,
    );
    final reversed = state.displayedDate.isBefore(day);
    emit(
      ScheduleListViewControllerCurrentDateIsSet(
        animateTo: day,
        displayedDate: state.displayedDate,
        reverseAnimation: reversed,
      ),
    );
  }

  /// Sets the current page of the calendar.
  @override
  void setPage(int page) {
    final displayedDate = DateUtils.addDaysToDate(initialDate, page);
    emit(
      ScheduleListViewControllerCurrentDateIsSet(
        displayedDate: displayedDate,
        animateTo: displayedDate,
        reverseAnimation: displayedDate.isBefore(state.displayedDate),
      ),
    );
  }

  /// Sets the current date of the calendar.
  void setDisplayedDateByGroupIndex(
    int index,
    Map<DateTime, List<CalendarEvent>> events,
  ) {
    final keys = events.keys.toList();
    final date = keys[min(keys.length - 1, index)];
    emit(
      ScheduleListViewControllerCurrentDateIsSet(
        displayedDate: date,
        animateTo: date,
        animePicker: date.month != state.displayedDate.month,
        animeList: false,
        reverseAnimation: date.isBefore(state.displayedDate),
      ),
    );
  }

  /// Sets the current date of the calendar.
  void setDisplayedDate(DateTime date) {
    final displayedDate = DateTime(date.year, date.month, date.day);
    emit(
      ScheduleListViewControllerCurrentDateIsSet(
        animateTo: displayedDate,
        displayedDate: state.displayedDate,
        animePicker: displayedDate.month != state.displayedDate.month,
        reverseAnimation: displayedDate.isBefore(
          DateTime(
            state.displayedDate.year,
            state.displayedDate.month,
            state.displayedDate.day,
          ),
        ),
      ),
    );
  }
}
