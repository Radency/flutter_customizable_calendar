part of 'days_view_controller.dart';

abstract class DaysViewState extends Equatable {
  const DaysViewState({
    required this.displayedDate,
    DateTime? focusedDate,
    this.reverseAnimation = false,
  }) : focusedDate = focusedDate ?? displayedDate;

  final DateTime focusedDate;
  final DateTime displayedDate;
  final bool reverseAnimation;

  @override
  List<Object?> get props => [
        focusedDate,
        displayedDate,
        reverseAnimation,
      ];
}

class DaysViewInitial extends DaysViewState {
  DaysViewInitial() : super(displayedDate: clock.now());
}

class DaysViewCurrentDateIsSet extends DaysViewState {
  const DaysViewCurrentDateIsSet({
    required super.displayedDate,
    required super.reverseAnimation,
  });
}

class DaysViewDaySelected extends DaysViewState {
  const DaysViewDaySelected({required super.displayedDate});
}

class DaysViewFocusedDateIsSet extends DaysViewState {
  const DaysViewFocusedDateIsSet(
    DateTime date, {
    required super.reverseAnimation,
  }) : super(displayedDate: date);
}

class DaysViewPrevMonthSelected extends DaysViewState {
  const DaysViewPrevMonthSelected({
    required super.displayedDate,
    required super.focusedDate,
  }) : super(reverseAnimation: true);
}

class DaysViewNextMonthSelected extends DaysViewState {
  const DaysViewNextMonthSelected({
    required super.displayedDate,
    required super.focusedDate,
  });
}
