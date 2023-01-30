import 'dart:async';
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
    this.floatingEventTheme = const FloatingEventTheme(),
    this.breaks = const [],
    this.events = const [],
    this.onEventTap,
    this.onDateLongPress,
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
  final FloatingEventTheme floatingEventTheme;

  /// Breaks list to display
  final List<Break> breaks;

  /// Events list to display
  final List<T> events;

  /// Returns the tapped event
  final void Function(T)? onEventTap;

  /// Returns selected timestamp (to the minute)
  final void Function(DateTime)? onDateLongPress;

  @override
  State<WeekView<T>> createState() => _WeekViewState<T>();
}

class _WeekViewState<T extends FloatingCalendarEvent> extends State<WeekView<T>>
    with SingleTickerProviderStateMixin {
  final _elevatedEvent = ValueNotifier<T?>(null);
  final _elevatedEventBounds = RectNotifier();
  final _weekdayPosition = ValueNotifier(0);
  late final PageController _weekPickerController;
  var _fingerPosition = Offset.zero;
  var _scrolling = false;
  var _dragging = false;
  var _resizing = false;
  ScrollController? _timelineController;

  DateTime get _now => clock.now();
  DateTime get _initialDate => widget.controller.initialDate;
  DateTime? get _endDate => widget.controller.endDate;
  DateTime get _focusedDate => widget.controller.state.focusedDate;
  DateTime get _displayedDate => _displayedWeek.days[_weekdayPosition.value];
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
    return;

    _scrolling = true;

    // final overlayBox =
    //     _overlayKey.currentContext!.findRenderObject()! as RenderBox;
    // final overlayPosition = overlayBox.localToGlobal(Offset.zero);
    // final top = overlayPosition.dy;
    // final bottom = top + overlayBox.size.height;
    // final left = overlayPosition.dx;
    // final right = left + overlayBox.size.width;
    //
    // const detectionArea = 25;
    // const moveDistance = 25;
    // final timelineScrollPosition = _timelineController!.position;
    // var timelineScrollOffset = timelineScrollPosition.pixels;
    //
    // if (bottom - _fingerPosition.dy < detectionArea &&
    //     timelineScrollOffset < timelineScrollPosition.maxScrollExtent) {
    //   timelineScrollOffset = min(
    //     timelineScrollOffset + moveDistance,
    //     timelineScrollPosition.maxScrollExtent,
    //   );
    // } else if (_fingerPosition.dy - top < detectionArea &&
    //     timelineScrollOffset > timelineScrollPosition.minScrollExtent) {
    //   timelineScrollOffset = max(
    //     timelineScrollOffset - moveDistance,
    //     timelineScrollPosition.minScrollExtent,
    //   );
    // } else {
    //   final weekPickerPosition = _weekPickerController.position;
    //
    //   // Checking if scroll is finished
    //   if (!weekPickerPosition.isScrollingNotifier.value) {
    //     if (right - _fingerPosition.dx < detectionArea &&
    //         weekPickerPosition.pixels < weekPickerPosition.maxScrollExtent) {
    //       widget.controller.next();
    //     } else if (_fingerPosition.dx - left < detectionArea &&
    //         weekPickerPosition.pixels > weekPickerPosition.minScrollExtent) {
    //       widget.controller.prev();
    //     }
    //   }
    //
    //   _scrolling = false;
    //   return;
    // }
    //
    // await timelineScrollPosition.animateTo(
    //   timelineScrollOffset,
    //   duration: const Duration(milliseconds: 100),
    //   curve: Curves.linear,
    // );

    if (_scrolling) unawaited(_scrollIfNecessary());
  }

  void _stopAutoScrolling() => _scrolling = false;

  void _autoScrolling(DragUpdateDetails details) {
    _fingerPosition = details.globalPosition;
    if (!_scrolling) _scrollIfNecessary();
  }

  void _elevatedEventBoundsListener() => _elevatedEventBounds.height = max(
        _elevatedEventBounds.height,
        _minuteExtent * _cellExtent,
      );

  void _updateElevatedEventStart() {
    final timelineBox = _getTimelineBox()!;
    final layoutBox = _getLayoutBox(_displayedDate)!;
    final eventPosition = layoutBox.globalToLocal(
      _elevatedEventBounds.origin,
      ancestor: timelineBox,
    );

    final startOffsetInMinutes = eventPosition.dy / _minuteExtent;
    final roundedOffset =
        (startOffsetInMinutes / _cellExtent).round() * _cellExtent;
    final newStart = _displayedDate.addMinutesToDayDate(roundedOffset);

    _elevatedEvent.value = _elevatedEvent.value!.copyWith(
      start: newStart.isBefore(_initialDate) ? _initialDate : newStart,
    ) as T;

    // Event position correction
    _elevatedEventBounds.origin = timelineBox.globalToLocal(
      layoutBox.localToGlobal(Offset(0, roundedOffset * _minuteExtent)),
    );
  }

  void _updateElevatedEventDuration() {
    final timelineBox = _getTimelineBox()!;
    final layoutBox = _getLayoutBox(_displayedDate)!;
    final eventPosition = layoutBox.globalToLocal(
      _elevatedEventBounds.origin,
      ancestor: timelineBox,
    );

    final endOffsetInMinutes =
        _elevatedEventBounds.size.bottomRight(eventPosition).dy / _minuteExtent;
    final roundedOffset =
        (endOffsetInMinutes / _cellExtent).round() * _cellExtent;
    final newHeight = roundedOffset * _minuteExtent - eventPosition.dy;

    _elevatedEvent.value =
        (_elevatedEvent.value! as EditableCalendarEvent).copyWith(
      duration: Duration(minutes: newHeight ~/ _minuteExtent),
    ) as T;

    // Event height correction
    _elevatedEventBounds.height = newHeight;
  }

  Rect? _getEventBoundsOnTimeline(T event) {
    final eventBox = _getEventBox(event);

    if (eventBox == null) return null;

    final eventPosition = eventBox.localToGlobal(
      Offset.zero,
      ancestor: _getTimelineBox(),
    );

    return eventPosition & eventBox.size;
  }

  Rect _getExpandedEventBounds(T event) {
    final dayDate = DateUtils.dateOnly(event.start);
    final layoutBox = _getLayoutBox(dayDate)!;
    final layoutPosition = layoutBox.localToGlobal(
      Offset.zero,
      ancestor: _getTimelineBox(),
    );
    final eventBox = _getEventBox(event)!;
    final eventPosition = eventBox.localToGlobal(
      layoutPosition,
      ancestor: layoutBox,
    );

    return Rect.fromLTWH(
      layoutPosition.dx,
      eventPosition.dy,
      layoutBox.size.width,
      eventBox.size.height,
    );
  }

  @override
  void initState() {
    super.initState();
    _weekPickerController = PageController(
      initialPage: _displayedWeek.start.difference(_initialWeek.start).inWeeks,
    );
    _elevatedEventBounds.addListener(_elevatedEventBoundsListener);

    // _weekdayPosition.addListener(
    //   () {
    //     final timelineBox = _getTimelineBox()!;
    //     final layoutBox = _getLayoutBox(_displayedDate)!;
    //     final layoutPosition = layoutBox.localToGlobal(
    //       Offset.zero,
    //       ancestor: timelineBox,
    //     );
    //     _elevatedEventBounds.dx = layoutPosition.dx;
    //   },
    // );
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
            child: _weekTimeline(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _elevatedEventBounds.dispose();
    _elevatedEvent.dispose();
    _weekdayPosition.dispose();
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
    const daysInWeek = 7;

    return Stack(
      children: [
        PageView.builder(
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
                          child: _stripesRow(daysInWeek),
                        ),
                        _timeline(weekdays),
                        Positioned.fill(
                          left: timeScaleWidth,
                          child: _dragTargetsRow(daysInWeek),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Positioned.fill(
          top: widget.daysRowTheme.height + (widget.divider?.height ?? 0),
          child: _elevatedEventView(),
        ),
      ],
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

  Widget _stripesRow(int length) => Row(
        children: List.generate(
          length,
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

  Widget _dragTargetsRow(int length) => Row(
        children: List.generate(
          length,
          (index) => Expanded(
            child: DragTarget<T>(
              onMove: (details) => _weekdayPosition.value = index,
              builder: (context, candidates, rejects) =>
                  const SizedBox.expand(),
            ),
          ),
          growable: false,
        ),
      );

  Widget _timeline(List<DateTime> days) {
    final theme = widget.timelineTheme;
    final isCurrentWeek = days.first.isSameWeekAs(_now);

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (event) {
        final delta = Offset(0, event.scrollDelta ?? 0);
        // Update nothing if user drags the event by himself/herself
        if (!_dragging && delta != Offset.zero) {
          _elevatedEventBounds.origin -= delta;
          if (_resizing) _elevatedEventBounds.size += delta;
        }
        return true;
      },
      child: LayoutBuilder(
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
            child: SizedBox(
              height: _dayExtent,
              child: TimeScale(
                showCurrentTimeMark: isCurrentWeek,
                theme: theme.timeScaleTheme,
                child: Row(
                  children: days
                      .map(
                        (dayDate) => Expanded(
                          child: EventsLayout(
                            dayDate: dayDate,
                            layoutsKeys: WeekViewKeys.layouts,
                            eventsKeys: WeekViewKeys.events,
                            cellExtent: _cellExtent,
                            breaks: widget.breaks,
                            events: widget.events,
                            elevatedEvent: _elevatedEvent,
                            onEventTap: widget.onEventTap,
                            onEventLongPress: (event) =>
                                _elevatedEvent.value = event,
                            onLayoutLongPress: widget.onDateLongPress,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _elevatedEventView() => DraggableEventView(
        _elevatedEvent,
        elevation: 5,
        bounds: _elevatedEventBounds,
        curve: Curves.fastOutSlowIn,
        getEventBounds: _getEventBoundsOnTimeline,
        expandTo: _getExpandedEventBounds,
        onDragDown: (details) => _stopTimelineScrolling(),
        onDragStart: () => _dragging = true,
        onDragUpdate: (details) {
          _elevatedEventBounds.origin += details.delta;
          _autoScrolling(details);
        },
        onDragEnd: (details) {
          _stopAutoScrolling();
          _updateElevatedEventStart();
          _dragging = false;
        },
        onDraggableCanceled: (velocity, offset) => _dragging = false,
        onResizingStart: (details) => _resizing = true,
        onSizeUpdate: (details) {
          _elevatedEventBounds.size += details.delta;
          _autoScrolling(details);
        },
        onResizingEnd: (details) {
          _stopAutoScrolling();
          _updateElevatedEventDuration();
          _resizing = false;
        },
        onResizingCancel: () => _resizing = false,
        onDropped: () => _elevatedEvent.value = null,
      );
}
