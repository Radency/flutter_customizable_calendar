import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_customizable_calendar/src/custom/custom_linked_scroll_controller.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/month_show_more_theme.dart';
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
  /// Creates a Month view. Parameters [saverConfig] [controller] are required.
  const MonthView({
    required this.saverConfig,
    required this.controller,
    super.key,
    this.monthPickerTheme = const DisplayedPeriodPickerTheme(),
    this.daysRowTheme = const DaysRowTheme(),
    this.divider,
    this.timelineTheme = const TimelineTheme(),
    this.floatingEventTheme = const FloatingEventsTheme(),
    this.monthDayTheme = const MonthDayTheme(),
    this.showMoreTheme = const MonthShowMoreTheme(),
    this.onShowMoreTap,
    this.breaks = const [],
    this.events = const [],
    this.onDateLongPress,
    this.onEventTap,
    this.onEventUpdated,
    this.onDiscardChanges,
    this.eventBuilders = const {},
    this.pageViewPhysics
  });

  /// Enable page view physics
  final ScrollPhysics? pageViewPhysics;

  /// Controller which allows to control the view
  final MonthViewController controller;

  /// The month picker customization params
  final DisplayedPeriodPickerTheme monthPickerTheme;

  /// Event builders
  final Map<Type, EventBuilder> eventBuilders;

  /// The days list customization params
  final DaysRowTheme daysRowTheme;

  /// The theme of show more button
  final MonthShowMoreTheme? showMoreTheme;

  /// The callback which is called when user taps on show more button
  final void Function(List<T> events, DateTime day)? onShowMoreTap;

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
  final Future<CalendarEvent?> Function(DateTime)? onDateLongPress;

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

