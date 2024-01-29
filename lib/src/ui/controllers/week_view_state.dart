part of 'week_view_controller.dart';

/// Base class for all states of [WeekViewController].
abstract class WeekViewState extends Equatable {

  /// Creates [WeekViewState] instance.
  const WeekViewState({
    required this.focusedDate,
    this.reverseAnimation = false,
  });

  /// The date which is currently focused in the week view.
  final DateTime focusedDate;

  /// Whether the animation should be reversed.
  final bool reverseAnimation;

  /// The week range which is currently displayed in the week view.

  DateTimeRange displayedWeek(int visibleDays) =>
      focusedDate.weekRange(visibleDays);

  @override
  List<Object?> get props => [
        focusedDate,
        reverseAnimation,
      ];
}

/// The initial state of [WeekViewController].
class WeekViewInitial extends WeekViewState {

  /// Creates [WeekViewInitial] instance.
  WeekViewInitial() : super(focusedDate: clock.now());
}

/// The state of [WeekViewController] when the current week is set.
class WeekViewCurrentWeekIsSet extends WeekViewState {

  /// Creates [WeekViewCurrentWeekIsSet] instance.
  const WeekViewCurrentWeekIsSet({
    required super.focusedDate,
    required super.reverseAnimation,
  });
}

/// The state of [WeekViewController] when the previous week is selected.
class WeekViewPrevWeekSelected extends WeekViewState {

  /// Creates [WeekViewPrevWeekSelected] instance.
  const WeekViewPrevWeekSelected({required super.focusedDate})
      : super(reverseAnimation: true);
}

/// The state of [WeekViewController] when the next week is selected.
class WeekViewNextWeekSelected extends WeekViewState {
  /// Creates [WeekViewNextWeekSelected] instance.
  const WeekViewNextWeekSelected({required super.focusedDate});
}
