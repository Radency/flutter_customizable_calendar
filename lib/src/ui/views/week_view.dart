import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/controllers/controllers.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/custom_widgets.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/themes.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

/// A key holder of all WeekView keys
@visibleForTesting
abstract class WeekViewKeys {
  /// A key for the timeline view
  static GlobalKey? timeline;

  /// Map of keys for the events layouts (by day date)
  static final layouts = <DateTime, GlobalKey>{};

  /// Map of keys for the displayed events (by event object)
  static final events = <CalendarEvent, GlobalKey>{};
}

/// Week view displays a timeline for a specific week.
class WeekView<T extends FloatingCalendarEvent> extends StatefulWidget {
  /// Creates a Week view, [controller] is required.
  const WeekView({
    super.key,
    required this.controller,
    this.weekPickerTheme = const DisplayedPeriodPickerTheme(),
    this.divider,
    this.daysRowTheme = const DaysRowTheme(),
    this.timelineTheme = const TimelineTheme(),
    this.floatingEventTheme = const FloatingEventsTheme(),
    this.breaks = const [],
    this.events = const [],
    this.onDateLongPress,
    this.onEventTap,
    this.onEventUpdated,
  });

  /// Controller which allows to control the view
  final WeekViewController controller;

  /// The month picker customization params
  final DisplayedPeriodPickerTheme weekPickerTheme;

  /// A divider which separates the days list and the timeline.
  /// You can set it to null if you don't need it.
  final Divider? divider;

  /// /// The days row customization params
  final DaysRowTheme daysRowTheme;

  /// The timeline customization params
  final TimelineTheme timelineTheme;

  /// Floating events customization params
  final FloatingEventsTheme floatingEventTheme;

  /// Breaks list to display
  final List<Break> breaks;

  /// Events list to display
  final List<T> events;

  /// Returns selected timestamp (to the minute)
  final void Function(DateTime)? onDateLongPress;

  /// Returns the tapped event
  final void Function(T)? onEventTap;

  /// Is called after an event is modified by user
  final void Function(T)? onEventUpdated;

  @override
  State<WeekView<T>> createState() => _WeekViewState<T>();
}

