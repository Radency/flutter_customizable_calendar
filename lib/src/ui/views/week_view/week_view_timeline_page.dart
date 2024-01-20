import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/all_days_events_list.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/widget_size.dart';
import 'package:flutter_customizable_calendar/src/ui/views/week_view/week_view_timeline_widget.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

class WeekViewTimelinePage<T extends FloatingCalendarEvent>
    extends StatefulWidget {
  const WeekViewTimelinePage({
    required this.weekPickerController,
    required this.pageViewPhysics,
    required this.theme,
    required this.daysRowTheme,
    required this.controller,
    required this.overlayKey,
    required this.breaks,
    required this.events,
    required this.allDayEvents,
    required this.elevatedEvent,
    required this.constraints,
    required this.timelineKey,
    required this.layoutKeys,
    required this.eventKeys,
    required this.allDayEventsTheme,
    this.eventBuilders = const {},
    this.dayRowBuilder,
    this.onEventTap,
    this.divider,
    this.allDayEventsShowMoreBuilder,
    this.onAllDayEventTap,
    this.onAllDayEventsShowMoreTap,
    super.key,
  });

  final ScrollPhysics? pageViewPhysics;

  final PageController weekPickerController;

  final void Function(
    List<AllDayCalendarEvent> visibleEvents,
    List<AllDayCalendarEvent> events,
  )? onAllDayEventsShowMoreTap;

  final void Function(AllDayCalendarEvent event)? onAllDayEventTap;

  final Widget Function(
    List<AllDayCalendarEvent> visibleEvents,
    List<AllDayCalendarEvent> events,
  )? allDayEventsShowMoreBuilder;
  final AllDayEventsTheme allDayEventsTheme;
  final List<AllDayCalendarEvent> allDayEvents;
  final Map<DateTime, GlobalKey> layoutKeys;
  final Map<CalendarEvent, GlobalKey> eventKeys;

  final GlobalKey Function(List<DateTime> days) timelineKey;
  final BoxConstraints constraints;
  final FloatingEventNotifier<T> elevatedEvent;
  final List<Break> breaks;
  final List<T> events;

  final Map<Type, EventBuilder> eventBuilders;
  final GlobalKey<DraggableEventOverlayState<T>> overlayKey;
  final WeekViewController controller;
  final TimelineTheme theme;
  final DaysRowTheme daysRowTheme;
  final Widget Function(
    BuildContext context,
    DateTime day,
    List<T> events,
  )? dayRowBuilder;
  final Widget? divider;
  final void Function(T)? onEventTap;

  @override
  State<WeekViewTimelinePage<T>> createState() => _WeekViewTimelinePageState();
}

