import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/controllers/controllers.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/custom_widgets.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/themes.dart';
import 'package:flutter_customizable_calendar/src/ui/views/week_view/week_view_timeline_page.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

/// A key holder of all WeekView keys
@visibleForTesting
abstract class WeekViewKeys {
  /// A key for the timeline view
  static Map<DateTimeRange, GlobalKey?> timeline = {};

  /// Map of keys for the events layouts (by day date)
  static final layouts = <DateTime, GlobalKey>{};

  /// Map of keys for the displayed events (by event object)
  static final events = <CalendarEvent, GlobalKey>{};
}

/// Week view displays a timeline for a specific week.
class WeekView<T extends FloatingCalendarEvent> extends StatefulWidget {
  /// Creates a Week view, [controller] is required.
  const WeekView({
    required this.controller,
    this.saverConfig,
    super.key,
    this.weekPickerTheme = const DisplayedPeriodPickerTheme(),
    this.weekPickerBuilder,
    this.divider,
    this.daysRowTheme = const DaysRowTheme(),
    this.dayRowBuilder,
    this.timelineTheme = const TimelineTheme(),
    this.floatingEventTheme = const FloatingEventsTheme(),
    this.breaks = const [],
    this.events = const [],
    this.onDateLongPress,
    this.onEventTap,
    this.onEventUpdated,
    this.onDiscardChanges,
    this.pageViewPhysics,
    this.eventBuilders = const {},
    this.overrideOnEventLongPress,
    this.allDayEventsTheme = const AllDayEventsTheme(),
    this.onAllDayEventsShowMoreTap,
    this.onAllDayEventTap,
    this.allDayEventsShowMoreBuilder,
  });

  /// Enable page view physics
  final ScrollPhysics? pageViewPhysics;

  /// Controller which allows to control the view
  final WeekViewController controller;

  /// Event builders
  final Map<Type, EventBuilder> eventBuilders;

  /// Overrides the default behavior of the event view's long press
  final void Function(LongPressStartDetails details, T event)?
      overrideOnEventLongPress;

  /// The month picker customization params
  /// Works only if [weekPickerBuilder] is null
  final DisplayedPeriodPickerTheme weekPickerTheme;

  /// The month picker builder
  final Widget Function(
    BuildContext context,
    List<T> events,
    DateTimeRange range,
  )? weekPickerBuilder;

  /// A divider which separates the days list and the timeline.
  /// You can set it to null if you don't need it.
  final Divider? divider;

  /// The days row customization params
  /// Works only if [dayRowBuilder] is null
  final DaysRowTheme daysRowTheme;

  /// Day row builder
  final Widget Function(
    BuildContext context,
    DateTime day,
    List<T> events,
  )? dayRowBuilder;

  /// The timeline customization params
  final TimelineTheme timelineTheme;

  /// Floating events customization params
  final FloatingEventsTheme floatingEventTheme;

  /// All day events theme
  final AllDayEventsTheme allDayEventsTheme;

  /// On all day events show more tap callback
  final void Function(
    List<AllDayCalendarEvent> visibleEvents,
    List<AllDayCalendarEvent> events,
  )? onAllDayEventsShowMoreTap;

  /// On all day event tap callback
  final void Function(AllDayCalendarEvent event)? onAllDayEventTap;

  /// Builder for all day events show more button
  final Widget Function(
    List<AllDayCalendarEvent> visibleEvents,
    List<AllDayCalendarEvent> events,
  )? allDayEventsShowMoreBuilder;

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
  final SaverConfig? saverConfig;

  @override
  State<WeekView<T>> createState() => _WeekViewState<T>();
}

