part of 'days_view_controller.dart';

/// [DaysViewController] base state class.
abstract class DaysViewState extends Equatable {
  /// Creates a base [DaysViewState] instance.
  const DaysViewState({
    required this.displayedDate,
    DateTime? focusedDate,
    this.reverseAnimation = false,
  }) : focusedDate = focusedDate ?? displayedDate;

  /// The date which is focused
  final DateTime focusedDate;

  /// The date which is displayed
  final DateTime displayedDate;

  /// If the animation should be reversed
  final bool reverseAnimation;

  @override
  List<Object?> get props => [
        focusedDate,
        displayedDate,
        reverseAnimation,
      ];
}

/// Initial state of the [DaysViewController].
class DaysViewInitial extends DaysViewState {
  /// Creates a [DaysViewInitial] instance.
  DaysViewInitial({
    DateTime? focusDate,
  }) : super(
          displayedDate: focusDate ?? clock.now(),
        );
}

/// State of the [DaysViewController] when the current date is set.
class DaysViewCurrentDateIsSet extends DaysViewState {
  /// Creates a [DaysViewCurrentDateIsSet] instance.
  const DaysViewCurrentDateIsSet({
    required super.displayedDate,
    required super.reverseAnimation,
  });
}

/// State of the [DaysViewController] when the day is selected.
class DaysViewDaySelected extends DaysViewState {
  /// Creates a [DaysViewDaySelected] instance.
  const DaysViewDaySelected({required super.displayedDate});
}

/// State of the [DaysViewController] when the focused date is set.
class DaysViewFocusedDateIsSet extends DaysViewState {
  /// Creates a [DaysViewFocusedDateIsSet] instance.
  const DaysViewFocusedDateIsSet(
    DateTime date, {
    required super.reverseAnimation,
  }) : super(displayedDate: date);
}

/// State of the [DaysViewController] when the previous month is selected.
class DaysViewPrevMonthSelected extends DaysViewState {
  /// Creates a [DaysViewPrevMonthSelected] instance.
  const DaysViewPrevMonthSelected({
    required super.displayedDate,
    required super.focusedDate,
  }) : super(reverseAnimation: true);
}

/// State of the [DaysViewController] when the next month is selected.
class DaysViewNextMonthSelected extends DaysViewState {
  /// Creates a [DaysViewNextMonthSelected] instance.
  const DaysViewNextMonthSelected({
    required super.displayedDate,
    required super.focusedDate,
  });
}
