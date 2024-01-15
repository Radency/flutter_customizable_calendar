import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/schedule_list_view_theme.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// A specific controller which controls the ScheduleListView state.
class ScheduleListView<T extends CalendarEvent> extends StatefulWidget {
  /// Creates ScheduleListView controller instance.
  const ScheduleListView({
    required this.controller,
    this.events = const [],
    this.breaks = const [],
    this.eventBuilders = const {},
    this.theme = const ScheduleListViewTheme(),
    this.monthPickerTheme = const DisplayedPeriodPickerTheme(),
    this.floatingEventsTheme = const FloatingEventsTheme(),
    this.onEventTap,
    this.monthPickerBuilder,
    this.dayBuilder,
    this.ignoreDaysWithoutEvents = false,
    super.key,
  });

  /// Theme which allows to customize schedule list view
  /// If you want to customize the default schedule list view, you need to
  /// specify this theme.
  final ScheduleListViewTheme theme;

  /// The theme for the floating events.
  /// If you want to customize the default floating events, you need to
  /// specify this theme.
  final FloatingEventsTheme floatingEventsTheme;

  /// The theme for the month picker.
  /// If you want to customize the default month picker, you need to
  /// specify this theme.
  /// It works only if you don't specify [monthPickerBuilder].
  final DisplayedPeriodPickerTheme monthPickerTheme;

  /// The controller that controls the state of the ScheduleListView.
  /// You can use [ScheduleListViewController] or create your own controller
  /// extending [ScheduleListViewController].
  final ScheduleListViewController controller;

  /// The list of breaks. By default [ScheduleListView] doesn't render breaks.
  /// If you want to render breaks, you need to specify [Break] builder in
  /// [eventBuilders] map.
  final List<Break> breaks;

  /// The list of events which will be rendered in the schedule list view.
  /// If you want to render custom events, you need to specify [T] builder in
  /// [eventBuilders] map.
  final List<T> events;

  /// The callback which is called when an event is tapped.
  final void Function(CalendarEvent event)? onEventTap;

  /// Event builders
  /// Allows to specify custom builders for events
  /// Works only if you don't specify [dayBuilder] builder.
  final Map<Type, EventBuilder> eventBuilders;

  /// Custom day builder
  /// Allows to specify custom builder for day
  /// Make sure you don't have many widgets with 0 height in your builder
  /// If you don't need empty days, you can set
  /// [ignoreDaysWithoutEvents] to true
  final Widget Function(
    List<CalendarEvent> events,
    DateTime date,
  )? dayBuilder;

  /// If true, days without events will be ignored.
  final bool ignoreDaysWithoutEvents;

  /// The builder for the month picker.
  /// If you want to use your own month picker, you need
  /// to specify this builder.
  final Widget Function(
    void Function() nextMonth,
    void Function() prevMonth,
    void Function(DateTime time) toTime,
    DateTime currentTime,
  )? monthPickerBuilder;

  @override
  State<ScheduleListView<T>> createState() => _ScheduleListViewState<T>();
}

