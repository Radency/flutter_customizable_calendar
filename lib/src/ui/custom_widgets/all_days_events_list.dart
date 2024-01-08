import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/widget_size.dart';

class AllDaysEventsList extends StatefulWidget {
  const AllDaysEventsList({
    required this.theme,
    required this.allDayEvents,
    this.onShowMoreTap,
    this.showMoreBuilder,
    this.onEventTap,
    super.key,
  });

  final AllDayEventsTheme theme;

  final List<AllDayCalendarEvent> allDayEvents;

  final void Function(AllDayCalendarEvent event)? onEventTap;

  final void Function(List<AllDayCalendarEvent> visibleEvents,
      List<AllDayCalendarEvent> events)? onShowMoreTap;

  final Widget Function(List<AllDayCalendarEvent> visibleEvents,
      List<AllDayCalendarEvent> events)? showMoreBuilder;

  @override
  State<AllDaysEventsList> createState() => _AllDaysEventsListState();
}

class _AllDaysEventsListState extends State<AllDaysEventsList> {
  AllDayEventsShowMoreButtonTheme get _showMoreButtonTheme =>
      _theme.showMoreButtonTheme;

  AllDayEventsTheme get _theme => widget.theme;

  int get _maxEvents => min(widget.allDayEvents.length, _theme.listMaxVisible);

  double get _eventHeight =>
      _theme.eventHeight + (_theme.eventPadding.vertical);

  double get _getContainerHeight =>
      _eventHeight * _maxEvents +
      (_maxEvents < widget.allDayEvents.length
          ? _showMoreButtonHeight + _theme.containerPadding.vertical
          : 0);

  double get _getShowMoreButtonThemeHeight =>
      _showMoreButtonTheme.height +
      _showMoreButtonTheme.padding.vertical +
      (_theme.containerPadding.vertical);

  double _showMoreButtonHeight = 0;

  @override
  void initState() {
    _showMoreButtonHeight = _getShowMoreButtonThemeHeight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _getContainerHeight,
      child: _buildList(),
    );
  }

  Padding _buildList() {
    return Padding(
      padding: _theme.containerPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.allDayEvents.take(_maxEvents).map(
                (e) => EventView(
                  e,
                  viewType: CalendarView.days,
                  allDayEventsTheme: _theme,
                  onTap: () {
                    widget.onEventTap?.call(e);
                  },
                ),
              ),
          if (widget.allDayEvents.length > _maxEvents)
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
                child: _buildShowMoreButton(widget.allDayEvents)),
        ],
      ),
    );
  }

  Widget _buildShowMoreButton(List<AllDayCalendarEvent> eventsToDisplay) {
    if (eventsToDisplay.isEmpty) {
      return Container();
    }

    if (widget.showMoreBuilder != null) {
      return widget.showMoreBuilder!
          .call(eventsToDisplay.take(_maxEvents).toList(), eventsToDisplay);
    }

    return InkWell(
      onTap: () {
        widget.onShowMoreTap
            ?.call(eventsToDisplay.take(_maxEvents).toList(), eventsToDisplay);
      },
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: double.maxFinite,
          height: _showMoreButtonTheme.height,
          padding: _showMoreButtonTheme.padding,
          margin: _showMoreButtonTheme.margin,
          child: RenderIdProvider(
            id: eventsToDisplay[_maxEvents],
            child: Container(
              decoration: BoxDecoration(
                color: _showMoreButtonTheme.backgroundColor,
                borderRadius:
                    BorderRadius.circular(_showMoreButtonTheme.borderRadius),
              ),
              child: Center(
                child: Text(
                  '+${eventsToDisplay.length - _maxEvents}',
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
