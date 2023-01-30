import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/controllers/controllers.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/custom_widgets.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/themes.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

/// A key holder of all DaysView keys
@visibleForTesting
abstract class DaysViewKeys {
  /// A key for the timeline view
  static final timeline = GlobalKey();

  /// Map of keys for the events layouts (by day date)
  static final layouts = <DateTime, GlobalKey>{};

  /// Map of keys for the displayed events (by event object)
  static final events = <CalendarEvent, GlobalKey>{};
}

/// Days view displays a timeline and has ability to move to a specific date.
class DaysView<T extends FloatingCalendarEvent> extends StatefulWidget {
  /// Creates a Days view, [controller] is required.
  const DaysView({
    super.key,
    required this.controller,
    this.monthPickerTheme = const DisplayedPeriodPickerTheme(),
    this.daysListTheme = const DaysListTheme(),
    this.timelineTheme = const TimelineTheme(),
    this.floatingEventTheme = const FloatingEventTheme(),
    this.breaks = const [],
    this.events = const [],
    this.onEventTap,
    this.onDateLongPress,
  });

  /// Controller which allows to control the view
  final DaysViewController controller;

  /// The month picker customization params
  final DisplayedPeriodPickerTheme monthPickerTheme;

  /// The days list customization params
  final DaysListTheme daysListTheme;

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
  State<DaysView<T>> createState() => _DaysViewState<T>();
}