class _ScheduleListViewState<T extends CalendarEvent>
    extends State<ScheduleListView<T>> {
  final weekDayFormatter = DateFormat('EE');
  final monthDayFormatter = DateFormat('d');

  late final ItemScrollController _scrollController;
  late final ItemPositionsListener _itemPositionsListener;

  ScheduleListViewTheme get theme => widget.theme;

  @override
  void initState() {
    super.initState();
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(() {
      widget.controller.setDisplayedDateByGroupIndex(
        _itemPositionsListener.itemPositions.value
                .sorted(
                  (a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge),
                )
                .firstOrNull
                ?.index ??
            0,
        _getGrouped(),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollToCurrentPosition(animate: false, events: _getGrouped());
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _getGrouped();

    return BlocListener<ScheduleListViewController,
        ScheduleListViewControllerState>(
      bloc: widget.controller,
      listenWhen: (previous, current) => true,
      listener: (context, state) {
        if (state is ScheduleListViewControllerCurrentDateIsSet &&
            state.animeList) {
          _scrollToCurrentPosition(events: grouped);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...[
            const SizedBox(
              height: 8,
            ),
            BlocBuilder<ScheduleListViewController,
                ScheduleListViewControllerState>(
              bloc: widget.controller,
              buildWhen: (previous, current) =>
                  current is ScheduleListViewControllerCurrentDateIsSet &&
                  previous.displayedDate.month != current.displayedDate.month &&
                  current.animePicker,
              builder: (context, state) {
                if (widget.monthPickerBuilder != null) {
                  return widget.monthPickerBuilder!(
                    widget.controller.next,
                    widget.controller.prev,
                    widget.controller.setDisplayedDate,
                    state.displayedDate,
                  );
                }
                return DisplayedPeriodPicker(
                  period: DisplayedPeriod(state.displayedDate),
                  theme: widget.monthPickerTheme,
                  reverseAnimation: state.reverseAnimation,
                  onLeftButtonPressed: DateUtils.isSameMonth(
                    state.displayedDate,
                    widget.controller.initialDate,
                  )
                      ? null
                      : widget.controller.prev,
                  onRightButtonPressed: DateUtils.isSameMonth(
                    state.displayedDate,
                    widget.controller.endDate,
                  )
                      ? null
                      : widget.controller.next,
                );
              },
            ),
          ],
          Expanded(
            child: Container(
              margin: theme.margin,
              padding: theme.padding,
              child: ScrollablePositionedList.builder(
                itemScrollController: _scrollController,
                itemPositionsListener: _itemPositionsListener,
                itemCount: grouped.length + 1,
                itemBuilder: (context, i) {
                  return _itemBuilder(i, grouped);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<CalendarEvent>> _getGrouped() {
    final grouped = {
      ...widget.controller.grouped,
      ...groupBy(
        [...widget.breaks, ...widget.events].sortedBy((e) => e.start),
        (e) => DateTime(e.start.year, e.start.month, e.start.day),
      ),
    };
    if (widget.ignoreDaysWithoutEvents) {
      grouped.removeWhere((key, value) => value.isEmpty);
    }
    return grouped;
  }

  Widget _itemBuilder(int i, Map<DateTime, List<CalendarEvent>> grouped) {
    if (i < 0) {
      return const SizedBox();
    }

    if (i == 0) {
      return SizedBox(height: theme.firstElementMarginTop);
    }

    final index = i - 1;

    final group = grouped.entries.elementAt(index);

    final date = group.key;
    final events = group.value;

    if (widget.dayBuilder != null) {
      return widget.dayBuilder!(events, date);
    }

    return Container(
      width: double.infinity,
      padding: theme.dayPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupDateWidget(date),
          _buildGroup(events),
        ],
      ),
    );
  }

  Expanded _buildGroup(List<CalendarEvent> events) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(events.length, (index) {
          final event = events[index];
          if (event is Break) {
            return _buildBreak(event);
          } else if (event is FloatingCalendarEvent) {
            return _buildEvent(event);
          }

          return const SizedBox();
        }),
      ),
    );
  }

  SizedBox _buildEvent(FloatingCalendarEvent event) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: theme.eventPadding,
        child: EventView(
          eventBuilders: widget.eventBuilders,
          theme: widget.floatingEventsTheme,
          event,
          viewType: CalendarView.scheduleList,
          onTap: () {
            widget.onEventTap?.call(event);
          },
        ),
      ),
    );
  }

  void _scrollToCurrentPosition({
    required Map<DateTime, List<CalendarEvent>> events,
    bool animate = true,
  }) {
    if (animate) {
      _scrollController.scrollTo(
        index: widget.controller.animateToGroupIndex(
              ignoreEmpty: widget.ignoreDaysWithoutEvents,
              events: events,
            ) +
            1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        alignment: .01,
      );
    } else {
      _scrollController.jumpTo(
        index: widget.controller.animateToGroupIndex(
          ignoreEmpty: widget.ignoreDaysWithoutEvents,
          events: events,
        ),
        alignment: 0,
      );
    }
  }

  Widget _buildBreak(Break brk) {
    final builder = widget.eventBuilders[brk.runtimeType];
    if (builder != null) {
      return builder(context, brk);
    }
    return const SizedBox();
  }

  Widget _buildGroupDateWidget(DateTime date) {
    return Container(
      width: 64,
      decoration: BoxDecoration(
        color: theme.dateBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: theme.dateMargin,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekDayFormatter.format(date),
              style: theme.weekDayTextStyle,
            ),
            Text(
              monthDayFormatter.format(date),
              style: theme.monthDayTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
