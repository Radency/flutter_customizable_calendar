part of 'schedule_list_view_controller.dart';

@immutable
abstract class ScheduleListViewControllerState extends Equatable {
  const ScheduleListViewControllerState({
    required this.displayedDate,
    required this.reverseAnimation,
  });

  final DateTime displayedDate;
  final bool reverseAnimation;

  @override
  List<Object?> get props => [displayedDate, reverseAnimation];
}

class ScheduleListViewControllerInitial
    extends ScheduleListViewControllerState {
  ScheduleListViewControllerInitial()
      : super(displayedDate: clock.now(), reverseAnimation: false);
}

class ScheduleListViewControllerCurrentDateIsSet
    extends ScheduleListViewControllerState {
  const ScheduleListViewControllerCurrentDateIsSet({
    required super.displayedDate,
    required super.reverseAnimation,
    required this.animateTo,
    this.animePicker = true,
    this.animeList = true,
  });

  final bool animePicker;
  final bool animeList;

  final DateTime animateTo;

  @override
  List<Object?> get props => [
        super.displayedDate,
        animePicker,
        animeList,
        animateTo,
        super.reverseAnimation,
      ];
}