class _WeekViewTimelinePageState<T extends FloatingCalendarEvent>
    extends State<WeekViewTimelinePage<T>> {
  late ScrollController _timelineController;

  DateTime get _focusedDate => widget.controller.state.focusedDate;

  double get _hourExtent => widget.theme.timeScaleTheme.hourExtent;

  static DateTime get _now => clock.now();

  double _daysRowsHeight = 0;
  double _allDayEventsHeight = 0;
  double _timelineHeight = 0;

  late final double _initScroll =
      widget.controller.timelineOffset ?? _focusedDate.hour * _hourExtent;

  @override
  void initState() {
    _timelineController = ScrollController(
      initialScrollOffset: _initScroll,
    );
    super.initState();
  }

  @override
  void dispose() {
    _timelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeScaleWidth = widget.theme.timeScaleTheme.width;
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.only(
            top: _daysRowsHeight + _allDayEventsHeight,
          ),
          child: BlocBuilder<WeekViewController, WeekViewState>(
            bloc: widget.controller,
            builder: (context, state) {
              final weekDays = state.focusedDate
                  .weekRange(widget.controller.visibleDays)
                  .days;

              return SingleChildScrollView(
                controller: _timelineController,
                physics: const NeverScrollableScrollPhysics(),
                child: WidgetSize(
                  onChange: (size) {
                    if (size == null) return;
                    setState(() {
                      _timelineHeight = size.height;
                    });
                  },
                  child: IntrinsicHeight(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: widget.theme.padding.top,
                        bottom: widget.theme.padding.bottom,
                      ),
                      color: Colors.transparent, // Needs for hitTesting
                      child: TimeScale(
                        showCurrentTimeMark: weekDays.first.isSameWeekAs(
                          widget.controller.visibleDays,
                          _now,
                        ),
                        theme: widget.theme.timeScaleTheme,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: widget.weekPickerController,
            physics: widget.pageViewPhysics,
            onPageChanged: (index) {
              widget.controller.setPage(index);
            },
            itemBuilder: (context, pageIndex) {
              final weekDays = _getWeekDays(pageIndex);

              return _buildBody(weekDays);
            },
          ),
        ),
      ],
    );
  }

  Padding _buildBody(
    List<DateTime> weekDays,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.theme.padding.left,
        right: widget.theme.padding.right,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetSize(
            onChange: (size) {
              if (size == null) return;
              setState(() {
                _allDayEventsHeight = size.height;
              });
            },
            child: _daysRow(
              weekDays,
            ),
          ),
          WidgetSize(
            onChange: (size) {
              if (size == null) return;
              setState(() {
                _daysRowsHeight = size.height;
              });
            },
            child: AllDaysEventsList(
              eventKeys: widget.eventKeys,
              width: widget.constraints.maxWidth,
              theme: widget.allDayEventsTheme,
              weekRange: DateTimeRange(
                start: weekDays.first,
                end: weekDays.last,
              ),
              allDayEvents: widget.allDayEvents
                  .where(
                    (element) =>
                        DateTimeRange(start: element.start, end: element.end)
                            .days
                            .any(
                              (d1) => weekDays.any(
                                (d2) => DateUtils.isSameDay(d1, d2),
                              ),
                            ),
                  )
                  .toList(),
              onEventTap: widget.onAllDayEventTap,
              onShowMoreTap: widget.onAllDayEventsShowMoreTap,
              showMoreBuilder: widget.allDayEventsShowMoreBuilder,
              view: CalendarView.week,
            ),
          ),
          widget.divider ?? const SizedBox.shrink(),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: _stripesRow(weekDays),
                ),
                WeekViewTimelineWidget(
                  days: weekDays,
                  scrollTo: (offset) {
                    _timelineController.jumpTo(offset);
                  },
                  initialScrollOffset: _timelineController.offset,
                  height: _timelineHeight,
                  controller: widget.controller,
                  timelineKey: widget.timelineKey(weekDays),
                  theme: widget.theme,
                  buildChild: _singleDayView,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _getWeekDays(int pageIndex) {
    final weekDays = DateUtils.addDaysToDate(
      widget.controller.initialDate,
      pageIndex * widget.controller.visibleDays,
    ).weekRange(widget.controller.visibleDays).days;
    return weekDays;
  }

  Widget _daysRow(List<DateTime> days) {
    if (widget.dayRowBuilder != null) {
      return Row(
        children: days
            .map(
              (dayDate) => Expanded(
                child: widget.dayRowBuilder!(
                  context,
                  dayDate,
                  widget.events
                      .where(
                        (element) =>
                            element.start.isAfter(dayDate) &&
                            element.start.isBefore(dayDate),
                      )
                      .toList(),
                ),
              ),
            )
            .toList(),
      );
    }

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

  Widget _singleDayView(DateTime dayDate) {
    return Expanded(
      child: RenderIdProvider(
        id: dayDate,
        child: Container(
          padding: EdgeInsets.only(
            top: widget.theme.padding.top,
            bottom: widget.theme.padding.bottom,
          ),
          color: Colors.transparent, // Needs for hitTesting
          child: EventsLayout<T>(
            // key: ValueKey(dayDate),
            dayDate: dayDate,
            eventBuilders: widget.eventBuilders,
            viewType: CalendarView.week,
            overlayKey: widget.overlayKey,
            layoutsKeys: widget.layoutKeys,
            eventsKeys: widget.eventKeys,
            timelineTheme: widget.theme,
            breaks: widget.breaks,
            events: widget.events,
            elevatedEvent: widget.elevatedEvent,
            onEventTap: widget.onEventTap,
          ),
        ),
      ),
    );
  }
}
