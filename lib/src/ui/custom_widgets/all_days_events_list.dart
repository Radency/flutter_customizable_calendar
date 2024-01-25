import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/widget_size.dart';

class AllDaysEventsListRow {
  const AllDaysEventsListRow({required this.events});

  final List<AllDaysEventListItemRow> events;
}

class AllDaysEventListItemRow {
  const AllDaysEventListItemRow({
    required this.event,
    required this.paddingLeft,
    required this.width,
  });

  final AllDayCalendarEvent event;
  final double paddingLeft;
  final double width;

  AllDaysEventListItemRow copyWith({
    AllDayCalendarEvent? event,
    double? paddingLeft,
    double? width,
  }) {
    return AllDaysEventListItemRow(
      event: event ?? this.event,
      paddingLeft: paddingLeft ?? this.paddingLeft,
      width: width ?? this.width,
    );
  }
}

class AllDaysEventsList extends StatefulWidget {
  const AllDaysEventsList({
    required this.theme,
    required this.allDayEvents,
    required this.width,
    required this.view,
    required this.eventKeys,
    required this.eventBuilders,
    this.onShowMoreTap,
    this.showMoreBuilder,
    this.onEventTap,
    this.weekRange,
    this.visibleDays = 7,
    super.key,
  });

  final int visibleDays;

  final Map<Type, EventBuilder> eventBuilders;
  final Map<CalendarEvent, GlobalKey> eventKeys;

  final DateTimeRange? weekRange;

  final CalendarView view;

  final double width;

  final AllDayEventsTheme theme;

  final List<AllDayCalendarEvent> allDayEvents;

  final void Function(AllDayCalendarEvent event)? onEventTap;

  final void Function(
    List<AllDayCalendarEvent> visibleEvents,
    List<AllDayCalendarEvent> events,
  )? onShowMoreTap;

  final Widget Function(
    List<AllDayCalendarEvent> visibleEvents,
    List<AllDayCalendarEvent> events,
  )? showMoreBuilder;

  @override
  State<AllDaysEventsList> createState() => _AllDaysEventsListState();
}

class _AllDaysEventsListState extends State<AllDaysEventsList> {
  AllDayEventsShowMoreButtonTheme get _showMoreButtonTheme =>
      _theme.showMoreButtonTheme;

  AllDayEventsTheme get _theme => widget.theme;

  int get _rowsNumber => widget.view == CalendarView.week
      ? widget.theme.alwaysShowEmptyRows
          // 1 - for show more button
          ? max(
              _allDaysEventsListItems.length,
              widget.theme.listMaxRowsVisible + 1,
            )
          : _allDaysEventsListItems.length
      : widget.allDayEvents.length;

  int get _maxRows => min(_rowsNumber, _theme.listMaxRowsVisible);

  double get _eventHeight =>
      _theme.eventHeight + (_theme.eventPadding.vertical);

  double get _getContainerHeight =>
      _eventHeight * _maxRows +
      (_maxRows < _rowsNumber
          ? _showMoreButtonHeight + _theme.containerPadding.vertical
          : _theme.containerPadding.vertical);

  double get _getShowMoreButtonThemeHeight =>
      _showMoreButtonTheme.height +
      _showMoreButtonTheme.padding.vertical +
      (_theme.containerPadding.vertical);

  bool get _showShowMoreButton {
    return (widget.theme.alwaysShowEmptyRows
            ? (_rowsNumber - 1)
            : _rowsNumber) >
        _maxRows;
  }

  double _showMoreButtonHeight = 0;

  bool _eventsOverlap(AllDayCalendarEvent event1, AllDayCalendarEvent event2) {
    return !(event1.end.isBefore(event2.start) ||
        event1.end == event2.start ||
        event1.start.isAfter(event2.end) ||
        event1.start == event2.end);
  }

  bool _canPlaceEvent(
    AllDaysEventsListRow row,
    AllDayCalendarEvent event,
    double eventWidth,
    double oneDayWidth,
  ) {
    for (final existingEvent in row.events) {
      if (_eventsOverlap(existingEvent.event, event)) {
        return false;
      }
    }

    var allPreviousEventsWidth = 0.0;

    for (var i = 0; i < row.events.length; i++) {
      final e = row.events[i];
      allPreviousEventsWidth +=
          e.width + (allPreviousEventsWidth - e.paddingLeft);
    }

    return (allPreviousEventsWidth + eventWidth) <= widget.width;
  }

