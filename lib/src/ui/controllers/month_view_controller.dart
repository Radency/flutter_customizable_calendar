import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/src/ui/controllers/calendar_controller.dart';

part 'month_view_state.dart';

/// A specific controller which controls the MonthView state.
class MonthViewController extends Cubit<MonthViewState>
    with CalendarController {
  /// Creates MonthView controller instance.
  MonthViewController({
    required this.initialDate,
    this.endDate,
  }) : super(MonthViewInitial());

  @override
  final DateTime initialDate;

  @override
  final DateTime? endDate;

  @override
  void dispose() => close();

  @override
  void reset() => emit(state);

  @override
  void prev() {}

  @override
  void next() {}
}
