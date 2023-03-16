import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';

/// A key holder of all MonthView keys
@visibleForTesting
abstract class MonthViewKeys {
  /// A key for the timeline view
  static final timeline = GlobalKey();

  /// Map of keys for the events layouts (by day date)
  static final layouts = <DateTime, GlobalKey>{};

  /// Map of keys for the displayed events (by event object)
  static final events = <CalendarEvent, GlobalKey>{};
}

class MonthView<T extends CalendarEvent> extends StatefulWidget {
  /// Creates a Month view. Parameter [initialDate] is required.
  const MonthView({
    super.key,
    required this.controller,
    this.monthPickerTheme = const DisplayedPeriodPickerTheme(),
    this.daysRowTheme = const DaysRowTheme(),
    this.timelineTheme = const TimelineTheme(),
    this.floatingEventTheme = const FloatingEventsTheme(),
    this.breaks = const [],
    this.events = const [],
    this.onDateLongPress,
    this.onEventTap,
    this.onEventUpdated,
    this.onDiscardChanges,
    required this.saverConfig,
  });

  /// Controller which allows to control the view
  final MonthViewController controller;

  /// The month picker customization params
  final DisplayedPeriodPickerTheme monthPickerTheme;

  /// The days list customization params
  final DaysRowTheme daysRowTheme;

  /// The timeline customization params
  final TimelineTheme timelineTheme;

  /// Floating events customization params
  final FloatingEventsTheme floatingEventTheme;

  /// Breaks list to display
  final List<Break> breaks;

  /// Events list to display
  final List<T> events;

  /// Returns selected timestamp
  final void Function(DateTime)? onDateLongPress;

  /// Returns the tapped event
  final void Function(T)? onEventTap;

  /// Is called after an event is modified by user
  final void Function(T)? onEventUpdated;

  /// Is called after user discards changes for event
  final void Function(T)? onDiscardChanges;

  /// Properties for widget which is used to save edited event
  final SaverConfig saverConfig;

  @override
  State<MonthView<T>> createState() => _MonthViewState<T>();
}

class _MonthViewState<T extends CalendarEvent> extends State<MonthView<T>> {
  /// Calendar initial date
  // final DateTime initialDate;

  /// Events list to display
  // final List<T> events;

  DateTime get _initialDate => widget.controller.initialDate;
  DateTime? get _endDate => widget.controller.endDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _monthPicker(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _monthPicker() => BlocBuilder<MonthViewController, MonthViewState>(
    bloc: widget.controller,
    builder: (context, state) => DisplayedPeriodPicker(
      period: DisplayedPeriod(state.focusedDate),
      theme: widget.monthPickerTheme,
      reverseAnimation: state.reverseAnimation,
      onLeftButtonPressed:
      DateUtils.isSameMonth(state.focusedDate, _initialDate)
          ? null
          : widget.controller.prev,
      onRightButtonPressed:
      DateUtils.isSameMonth(state.focusedDate, _endDate)
          ? null
          : widget.controller.next,
    ),
    buildWhen: (previous, current) => !DateUtils.isSameMonth(
      previous.focusedDate,
      current.focusedDate,
    ),
  );
}