  List<AllDaysEventsListRow> get _allDaysEventsListItems {
    assert(
      widget.view == CalendarView.week || widget.weekRange == null,
      'weekRange can be used only with CalendarView.week',
    );

    final weekRange = widget.weekRange!;

    final oneDayWidth = widget.width / widget.visibleDays;

    final allDaysEventsListRows = <AllDaysEventsListRow>[];

    for (var i = 0; i < widget.allDayEvents.length; i++) {
      final event = widget.allDayEvents[i];

      final start =
          weekRange.start.isAfter(event.start) ? weekRange.start : event.start;

      final paddingLeft =
          (start.difference(weekRange.start).inDays * oneDayWidth).abs();
      final width = min(
        widget.width -
            paddingLeft -
            _theme.eventPadding.horizontal -
            _theme.containerPadding.horizontal,
        (event.end.difference(start).inDays * oneDayWidth).abs(),
      );

      if (allDaysEventsListRows.isEmpty) {
        allDaysEventsListRows.add(
          AllDaysEventsListRow(
            events: [
              AllDaysEventListItemRow(
                event: event,
                paddingLeft: paddingLeft,
                width: width,
              ),
            ],
          ),
        );
        continue;
      }

      for (var rowI = 0; rowI < allDaysEventsListRows.length; rowI++) {
        final row = allDaysEventsListRows[rowI];
        if (_canPlaceEvent(row, event, width, oneDayWidth)) {
          row.events.add(
            AllDaysEventListItemRow(
              event: event,
              paddingLeft: paddingLeft,
              width: width,
            ),
          );
          break;
        }

        if (rowI == allDaysEventsListRows.length - 1) {
          allDaysEventsListRows.add(
            AllDaysEventsListRow(
              events: [
                AllDaysEventListItemRow(
                  event: event,
                  paddingLeft: paddingLeft,
                  width: width,
                ),
              ],
            ),
          );
          break;
        }
      }
    }
    return allDaysEventsListRows;
  }

  @override
  void initState() {
    _showMoreButtonHeight = _getShowMoreButtonThemeHeight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _getContainerHeight,
      width: widget.width,
      decoration: BoxDecoration(
        color: _theme.backgroundColor,
      ),
      child: _buildList(),
    );
  }

  Padding _buildList() {
    return Padding(
      padding: _theme.containerPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.view == CalendarView.week)
            ..._buildWeekListView()
          else
            ..._buildDaysListView(),
          if (_showShowMoreButton)
            WidgetSize(
              onChange: (size) {
                if (size == null) return;

                if (_showMoreButtonHeight != size.height) {
                  _showMoreButtonHeight = size.height;
                  if (mounted) {
                    setState(() {});
                  }
                }
              },
              child: _buildShowMoreButton(widget.allDayEvents),
            ),
        ],
      ),
    );
  }

  Iterable<Widget> _buildDaysListView() {
    return widget.allDayEvents.take(_maxRows).map(
      (e) {
        return SizedBox(
          height: _theme.eventHeight,
          width: widget.width,
          child: EventView(
            e,
            viewType: widget.view,
            key: _getEventKey(e),
            eventBuilders: widget.eventBuilders,
            allDayEventsTheme: _theme,
            onTap: () {
              widget.onEventTap?.call(e);
            },
          ),
        );
      },
    );
  }

  GlobalKey<State<StatefulWidget>> _getEventKey(CalendarEvent event) {
    if (widget.eventKeys.containsKey(event)) {
      widget.eventKeys.remove(event);
    }
    return widget.eventKeys[event] ??= GlobalKey();
  }

  Iterable<Widget> _buildWeekListView() {
    final rows = _allDaysEventsListItems;
    return rows.take(_maxRows).map(
      (e) {
        return Flexible(
          child: SizedBox(
            height: _theme.eventHeight,
            child: Stack(
              alignment: Alignment.topLeft,
              children: e.events
                  .map(
                    (e) => Positioned(
                      left: e.paddingLeft,
                      child: SizedBox(
                        height: _theme.eventHeight,
                        width: e.width,
                        child: EventView(
                          e.event,
                          viewType: widget.view,
                          key: _getEventKey(e.event),
                          allDayEventsTheme: _theme,
                          eventBuilders: widget.eventBuilders,
                          onTap: () {
                            widget.onEventTap?.call(e.event);
                          },
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  List<AllDayCalendarEvent> get _visibleEvents {
    if (widget.view == CalendarView.week) {
      return _allDaysEventsListItems
          .take(_maxRows)
          .map((e) => e.events.map((e) => e.event).toList())
          .toList()
          .reduce((value, element) => [...value, ...element]);
    } else {
      return widget.allDayEvents.take(_maxRows).toList();
    }
  }

  Widget _buildShowMoreButton(List<AllDayCalendarEvent> eventsToDisplay) {
    if (eventsToDisplay.isEmpty) {
      return Container();
    }

    if (widget.showMoreBuilder != null) {
      return widget.showMoreBuilder!.call(_visibleEvents, eventsToDisplay);
    }

    return InkWell(
      onTap: () {
        widget.onShowMoreTap?.call(_visibleEvents, eventsToDisplay);
      },
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: double.maxFinite,
          height: _showMoreButtonTheme.height,
          padding: _showMoreButtonTheme.padding,
          margin: _showMoreButtonTheme.margin,
          child: RenderIdProvider(
            id: 'show_more_button',
            child: Container(
              decoration: BoxDecoration(
                color: _showMoreButtonTheme.backgroundColor,
                borderRadius:
                    BorderRadius.circular(_showMoreButtonTheme.borderRadius),
              ),
              child: Center(
                child: Text(
                  '+${eventsToDisplay.length - _maxRows}',
                  style: _showMoreButtonTheme.textStyle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
