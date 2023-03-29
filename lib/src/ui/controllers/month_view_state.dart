part of 'month_view_controller.dart';

abstract class MonthViewState extends Equatable {
  const MonthViewState({
    required this.focusedDate,
    this.reverseAnimation = false,
  });

  final DateTime focusedDate;
  final bool reverseAnimation;

  DateTimeRange get displayedMonth => focusedDate.monthViewRange;

  @override
  List<Object?> get props => [
    focusedDate,
    reverseAnimation,
  ];
}

class MonthViewInitial extends MonthViewState {
  MonthViewInitial() : super(focusedDate: clock.now());
}

class MonthViewCurrentMonthIsSet extends MonthViewState {
  const MonthViewCurrentMonthIsSet({
    required super.focusedDate,
    required super.reverseAnimation,
  });
}

class MonthViewPrevMonthSelected extends MonthViewState {
  const MonthViewPrevMonthSelected({required super.focusedDate})
      : super(reverseAnimation: true);
}

class MonthViewNextMonthSelected extends MonthViewState {
  const MonthViewNextMonthSelected({required super.focusedDate});
}
