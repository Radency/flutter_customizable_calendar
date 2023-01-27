part of 'week_view_controller.dart';

abstract class WeekViewState extends Equatable {
  const WeekViewState({
    required this.focusedDate,
    this.reverseAnimation = false,
  });

  final DateTime focusedDate;
  final bool reverseAnimation;

  DateTimeRange get displayedWeek => focusedDate.weekRange;

  @override
  List<Object?> get props => [
        focusedDate,
        reverseAnimation,
      ];
}

class WeekViewInitial extends WeekViewState {
  WeekViewInitial() : super(focusedDate: clock.now());
}

class WeekViewCurrentWeekIsSet extends WeekViewState {
  const WeekViewCurrentWeekIsSet({
    required super.focusedDate,
    required super.reverseAnimation,
  });
}

class WeekViewPrevWeekSelected extends WeekViewState {
  const WeekViewPrevWeekSelected({required super.focusedDate})
      : super(reverseAnimation: true);
}

class WeekViewNextWeekSelected extends WeekViewState {
  const WeekViewNextWeekSelected({required super.focusedDate});
}