class _WeekViewState<T extends FloatingCalendarEvent> extends State<WeekView<T>>
    with SingleTickerProviderStateMixin {
  final _overlayKey = GlobalKey<DraggableEventOverlayState<T>>();
  final _elevatedEvent = FloatingEventNotifier<T>();
  PageController? _weekPickerController;
  var _pointerLocation = Offset.zero;
  var _scrolling = false;
  ScrollController? _timelineController;

  final StreamController<int> _eventUpdatesStreamController =
      StreamController.broadcast();

  DateTime get _initialDate => widget.controller.initialDate;

  DateTime? get _endDate => widget.controller.endDate;

  double get _hourExtent => widget.timelineTheme.timeScaleTheme.hourExtent;

  DateTimeRange get _displayedWeek =>
      widget.controller.state.displayedWeek(widget.controller.visibleDays);

  DateTimeRange get _initialWeek =>
      _initialDate.weekRange(widget.controller.visibleDays);

  RenderBox? _getTimelineBox(dynamic key) =>
      WeekViewKeys.timeline[key]?.currentContext?.findRenderObject()
          as RenderBox?;

  RenderBox? _getLayoutBox(DateTime dayDate) =>
      WeekViewKeys.layouts[dayDate]?.currentContext?.findRenderObject()
          as RenderBox?;

  RenderBox? _getEventBox(T event) =>
      WeekViewKeys.events[event]?.currentContext?.findRenderObject()
          as RenderBox?;

  List<AllDayCalendarEvent> get _allDayEvents =>
      widget.events.whereType<AllDayCalendarEvent>().toList();

  List<T> get _events {
    return widget.events
        .where((element) => element is! AllDayCalendarEvent)
        .toList()
        .cast<T>();
  }

  void _stopTimelineScrolling() =>
      _timelineController?.jumpTo(_timelineController?.offset ?? 0);

  Future<void> _scrollIfNecessary() async {
    final timelineBox = _getTimelineBox(
      widget.controller.state.focusedDate
          .weekRange(widget.controller.visibleDays),
    );

    _scrolling = timelineBox != null;

    if (!_scrolling) return; // Scrollable isn't found
    if (_timelineController == null) return;

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
      final weekPickerPosition = _weekPickerController?.position;

      if (weekPickerPosition == null) {
        _scrolling = false;
        return;
      }

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
      initialPage: _displayedWeek.start.difference(_initialWeek.start).inWeeks(
            widget.controller.visibleDays,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WeekViewController, WeekViewState>(
      bloc: widget.controller,
      listener: (context, state) {
        final weeksOffset = state
            .displayedWeek(widget.controller.visibleDays)
            .start
            .difference(_initialWeek.start)
            .inWeeks(widget.controller.visibleDays);

        if (state is WeekViewCurrentWeekIsSet) {
          Future.wait([
            if (weeksOffset != _weekPickerController?.page?.round())
              _weekPickerController!.animateToPage(
                weeksOffset,
                duration: const Duration(milliseconds: 400),
                curve: Curves.linearToEaseOut,
              ),
          ]).whenComplete(() {
            // Scroll the timeline just after current week is displayed
            final timelineOffset = min(
              state.focusedDate.hour * _hourExtent,
              _timelineController?.position.maxScrollExtent ?? 0,
            );

            if (timelineOffset != _timelineController?.offset) {
              _timelineController
                  ?.animateTo(
                timelineOffset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastLinearToSlowEaseIn,
              )
                  .then((value) {
                _requestDraggableEventOverlayUpdate();
              });
            } else {
              _requestDraggableEventOverlayUpdate();
            }
            setState(() {});
          });
        } else if (state is WeekViewNextWeekSelected ||
            state is WeekViewPrevWeekSelected) {
          Future.wait([
            _weekPickerController!.animateToPage(
              weeksOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linearToEaseOut,
            ),
          ]).whenComplete(() {
            _requestDraggableEventOverlayUpdate();
            setState(() {});
          });
        }
      },
      child: Column(
        children: [
          _weekPicker(),
          Expanded(
            child: DraggableEventOverlay<T>(
              _elevatedEvent,
              key: _overlayKey,
              onEventLongPressStart: widget.overrideOnEventLongPress,
              viewType: CalendarView.week,
              timelineTheme: widget.timelineTheme,
              padding: EdgeInsets.only(
                top: widget.daysRowTheme.height + (widget.divider?.height ?? 0),
              ),
              eventBuilders: widget.eventBuilders,
              onDateLongPress: _onDateLongPress,
              onDragDown: _stopTimelineScrolling,
              onDragUpdate: _autoScrolling,
              onDragEnd: _stopAutoScrolling,
              onSizeUpdate: _autoScrolling,
              onResizingEnd: _stopAutoScrolling,
              onDropped: widget.onDiscardChanges,
              onChanged: widget.onEventUpdated,
              getTimelineBox: () => _getTimelineBox(
                widget.controller.state.focusedDate
                    .weekRange(widget.controller.visibleDays),
              ),
              getLayoutBox: _getLayoutBox,
              getEventBox: _getEventBox,
              saverConfig: widget.saverConfig ?? SaverConfig.def(),
              eventUpdatesStreamController: _eventUpdatesStreamController,
              child: _weekTimeline(),
            ),
          ),
        ],
      ),
    );
  }

  void _requestDraggableEventOverlayUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _eventUpdatesStreamController.add(0);
    });
  }

  @override
  void dispose() {
    _elevatedEvent.dispose();
    _weekPickerController?.dispose();
    _timelineController?.dispose();
    _eventUpdatesStreamController.close();
    super.dispose();
  }

  Widget _weekPicker() => BlocBuilder<WeekViewController, WeekViewState>(
        bloc: widget.controller,
        builder: (context, state) {
          final days = state.displayedWeek(widget.controller.visibleDays).days;

          if (widget.weekPickerBuilder != null) {
            final range = DateTimeRange(
              start: days.first,
              end: days.last,
            );
            return widget.weekPickerBuilder!(
              context,
              widget.events
                  .where(
                    (element) =>
                        element.start.isAfter(range.start) &&
                        element.start.isBefore(range.end),
                  )
                  .toList()
                  .cast<T>(),
              state.displayedWeek(widget.controller.visibleDays),
            );
          }

          return DisplayedPeriodPicker(
            period: DisplayedPeriod(days.first, days.last),
            theme: widget.weekPickerTheme,
            reverseAnimation: state.reverseAnimation,
            onLeftButtonPressed: state.focusedDate
                    .isSameWeekAs(widget.controller.visibleDays, _initialDate)
                ? null
                : widget.controller.prev,
            onRightButtonPressed: state.focusedDate
                    .isSameWeekAs(widget.controller.visibleDays, _endDate)
                ? null
                : widget.controller.next,
          );
        },
        buildWhen: (previous, current) => !current.focusedDate
            .isSameWeekAs(widget.controller.visibleDays, previous.focusedDate),
      );

  Widget _weekTimeline() {
    final theme = widget.timelineTheme;

    _weekPickerController?.dispose();
    _weekPickerController = PageController(
      initialPage: _displayedWeek.start
          .difference(_initialWeek.start)
          .inWeeks(widget.controller.visibleDays),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return WeekViewTimelinePage(
          weekPickerController: _weekPickerController!,
          pageViewPhysics:
              widget.pageViewPhysics ?? const NeverScrollableScrollPhysics(),
          timelineKey: (days) {
            final timeRange = DateTimeRange(
              start: days.first,
              end: days.last,
            );
            if (!WeekViewKeys.timeline.containsKey(
              timeRange,
            )) {
              WeekViewKeys.timeline[timeRange] = GlobalKey();
            }
            return WeekViewKeys.timeline[timeRange]!;
          },
          layoutKeys: WeekViewKeys.layouts,
          eventKeys: WeekViewKeys.events,
          eventBuilders: widget.eventBuilders,
          constraints: constraints,
          theme: theme,
          daysRowTheme: widget.daysRowTheme,
          dayRowBuilder: widget.dayRowBuilder,
          controller: widget.controller,
          overlayKey: _overlayKey,
          breaks: widget.breaks,
          events: _events,
          allDayEvents: _allDayEvents,
          allDayEventsTheme: widget.allDayEventsTheme,
          allDayEventsShowMoreBuilder: widget.allDayEventsShowMoreBuilder,
          onAllDayEventsShowMoreTap: widget.onAllDayEventsShowMoreTap,
          onAllDayEventTap: widget.onAllDayEventTap,
          elevatedEvent: _elevatedEvent,
          divider: widget.divider,
          onEventTap: widget.onEventTap,
        );
      },
    );
  }

  void _onDateLongPress(DateTime timestamp) {
    if (timestamp.isBefore(_initialDate)) return;
    if ((_endDate != null) && timestamp.isAfter(_endDate!)) return;

    widget.onDateLongPress?.call(timestamp);
  }
}
