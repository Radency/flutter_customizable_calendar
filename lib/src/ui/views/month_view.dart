import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_customizable_calendar/src/custom/custom_linked_scroll_controller.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/widget_size.dart';
import 'package:flutter_customizable_calendar/src/utils/floating_event_notifier.dart';

/// A key holder of all MonthView keys
@visibleForTesting
abstract class MonthViewKeys {
  /// A key for the timeline view
  static Map<DateTimeRange, GlobalKey> timeline = {};

  /// Map of keys for the events layouts (by day date)
  static final layouts = <DateTime, GlobalKey>{};

  /// Map of keys for the displayed events (by event object)
  static final events = <CalendarEvent, GlobalKey>{};
}

class MonthView<T extends FloatingCalendarEvent> extends StatefulWidget {
  /// Creates a Month view. Parameters [saverConfig] [controller] are required.
  const MonthView({
    required this.controller,
    this.saverConfig,
    super.key,
    this.monthPickerTheme = const DisplayedPeriodPickerTheme(),
    this.monthPickerBuilder,
    this.daysRowTheme = const DaysRowTheme(),
    this.divider,
    this.timelineTheme = const TimelineTheme(),
    this.floatingEventTheme = const FloatingEventsTheme(),
    this.monthDayTheme = const MonthDayTheme(),
    this.monthDayBuilder,
    this.showMoreTheme = const MonthShowMoreTheme(),
    this.eventsListBuilder,
    this.onShowMoreTap,
    this.breaks = const [],
    this.events = const [],
    this.onDateLongPress,
    this.onEventTap,
    this.onEventUpdated,
    this.onDiscardChanges,
    this.eventBuilders = const {},
    this.pageViewPhysics,
    this.overrideOnEventLongPress,
    this.weekStartsOnSunday = false,
  });

  /// If true, the week starts on Sunday. Otherwise, the week starts on Monday.
  final bool weekStartsOnSunday;

  /// Enable page view physics
  final ScrollPhysics? pageViewPhysics;

  /// Controller which allows to control the view
  final MonthViewController controller;

  /// The month picker customization params.
  /// It works only if [monthPickerBuilder] is not provided.
  final DisplayedPeriodPickerTheme monthPickerTheme;

  /// The month picker builder
  final Widget Function(
    BuildContext,
    void Function() prevMonth,
    void Function() nextMonth,
    DateTime focusedDate,
  )? monthPickerBuilder;

  /// Event builders
  final Map<Type, EventBuilder> eventBuilders;

  /// The days list customization params
  final DaysRowTheme daysRowTheme;

  /// The theme of show more button
  final MonthShowMoreTheme? showMoreTheme;

  /// Custom builder for show more button
  /// Works only if [monthDayBuilder] is not provided
  final List<CustomMonthViewEventsListBuilder<T>> Function(
    BuildContext,
    List<T> events,
    DateTime day,
  )? eventsListBuilder;

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
  /// Works only if [monthDayBuilder] is not provided
  final MonthDayTheme monthDayTheme;

  /// Custom day cell builder
  final Widget Function(
    BuildContext context,
    List<T> events,
    DateTime day,
  )? monthDayBuilder;

  /// Breaks list to display
  final List<Break> breaks;

  /// Events list to display
  final List<T> events;

  /// Returns selected timestamp
  final Future<CalendarEvent?> Function(DateTime)? onDateLongPress;

  /// Overrides the default behavior of the event view's long press
  final void Function(LongPressStartDetails details, T event)?
      overrideOnEventLongPress;

  /// Returns the tapped event
  final void Function(T)? onEventTap;

  /// Is called after an event is modified by user
  final void Function(T)? onEventUpdated;

  /// Is called after user discards changes for event
  final void Function(T)? onDiscardChanges;

  /// Properties for widget which is used to save edited event
  final SaverConfig? saverConfig;

  @override
  State<MonthView<T>> createState() => _MonthViewState<T>();
}

