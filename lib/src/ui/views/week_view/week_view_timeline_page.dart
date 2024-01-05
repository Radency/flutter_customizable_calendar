import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

class WeekViewTimelinePage<T extends FloatingCalendarEvent>
    extends StatefulWidget {
  const WeekViewTimelinePage({
    required this.weekDays,
    required this.theme,
    required this.daysRowTheme,
    required this.controller,
    required this.overlayKey,
    required this.breaks,
    required this.events,
    required this.elevatedEvent,
    required this.constraints,
    required this.timelineKey,
    required this.layoutKeys,
    required this.eventKeys,
    this.eventBuilders = const {},
    this.onEventTap,
    this.divider,
    super.key,
  });

  final Map<DateTime, GlobalKey> layoutKeys;
  final Map<CalendarEvent, GlobalKey> eventKeys;

  final GlobalKey timelineKey;
  final BoxConstraints constraints;
  final FloatingEventNotifier<T> elevatedEvent;
  final List<Break> breaks;
  final List<T> events;

  final Map<Type, EventBuilder> eventBuilders;
  final GlobalKey<DraggableEventOverlayState<T>> overlayKey;
  final WeekViewController controller;
  final List<DateTime> weekDays;
  final TimelineTheme theme;
  final DaysRowTheme daysRowTheme;
  final Widget? divider;
  final void Function(T)? onEventTap;

  @override
  State<WeekViewTimelinePage<T>> createState() => _WeekViewTimelinePageState();
}

class _WeekViewTimelinePageState<T extends FloatingCalendarEvent>
    extends State<WeekViewTimelinePage<T>> {
  late final ScrollController _timelineController;

  DateTime get _focusedDate => widget.controller.state.focusedDate;

  double get _hourExtent => widget.theme.timeScaleTheme.hourExtent;

  static DateTime get _now => clock.now();

  @override
  void initState() {
    widget.controller.timelineOffset =
        widget.controller.timelineOffset ?? _focusedDate.hour * _hourExtent;
    _timelineController = ScrollController(
      initialScrollOffset:
          widget.controller.timelineOffset ?? _focusedDate.hour * _hourExtent,
    );
    _timelineController.addListener(() {
      widget.controller.timelineOffset = _timelineController.offset;
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant WeekViewTimelinePage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeScaleWidth = widget.theme.timeScaleTheme.width;
    return Padding(
      padding: EdgeInsets.only(
        left: widget.theme.padding.left,
        right: widget.theme.padding.right,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: timeScaleWidth),
            child: _daysRow(widget.weekDays),
          ),
          widget.divider ?? const SizedBox.shrink(),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  left: timeScaleWidth,
                  child: _stripesRow(widget.weekDays),
                ),
                _timeline(widget.weekDays),
              ],
            ),
          ),
        ],
      ),
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

  Widget _timeline(List<DateTime> days) {
    final theme = widget.theme;
    final isCurrentWeek = days.first.isSameWeekAs(_now);

    return SingleChildScrollView(
      key: widget.timelineKey,
      controller: _timelineController,
      child: IntrinsicHeight(
        child: Row(
          children: [
            RenderIdProvider(
              id: days.first, // TimeScale marked as a part of the first day
              child: Container(
                padding: EdgeInsets.only(
                  top: theme.padding.top,
                  bottom: theme.padding.bottom,
                ),
                color: Colors.transparent, // Needs for hitTesting
                child: TimeScale(
                  showCurrentTimeMark: isCurrentWeek,
                  theme: theme.timeScaleTheme,
                ),
              ),
            ),
            ...days.map(_singleDayView),
          ],
        ),
      ),
    );
  }

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
