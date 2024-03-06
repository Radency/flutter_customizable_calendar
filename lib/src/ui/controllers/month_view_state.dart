part of 'month_view_controller.dart';

/// Base class for all states of [MonthViewController].
abstract class MonthViewState extends Equatable {
  /// Creates [MonthViewState] instance.
  const MonthViewState({
    required this.focusedDate,
    this.reverseAnimation = false,
  });

  /// The date which is currently focused in the month view.
  final DateTime focusedDate;

  /// Whether the animation should be reversed.
  final bool reverseAnimation;

  /// The month range which is currently displayed in the month view.

  DateTimeRange displayedMonth({
    bool weekStartsOnSunday = false,
    int numberOfWeeks = 6,
  }) =>
      focusedDate.monthViewRange(
        weekStartsOnSunday: weekStartsOnSunday,
        numberOfWeeks: numberOfWeeks,
      );

  @override
  List<Object?> get props => [
        focusedDate,
        reverseAnimation,
      ];
}

/// The initial state of [MonthViewController].
class MonthViewInitial extends MonthViewState {
  /// Creates [MonthViewInitial] instance.
  MonthViewInitial() : super(focusedDate: clock.now());
}

/// The state of [MonthViewController] when the current month is set.
class MonthViewCurrentMonthIsSet extends MonthViewState {
  /// Creates [MonthViewCurrentMonthIsSet] instance.
  const MonthViewCurrentMonthIsSet({
    required super.focusedDate,
    required super.reverseAnimation,
  });
}

/// The state of [MonthViewController] when the previous month is selected.
class MonthViewPrevMonthSelected extends MonthViewState {
  /// Creates [MonthViewPrevMonthSelected] instance.
  const MonthViewPrevMonthSelected({required super.focusedDate})
      : super(reverseAnimation: true);
}

/// The state of [MonthViewController] when the next month is selected.
class MonthViewNextMonthSelected extends MonthViewState {
  /// Creates [MonthViewNextMonthSelected] instance.
  const MonthViewNextMonthSelected({required super.focusedDate});
}
