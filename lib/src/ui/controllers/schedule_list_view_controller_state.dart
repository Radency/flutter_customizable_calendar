part of 'schedule_list_view_controller.dart';

/// Base class for all states of [ScheduleListViewController].
@immutable
abstract class ScheduleListViewControllerState extends Equatable {
  /// Creates [ScheduleListViewControllerState] instance.
  const ScheduleListViewControllerState({
    required this.displayedDate,
    required this.reverseAnimation,
  });

  /// The date which is currently displayed in the schedule list view.
  final DateTime displayedDate;

  /// Whether the animation should be reversed.
  final bool reverseAnimation;

  @override
  List<Object?> get props => [displayedDate, reverseAnimation];
}

/// The initial state of [ScheduleListViewController].
class ScheduleListViewControllerInitial
    extends ScheduleListViewControllerState {
  /// Creates [ScheduleListViewControllerInitial] instance.
  ScheduleListViewControllerInitial()
      : super(displayedDate: clock.now(), reverseAnimation: false);
}

/// The state of [ScheduleListViewController] when the current date is set.
class ScheduleListViewControllerCurrentDateIsSet
    extends ScheduleListViewControllerState {
  /// Creates [ScheduleListViewControllerCurrentDateIsSet] instance.
  const ScheduleListViewControllerCurrentDateIsSet({
    required super.displayedDate,
    required super.reverseAnimation,
    required this.animateTo,
    this.animatePicker = true,
    this.animateList = true,
  });

  /// Whether the picker should be animated.
  final bool animatePicker;

  /// Whether the list should be animated.
  final bool animateList;

  /// The date to which the picker should be animated.

  final DateTime animateTo;

  @override
  List<Object?> get props => [
        super.displayedDate,
        animatePicker,
        animateList,
        animateTo,
        super.reverseAnimation,
      ];
}
