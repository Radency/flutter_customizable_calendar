import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/month_day_theme.dart';
import 'package:flutter_customizable_calendar/src/utils/floating_event_notifier.dart';

/// A key holder of all MonthView keys
@visibleForTesting
abstract class MonthViewKeys {
  /// A key for the timeline view
  static GlobalKey? timeline;

  /// Map of keys for the events layouts (by day date)
  static final layouts = <DateTime, GlobalKey>{};

  /// Map of keys for the displayed events (by event object)
  static final events = <CalendarEvent, GlobalKey>{};
}

class MonthView<T extends FloatingCalendarEvent> extends StatefulWidget {
  /// Creates a Month view. Parameter [initialDate] is required.
  const MonthView({
    super.key,
    required this.controller,
    this.monthPickerTheme = const DisplayedPeriodPickerTheme(),
    this.daysRowTheme = const DaysRowTheme(),
    this.divider,
    this.timelineTheme = const TimelineTheme(),
    this.floatingEventTheme = const FloatingEventsTheme(),
    this.monthDayTheme = const MonthDayTheme(),
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

  /// A divider which separates the weekdays list and the month section.
  /// You can set it to null if you don't need it.
  final Divider? divider;

  /// The timeline customization params
  final TimelineTheme timelineTheme;

  /// Floating events customization params
  final FloatingEventsTheme floatingEventTheme;

  /// Single day customization params
  final MonthDayTheme monthDayTheme;

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

class _MonthViewState<T extends FloatingCalendarEvent> extends State<MonthView<T>> {
  final _overlayKey = GlobalKey<DraggableEventOverlayState<T>>();
  final _elevatedEvent = FloatingEventNotifier<T>();
  late final PageController _monthPickerController;
  var _pointerLocation = Offset.zero;

  static DateTime get _now => clock.now();

  DateTime get _initialDate => widget.controller.initialDate;
  DateTime? get _endDate => widget.controller.endDate;
  DateTime get _monthDate => _displayedMonth.start
      .add(const Duration(days: 14));
  DateTime get _focusedDate => widget.controller.state.focusedDate;
  DateTimeRange get _displayedMonth => widget.controller.state.displayedMonth;
  DateTimeRange get _initialMonth => _initialDate.monthViewRange;

  RenderBox? _getTimelineBox() =>
      MonthViewKeys.timeline?.currentContext?.findRenderObject() as RenderBox?;

  RenderBox? _getLayoutBox(DateTime dayDate) =>
      MonthViewKeys.layouts[dayDate]?.currentContext?.findRenderObject()
      as RenderBox?;

  RenderBox? _getEventBox(T event) =>
      MonthViewKeys.events[event]?.currentContext?.findRenderObject()
      as RenderBox?;

  @override
  void initState() {
    super.initState();
    _monthPickerController = PageController(
      initialPage: DateUtils.monthDelta(_initialDate, _monthDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MonthViewController, MonthViewState>(
      bloc: widget.controller,
      listener: (context, state) {
        final displayedMonth = DateUtils.monthDelta(_initialDate, _monthDate);

        if (state is MonthViewCurrentMonthIsSet) {
          Future.wait([
            if (displayedMonth != _monthPickerController.page?.round())
              _monthPickerController.animateToPage(
                displayedMonth,
                duration: const Duration(milliseconds: 400),
                curve: Curves.linearToEaseOut,
              ),
          ]);
        } else if (state is MonthViewNextMonthSelected ||
            state is MonthViewPrevMonthSelected) {
          _monthPickerController.animateToPage(
            displayedMonth,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linearToEaseOut,
          );
        }
      },
      child: Column(
        children: [
          _monthPicker(),
          Expanded(
            child: DraggableEventOverlay<T>(
              _elevatedEvent,
              key: _overlayKey,
              viewType: CalendarView.month,
              timelineTheme: widget.timelineTheme,
              padding: EdgeInsets.only(
                top: widget.daysRowTheme.height + (widget.divider?.height ?? 0),
              ),
              onDropped: widget.onDiscardChanges,
              onChanged: widget.onEventUpdated,
              getTimelineBox: _getTimelineBox,
              getLayoutBox: _getLayoutBox,
              getEventBox: _getEventBox,
              saverConfig: widget.saverConfig,
              child: _monthSection(),
            ),
          ),
        ],
      ),
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

  Widget _monthSection() {
    final theme = widget.timelineTheme;

    return PageView.builder(
      controller: _monthPickerController,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, pageIndex) {
        final monthDays = widget.controller.state.displayedMonth.days;
        print ("aaa");

        return Padding(
          padding: EdgeInsets.only(
            left: theme.padding.left,
            right: theme.padding.right,
          ),
          child: Column(
            children: [
              _daysRow(monthDays.take(7).toList()),
              widget.divider ?? const SizedBox.shrink(),
              Expanded(
                child: _monthDays(monthDays),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _daysRow(List<DateTime> days) {
    final theme = widget.daysRowTheme;

    return SizedBox(
      height: theme.height,
      child: Row(
        children: days
            .map(
              (dayDate) => Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!theme.hideWeekday)
                  Text(
                    theme.weekdayFormatter.call(dayDate),
                    style: theme.weekdayStyle,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        )
            .toList(growable: false),
      ),
    );
  }

  Widget _monthDays(List<DateTime> days) {
    final theme = widget.monthDayTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        double mainAxisSpacing = theme.mainAxisSpacing;
        double crossAxisSpacing = theme.crossAxisSpacing;
        double aspectRatio = (constraints.maxWidth - crossAxisSpacing * 6) / 7
            / (constraints.maxHeight - mainAxisSpacing * 5) * 6;
        bool shouldScroll = aspectRatio > 1;
        if(shouldScroll) {
          aspectRatio = 1.0;// / aspectRatio;
        }

        return Container(
          key: MonthViewKeys.timeline = GlobalKey(),
          padding: EdgeInsets.only(
            bottom: 1,
          ),
          color: theme.spacingColor ?? widget.divider?.color ?? Colors.grey,
          child: IntrinsicHeight(
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: aspectRatio,
              physics: shouldScroll ? null : NeverScrollableScrollPhysics(),
              children: [
                ...days.map(_singleDayView),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _singleDayView(DateTime dayDate) {
    final theme = widget.monthDayTheme;
    final bool isToday = DateUtils.isSameDay(dayDate, _now);

    return Container(
      color: (isToday ? theme.currentDayColor : theme.dayColor)
          ??  Theme.of(context).scaffoldBackgroundColor,
      child: RenderIdProvider(
        id: dayDate,
        child: ValueListenableBuilder(
          valueListenable: _elevatedEvent,
          builder: (context, elevatedEvent, child) => AbsorbPointer(
            absorbing: elevatedEvent != null,
            child: child,
          ),
          child: GestureDetector(
            onLongPressStart: (details) {
              final timestamp = dayDate.add(Duration(hours: 12));

              if (timestamp.isBefore(_initialDate)) return;
              if ((_endDate != null) && timestamp.isAfter(_endDate!)) return;

              widget.onDateLongPress?.call(timestamp);
            },
            child: Container(
              color: Colors.transparent, // Needs for hitTesting
              child: Column(
                children: [
                  Container(
                    padding: theme.dayNumberPadding,
                    margin: theme.dayNumberMargin,
                    height: theme.dayNumberHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday
                          ? theme.currentDayNumberBackgroundColor
                          : theme.dayNumberBackgroundColor,
                    ),
                    child: Text(
                      dayDate.day.toString(),
                      style: isToday
                          ? theme.currentDayNumberTextStyle
                          : theme.dayNumberTextStyle,
                    ),
                  ),
                  Expanded(
                    child: EventsLayout<T>(
                      dayDate: dayDate,
                      overlayKey: _overlayKey,
                      layoutsKeys: MonthViewKeys.layouts,
                      eventsKeys: MonthViewKeys.events,
                      timelineTheme: widget.timelineTheme,
                      breaks: widget.breaks,
                      events: widget.events,
                      elevatedEvent: _elevatedEvent,
                      onEventTap: widget.onEventTap,
                      simpleView: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
