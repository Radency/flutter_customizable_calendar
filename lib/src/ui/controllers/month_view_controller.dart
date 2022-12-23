import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/src/ui/controllers/calendar_controller.dart';

part 'month_view_state.dart';

class MonthViewController extends Cubit<MonthViewState>
    with CalendarController {
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