class _DaysViewState<T extends FloatingCalendarEvent> extends State<DaysView<T>>
    with SingleTickerProviderStateMixin {
  final _elevatedEvent = ValueNotifier<T?>(null);
  final _elevatedEventBounds = RectNotifier();
  late final PageController _monthPickerController;
  late final ScrollController _timelineController;
  var _fingerPosition = Offset.zero;
  var _scrolling = false;
  var _dragging = false;
  var _resizing = false;
  ScrollController? _daysListController;

  DateTime get _now => clock.now();
  DateTime get _initialDate => widget.controller.initialDate;
  DateTime? get _endDate => widget.controller.endDate;
  DateTime get _displayedDate => widget.controller.state.displayedDate;

  double get _minuteExtent => _hourExtent / Duration.minutesPerHour;
  double get _hourExtent => widget.timelineTheme.timeScaleTheme.hourExtent;
  double get _dayExtent => _hourExtent * Duration.hoursPerDay;

  int get _cellExtent => widget.timelineTheme.cellExtent;

  RenderBox? _getTimelineBox() =>
      DaysViewKeys.timeline.currentContext?.findRenderObject() as RenderBox?;

  RenderBox? _getLayoutBox(DateTime dayDate) =>
      DaysViewKeys.layouts[dayDate]?.currentContext?.findRenderObject()
          as RenderBox?;

  RenderBox? _getEventBox(T event) =>
      DaysViewKeys.events[event]?.currentContext?.findRenderObject()
          as RenderBox?;

  void _stopTimelineScrolling() =>
      _timelineController.jumpTo(_timelineController.offset);

  Future<void> _scrollIfNecessary() async {
    return;

    _scrolling = true;

    // final overlayBox =
    //     _overlayKey.currentContext!.findRenderObject()! as RenderBox;
    // final overlayPosition = overlayBox.localToGlobal(Offset.zero);
    // final top = overlayPosition.dy;
    // final bottom = top + overlayBox.size.height;
    //
    // const detectionArea = 25;
    // const moveDistance = 25;
    // final timelineScrollPosition = _timelineController.position;
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

  void _updateFocusedDate() {
    final daysOffset = _timelineController.offset ~/ _dayExtent;
    final displayedDay = DateUtils.addDaysToDate(_initialDate, daysOffset);
    final offsetInMinutes =
        (_timelineController.offset % _minuteExtent).truncate();
    final displayedDate = displayedDay.addMinutesToDayDate(offsetInMinutes);
    widget.controller.setFocusedDate(displayedDate);
  }

  void _elevatedEventBoundsListener() => _elevatedEventBounds.height = max(
        _elevatedEventBounds.height,
        _minuteExtent * _cellExtent,
      );

  void _updateElevatedEventStart() {
    final displayedDay = DateUtils.dateOnly(_displayedDate);
    final timelineBox = _getTimelineBox()!;
    final layoutBox = _getLayoutBox(displayedDay)!;
    final eventPosition = layoutBox.globalToLocal(
      _elevatedEventBounds.origin,
      ancestor: timelineBox,
    );

    final startOffsetInMinutes = eventPosition.dy / _minuteExtent;
    final roundedOffset =
        (startOffsetInMinutes / _cellExtent).round() * _cellExtent;
    final newStart = displayedDay.addMinutesToDayDate(roundedOffset);

    _elevatedEvent.value = _elevatedEvent.value!.copyWith(
      start: newStart.isBefore(_initialDate) ? _initialDate : newStart,
    ) as T;

    // Event position correction
    _elevatedEventBounds.origin = timelineBox.globalToLocal(
      layoutBox.localToGlobal(Offset(0, roundedOffset * _minuteExtent)),
    );
  }

  void _updateElevatedEventDuration() {
    final displayedDay = DateUtils.dateOnly(_displayedDate);
    final timelineBox = _getTimelineBox()!;
    final layoutBox = _getLayoutBox(displayedDay)!;
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

  int _getMonthsDeltaForDate(DateTime date) =>
      DateUtils.monthDelta(_initialDate, date);

  double _getDaysListOffsetForDate(DateTime date) => min(
        (date.day - 1) * widget.daysListTheme.itemExtent,
        _daysListController!.position.maxScrollExtent,
      );

  double _getTimelineOffsetForDate(DateTime date) {
    final timeZoneDiff = date.timeZoneOffset - _initialDate.timeZoneOffset;
    final timeDiff = date.difference(_initialDate) + timeZoneDiff;
    return timeDiff.inHours * _hourExtent;
  }

  @override
  void initState() {
    super.initState();
    _monthPickerController = PageController(
      initialPage: DateUtils.monthDelta(_initialDate, _displayedDate),
    );
    _timelineController = ScrollController(
      initialScrollOffset: _getTimelineOffsetForDate(_displayedDate),
    )..addListener(_updateFocusedDate);
    _elevatedEventBounds.addListener(_elevatedEventBoundsListener);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DaysViewController, DaysViewState>(
      bloc: widget.controller,
      listener: (context, state) {
        if (state is DaysViewDaySelected || state is DaysViewCurrentDateIsSet) {
          final timelineOffset = _getTimelineOffsetForDate(_displayedDate);

          if (timelineOffset != _timelineController.offset) {
            _timelineController
              ..removeListener(_updateFocusedDate)
              ..animateTo(
                timelineOffset,
                duration: const Duration(milliseconds: 450),
                curve: Curves.fastLinearToSlowEaseIn,
              ).whenComplete(() {
                // Checking if scroll is finished
                if (!_timelineController.position.isScrollingNotifier.value) {
                  _timelineController.addListener(_updateFocusedDate);
                }
              });
          }

          if (state is DaysViewCurrentDateIsSet) {
            // Reset displayed month
            final displayedMonth = _getMonthsDeltaForDate(_displayedDate);
            final daysListOffset = _getDaysListOffsetForDate(_displayedDate);

            if (displayedMonth != _monthPickerController.page?.round()) {
              // Switch displayed month
              _monthPickerController.animateToPage(
                displayedMonth,
                duration: const Duration(milliseconds: 150),
                curve: Curves.linear,
              );
            } else if (daysListOffset != _daysListController!.offset) {
              _daysListController!.animateTo(
                daysListOffset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastLinearToSlowEaseIn,
              );
            }
          }
        } else if (state is DaysViewFocusedDateIsSet) {
          // User scrolls a timeline
          final focusedDate = state.focusedDate;
          final displayedMonth = _getMonthsDeltaForDate(focusedDate);
          final daysListOffset = _getDaysListOffsetForDate(focusedDate);

          if (displayedMonth != _monthPickerController.page?.round()) {
            // Switch displayed month
            _monthPickerController.animateToPage(
              displayedMonth,
              duration: const Duration(milliseconds: 150),
              curve: Curves.linear,
            );
          } else if (daysListOffset != _daysListController!.offset) {
            _daysListController!.animateTo(
              daysListOffset,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
            );
          }
        } else if (state is DaysViewNextMonthSelected ||
            state is DaysViewPrevMonthSelected) {
          _stopTimelineScrolling();
          // Change a displayed month
          _monthPickerController.animateToPage(
            _getMonthsDeltaForDate(state.displayedDate),
            duration: const Duration(milliseconds: 450),
            curve: Curves.fastLinearToSlowEaseIn,
          );
        }
      },
      child: Column(
        children: [
          _monthPicker(),
          _daysList(),
          Expanded(
            child: _timeline(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _elevatedEventBounds.dispose();
    _elevatedEvent.dispose();
    _monthPickerController.dispose();
    _daysListController?.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  Widget _monthPicker() => BlocBuilder<DaysViewController, DaysViewState>(
        bloc: widget.controller,
        builder: (context, state) => DisplayedPeriodPicker(
          period: DisplayedPeriod(state.displayedDate),
          theme: widget.monthPickerTheme,
          reverseAnimation: state.reverseAnimation,
          onLeftButtonPressed:
              DateUtils.isSameMonth(state.displayedDate, _initialDate)
                  ? null
                  : widget.controller.prev,
          onRightButtonPressed:
              DateUtils.isSameMonth(state.displayedDate, _endDate)
                  ? null
                  : widget.controller.next,
        ),
        buildWhen: (previous, current) => !DateUtils.isSameMonth(
          previous.displayedDate,
          current.displayedDate,
        ),
      );

  Widget _daysList() {
    final theme = widget.daysListTheme;

    return SizedBox(
      height: theme.height,
      child: PageView.builder(
        controller: _monthPickerController,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, pageIndex) {
          final monthDate =
              DateUtils.addMonthsToMonthDate(_initialDate, pageIndex);
          final daysInMonth = DateUtils.getDaysInMonth(
            _displayedDate.year,
            _displayedDate.month,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              // Dispose the previous list controller
              _daysListController?.dispose();
              _daysListController = ScrollController(
                initialScrollOffset: min(
                  (_displayedDate.day - 1) * theme.itemExtent,
                  daysInMonth * theme.itemExtent - constraints.maxWidth,
                ),
              );

              return NotificationListener<UserScrollNotification>(
                onNotification: (event) {
                  // Stop scrolling the timeline if user scrolls the list
                  if (event.direction != ScrollDirection.idle) {
                    _stopTimelineScrolling();
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: _daysListController,
                  scrollDirection: Axis.horizontal,
                  physics: theme.physics,
                  itemExtent: theme.itemExtent,
                  itemCount: daysInMonth,
                  itemBuilder: (context, index) {
                    final dayDate = DateUtils.addDaysToDate(monthDate, index);

                    return BlocBuilder<DaysViewController, DaysViewState>(
                      bloc: widget.controller,
                      builder: (context, state) => DaysListItem(
                        dayDate: dayDate,
                        isFocused:
                            DateUtils.isSameDay(state.focusedDate, dayDate),
                        theme: theme.itemTheme,
                        onTap: () => widget.controller.selectDay(dayDate),
                      ),
                      buildWhen: (previous, current) =>
                          DateUtils.isSameDay(current.focusedDate, dayDate) ||
                          DateUtils.isSameDay(previous.focusedDate, dayDate),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _timeline() {
    final theme = widget.timelineTheme;

    return Stack(
      children: [
        NotificationListener<ScrollUpdateNotification>(
          onNotification: (event) {
            final delta = Offset(0, event.scrollDelta ?? 0);
            // Update nothing if user drags the event by himself/herself
            if (!_dragging && delta != Offset.zero) {
              _elevatedEventBounds.origin -= delta;
              if (_resizing) _elevatedEventBounds.size += delta;
            }
            return true;
          },
          child: ListView.builder(
            key: DaysViewKeys.timeline,
            controller: _timelineController,
            padding: EdgeInsets.only(
              top: theme.padding.top,
              bottom: theme.padding.bottom,
            ),
            itemExtent: _dayExtent,
            itemCount: (_endDate != null)
                ? _endDate!.difference(_initialDate).inDays + 1
                : null,
            itemBuilder: (context, index) {
              final dayDate = DateUtils.addDaysToDate(_initialDate, index);
              final isToday = DateUtils.isSameDay(dayDate, _now);

              return Padding(
                padding: EdgeInsets.only(
                  left: theme.padding.left,
                  right: theme.padding.right,
                ),
                child: TimeScale(
                  showCurrentTimeMark: isToday,
                  theme: theme.timeScaleTheme,
                  child: EventsLayout(
                    dayDate: dayDate,
                    layoutsKeys: DaysViewKeys.layouts,
                    eventsKeys: DaysViewKeys.events,
                    cellExtent: _cellExtent,
                    breaks: widget.breaks,
                    events: widget.events,
                    elevatedEvent: _elevatedEvent,
                    onEventTap: widget.onEventTap,
                    onEventLongPress: (event) => _elevatedEvent.value = event,
                    onLayoutLongPress: widget.onDateLongPress,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: _elevatedEventView(),
        ),
      ],
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
