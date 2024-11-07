import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

extension ItemPositionExtension on ItemPosition {
  double getEdgeByMode(EScheduleListViewDisplayedDateEdge mode) {
    switch (mode) {
      case EScheduleListViewDisplayedDateEdge.leading:
        return itemTrailingEdge;
      case EScheduleListViewDisplayedDateEdge.trailing:
        return itemLeadingEdge;
    }
  }
}