class _MonthViewState<T extends FloatingCalendarEvent>
    extends State<MonthView<T>> {
  final _overlayKey = GlobalKey<DraggableEventOverlayState<T>>();
  final _elevatedEvent = FloatingEventNotifier<T>();
  late final PageController _monthPickerController;
  var _pointerLocation = Offset.zero;
  var _scrolling = false;
  Map<DateTime, List<T>> dayEventMap = {};
  Map<DateTime, ScrollController> dayControllerMap = {};
  List<T> events = [];

  static DateTime get _now => clock.now();

  DateTime get _initialDate => widget.controller.initialDate;

  DateTime? get _endDate => widget.controller.endDate;

  DateTime get _monthDate =>
      _displayedMonth.start.add(const Duration(days: 14));

  DateTimeRange get _displayedMonth => widget.controller.state.displayedMonth;

  late final ScrollController _forward;
  late final ScrollController _backward;

  RenderBox? _getTimelineBox() =>
      MonthViewKeys.timeline?.currentContext?.findRenderObject() as RenderBox?;

  RenderBox? _getLayoutBox(DateTime dayDate) =>
      MonthViewKeys.layouts[dayDate]?.currentContext?.findRenderObject()
          as RenderBox?;

  RenderBox? _getEventBox(T event) =>
      MonthViewKeys.events[event]?.currentContext?.findRenderObject()
          as RenderBox?;

  Future<void> _scrollIfNecessary() async {
    final timelineBox = _getTimelineBox();

    _scrolling = timelineBox != null;

    if (!_scrolling) return; // Scrollable isn't found

    final fingerPosition = timelineBox!.globalToLocal(_pointerLocation);
    final monthListScrollPosition = _forward.position;
    var monthListScrollOffset = monthListScrollPosition.pixels;

    const detectionArea = 15;
    const moveDistance = 25;

    if (fingerPosition.dy > timelineBox.size.height - detectionArea &&
        monthListScrollOffset < monthListScrollPosition.maxScrollExtent) {
      monthListScrollOffset = min(
        monthListScrollOffset + moveDistance,
        monthListScrollPosition.maxScrollExtent,
      );
    } else if (fingerPosition.dy < detectionArea &&
        monthListScrollOffset > monthListScrollPosition.minScrollExtent) {
      monthListScrollOffset = max(
        monthListScrollOffset - moveDistance,
        monthListScrollPosition.minScrollExtent,
      );
    } else {
      final monthPickerPosition = _monthPickerController.position;

      // Checking if scroll is finished
      if (!monthPickerPosition.isScrollingNotifier.value) {
        if (fingerPosition.dx > timelineBox.size.width - detectionArea &&
            monthPickerPosition.pixels < monthPickerPosition.maxScrollExtent) {
          widget.controller.next();
        } else if (fingerPosition.dx < detectionArea &&
            monthPickerPosition.pixels > monthPickerPosition.minScrollExtent) {
          widget.controller.prev();
        }
      }

      _scrolling = false;
      return;
    }

    await monthListScrollPosition.animateTo(
      monthListScrollOffset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );

    if (_scrolling) await _scrollIfNecessary();
  }

  void _stopAutoScrolling() {
    _scrolling = false;
  }

  void _autoScrolling(DragUpdateDetails details) {
    _pointerLocation = details.globalPosition;
    if (!_scrolling) _scrollIfNecessary();
  }

  @override
  void initState() {
    super.initState();
    final group = LinkedScrollControllerGroup();
    _forward = group.addAndGet();
    _backward = group.addAndGet();
    _monthPickerController = PageController(
      initialPage: DateUtils.monthDelta(_initialDate, _monthDate),
    );
    events = widget.events;
    _initDailyEventsAndControllers();
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
          ]).whenComplete(() {
            _requestDraggableEventOverlayUpdate();
            setState(() {});
          });
        } else if (state is MonthViewNextMonthSelected ||
            state is MonthViewPrevMonthSelected) {
          _monthPickerController
              .animateToPage(
            displayedMonth,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linearToEaseOut,
          )
              .then((value) {
            _requestDraggableEventOverlayUpdate();
          });
        } else {
          _requestDraggableEventOverlayUpdate();
        }

        if (displayedMonth != _monthPickerController.page?.round()) {
          _initDailyEventsAndControllers();
        }
      },
      child: Column(
        children: [
          _monthPicker(),
          Expanded(
            child: DraggableEventOverlay<T>(
              _elevatedEvent,
              key: _overlayKey,
              eventBuilders: widget.eventBuilders,
              viewType: CalendarView.month,
              timelineTheme: widget.timelineTheme,
              padding: EdgeInsets.only(
                top: widget.daysRowTheme.height + (widget.divider?.height ?? 0),
              ),
              onDateLongPress: _onLongPressStart,
              onDragUpdate: _autoScrolling,
              onDragEnd: _stopAutoScrolling,
              onDropped: widget.onDiscardChanges,
              onChanged: (event) async {
                events
                  ..removeWhere((element) => element.id == event.id)
                  ..add(event);
                widget.onEventUpdated?.call(event);
                _initDailyEventsAndControllers();
              },
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

  @override
  void dispose() {
    _forward.dispose();
    _backward.dispose();
    super.dispose();
  }

  void _requestDraggableEventOverlayUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      DraggableEventOverlay.eventUpdatesStreamController.add(0);
    });
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
      physics: widget.pageViewPhysics ?? const NeverScrollableScrollPhysics(),
      onPageChanged: (pageIndex) {
        widget.controller.setPage(pageIndex);
      },
      itemBuilder: (context, pageIndex) {
        // final focusedMonthDays = _displayedMonth.days;
        final monthDays = DateUtils.addMonthsToMonthDate(
          widget.controller.initialDate,
          pageIndex,
        ).monthViewRange.days;

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
        final mainAxisSpacing = theme.mainAxisSpacing;
        final crossAxisSpacing = theme.crossAxisSpacing;
        var aspectRatio = (constraints.maxWidth - crossAxisSpacing * 6) /
            7 /
            (constraints.maxHeight - mainAxisSpacing * 5) *
            6;
        final shouldScroll = aspectRatio > 1;
        if (shouldScroll) {
          aspectRatio = 1.0; // / aspectRatio;
        }

        return Container(
          key: MonthViewKeys.timeline = GlobalKey(),
          padding: const EdgeInsets.only(
            bottom: 1,
          ),
          color: theme.spacingColor ?? widget.divider?.color ?? Colors.grey,
          child: IntrinsicHeight(
            child: Stack(
              children: [
                GridView.count(
                  controller: _backward,
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  childAspectRatio: aspectRatio,
                  physics: shouldScroll
                      ? null
                      : const NeverScrollableScrollPhysics(),
                  children: [
                    ...days.map((day) {
                      final isToday = DateUtils.isSameDay(day, _now);
                      return ColoredBox(
                        color: (isToday
                                ? theme.currentDayColor
                                : theme.dayColor) ??
                            Theme.of(context).scaffoldBackgroundColor,
                      );
                    }),
                  ],
                ),
                GridView.count(
                  controller: _forward,
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  childAspectRatio: aspectRatio,
                  physics: shouldScroll
                      ? null
                      : const NeverScrollableScrollPhysics(),
                  children: [
                    ...days.map(
                      (day) =>
                          _singleDayView(day, constraints.maxWidth * 13 / 7),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _singleDayView(DateTime dayDate, double maxWidth) {
    final theme = widget.monthDayTheme;
    final isToday = DateUtils.isSameDay(dayDate, _now);

    return RenderIdProvider(
      id: dayDate,
      child: ColoredBox(
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
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      width: maxWidth,
                      height: constraints.maxHeight,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight,
                        ),
                        child: EventsLayout<T>(
                          dayDate: dayDate,
                          overlayKey: _overlayKey,
                          layoutsKeys: MonthViewKeys.layouts,
                          eventsKeys: MonthViewKeys.events,
                          timelineTheme: widget.timelineTheme,
                          breaks: widget.breaks,
                          events: dayEventMap[dayDate] ?? [],
                          eventBuilders: widget.eventBuilders,
                          elevatedEvent: _elevatedEvent,
                          onEventTap: widget.onEventTap,
                          viewType: CalendarView.month,
                          dayWidth: maxWidth / 13,
                          showMoreTheme: widget.showMoreTheme,
                          onShowMoreTap: widget.onShowMoreTap,
                          controller: dayControllerMap[dayDate],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initDailyEventsAndControllers() {
    _initDailyEvents();
    _initDailyControllers();
  }

  void _initDailyEvents() {
    final monthDays = _displayedMonth.days;

    for (var i = 0; i < 6; i++) {
      final monday = DateUtils.dateOnly(monthDays[7 * i]);
      dayEventMap[monday] = _getEventsOnDay(events, monday, true);
      for (var j = 1; j < 7; j++) {
        final currentDay = DateUtils.dateOnly(monthDays[7 * i + j]);
        final currentEvents = _getEventsOnDay(events, currentDay)..sort();

        final previousDay = DateUtils.dateOnly(monthDays[7 * i + j - 1]);
        final previousEvents = dayEventMap[previousDay] ?? [];

        for (var k = 0; k < previousEvents.length; k++) {
          final previousEvent = previousEvents[k];
          if (previousEvent.end.isAfter(currentDay) &&
              k <= currentEvents.length) {
            currentEvents.insert(k, previousEvent);
          }
        }

        for (var k = currentEvents.length; k < previousEvents.length; k++) {
          currentEvents.add(previousEvents[k]);
        }

        dayEventMap[currentDay] = currentEvents;
      }
    }
  }

  void _initDailyControllers() {
    final monthDays = _displayedMonth.days;

    LinkedScrollControllerGroup group;

    for (var i = 0; i < 6; i++) {
      final monday = DateUtils.dateOnly(monthDays[7 * i]);
      group = LinkedScrollControllerGroup();
      final controller = group.addAndGet();
      dayControllerMap[monday] = controller;
      for (var j = 1; j < 7; j++) {
        final currentDay = DateUtils.dateOnly(monthDays[7 * i + j]);

        if (_getEventsOnDay(events, currentDay).length ==
            _getEventsOnDay(events, currentDay, true).length) {
          group = LinkedScrollControllerGroup();
        }
        final controller = group.addAndGet();
        dayControllerMap[currentDay] = controller;
      }
    }
  }

  List<E> _getEventsOnDay<E extends CalendarEvent>(
    List<E> list,
    DateTime dayDate, [
    bool all = false,
  ]) {
    if (all) {
      return list
          .where(
            (event) =>
                DateUtils.isSameDay(event.start, dayDate) ||
                (event.start.isBefore(dayDate) && event.end.isAfter(dayDate)),
          )
          .toList(growable: false);
    } else {
      return list
          .where((event) => DateUtils.isSameDay(event.start, dayDate))
          .toList();
    }
  }

  Future<void> _onLongPressStart(DateTime timestamp) async {
    if (timestamp.isBefore(_initialDate)) return;
    if ((_endDate != null) && timestamp.isAfter(_endDate!)) return;

    final newItem = await widget.onDateLongPress?.call(timestamp);
    if (newItem is T) {
      events.add(newItem);
      _initDailyEventsAndControllers();
    }
  }
}