class _WeekViewState<T extends FloatingCalendarEvent> extends State<WeekView<T>>
    with SingleTickerProviderStateMixin {
  final _elevatedEvent = FloatingEventNotifier<T>();
  late final PageController _weekPickerController;
  var _pointerLocation = Offset.zero;
  var _scrolling = false;
  ScrollController? _timelineController;

  static DateTime get _now => clock.now();

  DateTime get _initialDate => widget.controller.initialDate;
  DateTime? get _endDate => widget.controller.endDate;
  DateTime get _focusedDate => widget.controller.state.focusedDate;
  DateTimeRange get _displayedWeek => widget.controller.state.displayedWeek;
  DateTimeRange get _initialWeek => _initialDate.weekRange;

  double get _minuteExtent => _hourExtent / Duration.minutesPerHour;
  double get _hourExtent => widget.timelineTheme.timeScaleTheme.hourExtent;
  double get _dayExtent => _hourExtent * Duration.hoursPerDay;

  int get _cellExtent => widget.timelineTheme.cellExtent;

  RenderBox? _getTimelineBox() =>
      WeekViewKeys.timeline?.currentContext?.findRenderObject() as RenderBox?;

  RenderBox? _getLayoutBox(DateTime dayDate) =>
      WeekViewKeys.layouts[dayDate]?.currentContext?.findRenderObject()
          as RenderBox?;

  RenderBox? _getEventBox(T event) =>
      WeekViewKeys.events[event]?.currentContext?.findRenderObject()
          as RenderBox?;

  void _stopTimelineScrolling() =>
      _timelineController?.jumpTo(_timelineController!.offset);

  Future<void> _scrollIfNecessary() async {
    final timelineBox = _getTimelineBox();

    _scrolling = timelineBox != null;

    if (!_scrolling) return; // Scrollable isn't found

    final fingerPosition = timelineBox!.globalToLocal(_pointerLocation);
    final timelineScrollPosition = _timelineController!.position;
    var timelineScrollOffset = timelineScrollPosition.pixels;

    const detectionArea = 25;
    const moveDistance = 25;

    if (fingerPosition.dy > timelineBox.size.height - detectionArea &&
        timelineScrollOffset < timelineScrollPosition.maxScrollExtent) {
      timelineScrollOffset = min(
        timelineScrollOffset + moveDistance,
        timelineScrollPosition.maxScrollExtent,
      );
    } else if (fingerPosition.dy < detectionArea &&
        timelineScrollOffset > timelineScrollPosition.minScrollExtent) {
      timelineScrollOffset = max(
        timelineScrollOffset - moveDistance,
        timelineScrollPosition.minScrollExtent,
      );
    } else {
      final weekPickerPosition = _weekPickerController.position;

      // Checking if scroll is finished
      if (!weekPickerPosition.isScrollingNotifier.value) {
        if (fingerPosition.dx > timelineBox.size.width - detectionArea &&
            weekPickerPosition.pixels < weekPickerPosition.maxScrollExtent) {
          widget.controller.next();
        } else if (fingerPosition.dx < detectionArea &&
            weekPickerPosition.pixels > weekPickerPosition.minScrollExtent) {
          widget.controller.prev();
        }
      }

      _scrolling = false;
      return;
    }

    await timelineScrollPosition.animateTo(
      timelineScrollOffset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );

    if (_scrolling) await _scrollIfNecessary();
  }

  void _stopAutoScrolling() {
    _stopTimelineScrolling();
    _scrolling = false;
  }

  void _autoScrolling(DragUpdateDetails details) {
    _pointerLocation = details.globalPosition;
    if (!_scrolling) _scrollIfNecessary();
  }

  @override
  void initState() {
    super.initState();
    _weekPickerController = PageController(
      initialPage: _displayedWeek.start.difference(_initialWeek.start).inWeeks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WeekViewController, WeekViewState>(
      bloc: widget.controller,
      listener: (context, state) {
        final weeksOffset =
            state.displayedWeek.start.difference(_initialWeek.start).inWeeks;

        if (state is WeekViewCurrentWeekIsSet) {
          Future.wait([
            if (weeksOffset != _weekPickerController.page?.round())
              _weekPickerController.animateToPage(
                weeksOffset,
                duration: const Duration(milliseconds: 400),
                curve: Curves.linearToEaseOut,
              ),
          ]).whenComplete(() {
            // Scroll the timeline just after current week is displayed
            final timelineOffset = min(
              state.focusedDate.hour * _hourExtent,
              _timelineController!.position.maxScrollExtent,
            );

            if (timelineOffset != _timelineController!.offset) {
              _timelineController!.animateTo(
                timelineOffset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastLinearToSlowEaseIn,
              );
            }
          });
        } else if (state is WeekViewNextWeekSelected ||
            state is WeekViewPrevWeekSelected) {
          _weekPickerController.animateToPage(
            weeksOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linearToEaseOut,
          );
        }
      },
      child: Column(
        children: [
          _weekPicker(),
          Expanded(
            child: DraggableEventOverlay<T>(
              _elevatedEvent,
              padding: EdgeInsets.only(
                top: widget.daysRowTheme.height + (widget.divider?.height ?? 0),
              ),
              timelineTheme: widget.timelineTheme,
              onDragDown: _stopTimelineScrolling,
              onDragUpdate: _autoScrolling,
              onDragEnd: _stopAutoScrolling,
              onSizeUpdate: _autoScrolling,
              onResizingEnd: _stopAutoScrolling,
              onDropped: widget.onEventUpdated,
              getTimelineBox: _getTimelineBox,
              getLayoutBox: _getLayoutBox,
              getEventBox: _getEventBox,
              child: _weekTimeline(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _elevatedEvent.dispose();
    _weekPickerController.dispose();
    _timelineController?.dispose();
    super.dispose();
  }

  Widget _weekPicker() => BlocBuilder<WeekViewController, WeekViewState>(
        bloc: widget.controller,
        builder: (context, state) {
          final days = state.displayedWeek.days;

          return DisplayedPeriodPicker(
            period: DisplayedPeriod(days.first, days.last),
            theme: widget.weekPickerTheme,
            reverseAnimation: state.reverseAnimation,
            onLeftButtonPressed: state.focusedDate.isSameWeekAs(_initialDate)
                ? null
                : widget.controller.prev,
            onRightButtonPressed: state.focusedDate.isSameWeekAs(_endDate)
                ? null
                : widget.controller.next,
          );
        },
        buildWhen: (previous, current) =>
            !current.focusedDate.isSameWeekAs(previous.focusedDate),
      );

  Widget _weekTimeline() {
    final theme = widget.timelineTheme;
    final timeScaleWidth = theme.timeScaleTheme.width;

    return PageView.builder(
      controller: _weekPickerController,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, pageIndex) {
        final weekdays = widget.controller.state.displayedWeek.days;

        return Padding(
          padding: EdgeInsets.only(
            left: theme.padding.left,
            right: theme.padding.right,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: timeScaleWidth),
                child: _daysRow(weekdays),
              ),
              widget.divider ?? const SizedBox.shrink(),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      left: timeScaleWidth,
                      child: _stripesRow(weekdays),
                    ),
                    _timeline(weekdays),
                    Positioned.fill(
                      left: timeScaleWidth,
                      child: _dragTargetsRow(weekdays),
                    ),
                  ],
                ),
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
                    if (!theme.hideNumber)
                      Text(
                        theme.numberFormatter.call(dayDate),
                        style: theme.numberStyle,
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

  Widget _stripesRow(List<DateTime> days) => Row(
        children: List.generate(
          days.length,
          (index) => Expanded(
            child: ColoredBox(
              color: index.isOdd
                  ? Colors.transparent
                  : Colors.grey.withOpacity(0.1),
              child: const SizedBox.expand(),
            ),
          ),
          growable: false,
        ),
      );

  Widget _dragTargetsRow(List<DateTime> days) => Row(
        children: days
            .map(
              (dayDate) => Expanded(
                child: DragTarget<T>(
                  onMove: (details) {
                    final layoutBox = _getLayoutBox(dayDate)!;
                    final dy = layoutBox.globalToLocal(details.offset).dy;
                    final offset =
                        dy.isNegative ? 0 : min(dy, layoutBox.size.height);
                    final minutes = offset ~/ _minuteExtent;
                    final roundedMinutes =
                        (minutes / _cellExtent).round() * _cellExtent;
                    final timestamp =
                        dayDate.add(Duration(minutes: roundedMinutes));

                    _elevatedEvent.value = details.data.copyWith(
                      start: timestamp.isBefore(_initialDate)
                          ? _initialDate
                          : (_endDate?.isAfter(timestamp) ?? true)
                              ? timestamp
                              : _endDate,
                    ) as T;
                  },
                  builder: (context, candidates, rejects) =>
                      const SizedBox.expand(),
                ),
              ),
            )
            .toList(growable: false),
      );

  Widget _timeline(List<DateTime> days) {
    final theme = widget.timelineTheme;
    final isCurrentWeek = days.first.isSameWeekAs(_now);

    return LayoutBuilder(
      builder: (context, constraints) {
        final scrollOffset = _timelineController?.offset ??
            min(
              _focusedDate.hour * _hourExtent,
              _dayExtent + theme.padding.vertical - constraints.maxHeight,
            );

        // Dispose the previous week timeline controller
        _timelineController?.dispose();
        _timelineController = ScrollController(
          initialScrollOffset: scrollOffset,
        );

        return SingleChildScrollView(
          key: WeekViewKeys.timeline = GlobalKey(),
          controller: _timelineController,
          padding: EdgeInsets.only(
            top: theme.padding.top,
            bottom: theme.padding.bottom,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                TimeScale(
                  showCurrentTimeMark: isCurrentWeek,
                  theme: theme.timeScaleTheme,
                ),
                ...days.map(_singleDayView),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _singleDayView(DateTime dayDate) => Expanded(
        child: ValueListenableBuilder(
          valueListenable: _elevatedEvent,
          builder: (context, elevatedEvent, child) => AbsorbPointer(
            absorbing: elevatedEvent != null,
            child: child,
          ),
          child: GestureDetector(
            onLongPressStart: (details) {
              final minutes = details.localPosition.dy ~/ _minuteExtent;
              final roundedMinutes =
                  (minutes / _cellExtent).round() * _cellExtent;
              final timestamp = dayDate.add(Duration(minutes: roundedMinutes));

              if (timestamp.isBefore(_initialDate)) return;
              if ((_endDate != null) && timestamp.isAfter(_endDate!)) return;

              widget.onDateLongPress?.call(timestamp);
            },
            behavior: HitTestBehavior.opaque,
            child: EventsLayout<T>(
              dayDate: dayDate,
              layoutsKeys: WeekViewKeys.layouts,
              eventsKeys: WeekViewKeys.events,
              timelineTheme: widget.timelineTheme,
              breaks: widget.breaks,
              events: widget.events,
              elevatedEvent: _elevatedEvent,
              onEventTap: widget.onEventTap,
            ),
          ),
        ),
      );
}