class _MonthViewState<T extends FloatingCalendarEvent>
    extends State<MonthView<T>> {
  final _overlayKey = GlobalKey<DraggableEventOverlayState<T>>();
  final _elevatedEvent = FloatingEventNotifier<T>();
  PageController? _monthPickerController;
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

  DateTimeRange get _displayedMonth => widget.controller.state.displayedMonth(
        weekStartsOnSunday: widget.weekStartsOnSunday,
      );

  late final ScrollController _forward;
  late final ScrollController _backward;

  RenderBox? _getTimelineBox(DateTimeRange key) {
    return MonthViewKeys
        .timeline[DateTimeRange(
      start: DateTime(
        key.start.year,
        key.start.month,
        key.start.day,
      ),
      end: DateTime(
        key.end.year,
        key.end.month,
        key.end.day,
      ),
    )]
        ?.currentContext
        ?.findRenderObject() as RenderBox?;
  }

  RenderBox? _getLayoutBox(DateTime dayDate) =>
      MonthViewKeys.layouts[dayDate]?.currentContext?.findRenderObject()
          as RenderBox?;

  RenderBox? _getEventBox(T event) =>
      MonthViewKeys.events[event]?.currentContext?.findRenderObject()
          as RenderBox?;

  Future<void> _scrollIfNecessary() async {
    final timelineBox = _getTimelineBox(
      widget.controller.state.displayedMonth(
        weekStartsOnSunday: widget.weekStartsOnSunday,
      ),
    );

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
      final monthPickerPosition = _monthPickerController?.position;

      if (monthPickerPosition == null) {
        _scrolling = false;
        return;
      }
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
  void didUpdateWidget(covariant MonthView<T> oldWidget) {
    _initDailyEvents();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MonthViewController, MonthViewState>(
      bloc: widget.controller,
      listener: (context, state) {
        final displayedMonth = DateUtils.monthDelta(
          widget.controller.initialDate,
          state.focusedDate,
        );
        _syncGridViewPosition();

        if (state is MonthViewCurrentMonthIsSet) {
          Future.wait([
            if (displayedMonth != _monthPickerController?.page?.round())
              _monthPickerController!.animateToPage(
                displayedMonth,
                duration: const Duration(milliseconds: 400),
                curve: Curves.linearToEaseOut,
              ),
          ]).whenComplete(() {
            setState(() {});
          });
        } else if (state is MonthViewNextMonthSelected ||
            state is MonthViewPrevMonthSelected) {
          _monthPickerController?.animateToPage(
            displayedMonth,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linearToEaseOut,
          );
        }
        if (displayedMonth != _monthPickerController?.page?.round()) {
          _initDailyEventsAndControllers();
        }
      },
      child: Column(
        children: [
          _monthPicker(),
          BlocBuilder<MonthViewController, MonthViewState>(
            bloc: widget.controller,
            builder: (context, state) {
              return Expanded(
                child: DraggableEventOverlay<T>(
                  _elevatedEvent,
                  key: _overlayKey,
                  onEventLongPressStart: widget.overrideOnEventLongPress,
                  eventBuilders: widget.eventBuilders,
                  viewType: CalendarView.month,
                  timelineTheme: widget.timelineTheme,
                  padding: EdgeInsets.only(
                    top: widget.daysRowTheme.height +
                        (widget.divider?.height ?? 0),
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
                  getTimelineBox: () {
                    return _getTimelineBox(
                      state.displayedMonth(
                        weekStartsOnSunday: widget.weekStartsOnSunday,
                      ),
                    );
                  },
                  getLayoutBox: _getLayoutBox,
                  getEventBox: _getEventBox,
                  saverConfig: widget.saverConfig ?? SaverConfig.def(),
                  child: _monthSection(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _forward.dispose();
    _backward.dispose();
    _monthPickerController?.dispose();
    super.dispose();
  }

  Widget _monthPicker() => BlocBuilder<MonthViewController, MonthViewState>(
        bloc: widget.controller,
        builder: (context, state) {
          if (widget.monthPickerBuilder != null) {
            return widget.monthPickerBuilder!.call(
              context,
              widget.controller.prev,
              widget.controller.next,
              widget.controller.state.focusedDate,
            );
          }

          return DisplayedPeriodPicker(
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
          );
        },
        buildWhen: (previous, current) => !DateUtils.isSameMonth(
          previous.focusedDate,
          current.focusedDate,
        ),
      );

  Widget _monthSection() {
    final theme = widget.timelineTheme;

    _monthPickerController?.dispose();
    _monthPickerController = PageController(
      initialPage: DateUtils.monthDelta(_initialDate, _monthDate),
    );

    return PageView.builder(
      controller: _monthPickerController,
      physics: widget.pageViewPhysics ?? const NeverScrollableScrollPhysics(),
      onPageChanged: (pageIndex) {
        widget.controller.setPage(pageIndex);
        _syncGridViewPosition();
      },
      dragStartBehavior: DragStartBehavior.down,
      itemBuilder: (context, pageIndex) {
        final monthDays = DateUtils.addMonthsToMonthDate(
          widget.controller.initialDate,
          pageIndex,
        )
            .monthViewRange(
              weekStartsOnSunday: widget.weekStartsOnSunday,
            )
            .days;

        return Padding(
          key: ValueKey(widget.controller.state.focusedDate),
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

    return Container(
      height: theme.height,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
      ),
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

  double _rowHeight = 1;

  double get _rowsHeight => _rowHeight * 5;

  bool _shouldScroll = false;

  Widget _monthDays(List<DateTime> days) {
    final theme = widget.monthDayTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mainAxisSpacing = theme.mainAxisSpacing;
        final crossAxisSpacing = theme.crossAxisSpacing;

        var aspectRatio = (constraints.maxWidth - crossAxisSpacing * 6) /
            7 /
            (constraints.maxHeight - mainAxisSpacing * 4) *
            5;
        _shouldScroll = _rowsHeight.round() > constraints.maxHeight.round();
        if (_shouldScroll) {
          aspectRatio = 1.0;
        }

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (!_shouldScroll) {
            _forward.jumpTo(0);
          }
        });

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (_shouldScroll) {
              _onGridViewDragUpdate(details);
            }
          },
          onVerticalDragEnd: (details) {
            if (_shouldScroll) {
              // animate to to the nearest row
              _onGridViewDragEnd();
            }
          },
          child: Container(
            key: MonthViewKeys.timeline[DateTimeRange(
              start: days.first,
              end: days.last.add(
                const Duration(days: 1),
              ),
            )] = GlobalKey(),
            padding: const EdgeInsets.only(
              bottom: 1,
            ),
            color: theme.spacingColor ??
                widget.divider?.color ??
                Colors.transparent,
            child: Stack(
              children: [
                GridView.count(
                  controller: _backward,
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: aspectRatio,
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
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: aspectRatio,
                  children: [
                    ...days.map(
                      (day) => WidgetSize(
                        onChange: (size) {
                          if (size != null && _rowHeight != size.height) {
                            _rowHeight = size.height;
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        },
                        child: _singleDayView(
                          day,
                          constraints.maxWidth * 13 / 7,
                        ),
                      ),
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

  void _syncGridViewPosition() {
    if (!_shouldScroll) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _forward.jumpTo(0);
      });
      return;
    }

    final monthDays = widget.controller.state
        .displayedMonth(
          weekStartsOnSunday: widget.weekStartsOnSunday,
        )
        .days;

    final index = monthDays.indexOf(widget.controller.state.focusedDate);
    if (index == -1) return;

    final row = clampDouble(index / 7, 0, 5).floor();

    final offset = clampDouble(
      row * _rowHeight,
      0,
      _rowsHeight - _rowHeight,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _forward.animateTo(
        offset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn,
      );
    });
  }

  void _onGridViewDragEnd() {
    final position = _forward.offset;
    final row = (position / _rowHeight).round();
    final offset = clampDouble(
      row * _rowHeight,
      0,
      _rowsHeight - _rowHeight,
    );
    _forward.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  void _onGridViewDragUpdate(DragUpdateDetails details) {
    _forward.jumpTo(
      clampDouble(
        _forward.offset - details.delta.dy,
        _forward.position.minScrollExtent - 32,
        _forward.position.maxScrollExtent + 32,
      ),
    );
  }

  Widget _singleDayView(DateTime dayDate, double maxWidth) {
    return BlocBuilder<MonthViewController, MonthViewState>(
      bloc: widget.controller,
      builder: (context, state) {
        final theme = widget.monthDayTheme;
        final isSelected = DateUtils.isSameDay(dayDate, state.focusedDate);
        final eventsToShow = dayEventMap[dayDate] ?? [];

        return RenderIdProvider(
          id: dayDate,
          child: ColoredBox(
            color: Colors.transparent, // Needs for hitTesting
            child: Column(
              children: [
                if (widget.monthDayBuilder != null)
                  Container(
                    height: theme.dayNumberHeight,
                    margin: theme.dayNumberMargin,
                    padding: theme.dayNumberPadding,
                    child: widget.monthDayBuilder!.call(
                      context,
                      eventsToShow,
                      dayDate,
                    ),
                  )
                else ...[
                  Container(
                    padding: theme.dayNumberPadding,
                    margin: theme.dayNumberMargin,
                    height: theme.dayNumberHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? theme.selectedDayNumberBackgroundColor
                          : theme.dayNumberBackgroundColor,
                    ),
                    child: Text(
                      dayDate.day.toString(),
                      style: isSelected
                          ? theme.selectedDayNumberTextStyle
                          : theme.dayNumberTextStyle,
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
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
                                  events: eventsToShow,
                                  eventBuilders: widget.eventBuilders,
                                  elevatedEvent: _elevatedEvent,
                                  onEventTap: widget.onEventTap,
                                  viewType: CalendarView.month,
                                  dayWidth: maxWidth / 13,
                                  showMoreTheme: widget.showMoreTheme,
                                  onShowMoreTap: widget.onShowMoreTap,
                                  eventsListBuilder: widget.eventsListBuilder,
                                  controller: dayControllerMap[dayDate],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _initDailyEventsAndControllers() {
    _initDailyEvents();
    _initDailyControllers();
  }

  void _initDailyEvents() {
    final monthDays = _displayedMonth.days;

    for (var i = 0; i < 5; i++) {
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

    for (var i = 0; i < 5; i++) {
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
