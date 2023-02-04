import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/custom_widgets.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/themes.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

/// A day view which automatically creates views of given [breaks] and [events]
/// and sets their positions on it.
class EventsLayout<T extends FloatingCalendarEvent> extends StatelessWidget {
  /// Creates a layout for all [breaks] and [events] of given [dayDate].
  const EventsLayout({
    super.key,
    required this.dayDate,
    required this.layoutsKeys,
    required this.eventsKeys,
    required this.timelineTheme,
    this.breaks = const [],
    this.events = const [],
    required this.elevatedEvent,
    this.onEventTap,
  });

  /// A day which needs to be displayed
  final DateTime dayDate;

  /// A keys collection for all layouts views
  final Map<DateTime, GlobalKey> layoutsKeys;

  /// A keys collection for all events views
  final Map<CalendarEvent, GlobalKey> eventsKeys;

  /// The timeline customization params
  final TimelineTheme timelineTheme;

  /// All breaks list
  final List<Break> breaks;

  /// All events list
  final List<T> events;

  /// A notifier which needs to set an event as elevated
  final FloatingEventNotifier<T> elevatedEvent;

  /// Callback which returns a tapped event value
  final void Function(T)? onEventTap;

  List<E> _getEventsOnDay<E extends CalendarEvent>(List<E> list) => list
      .where((event) => DateUtils.isSameDay(event.start, dayDate))
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final breaksToDisplay = _getEventsOnDay(breaks);
    final eventsToDisplay = _getEventsOnDay(events);

    return ValueListenableBuilder(
      valueListenable: elevatedEvent,
      builder: (context, elevatedEvent, child) => IgnorePointer(
        ignoring: elevatedEvent != null,
        child: child,
      ),
      child: CustomMultiChildLayout(
        key: layoutsKeys[dayDate] ??= GlobalKey(),
        delegate: _EventsLayoutDelegate<T>(
          date: dayDate,
          breaks: breaksToDisplay,
          events: eventsToDisplay,
          cellExtent: timelineTheme.cellExtent,
        ),
        children: [
          ...breaksToDisplay.map(
            (event) => LayoutId(
              id: event,
              child: BreakView(event),
            ),
          ),
          ...eventsToDisplay.map(
            (event) => LayoutId(
              id: event,
              child: _eventView(event),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventView(T event) => ValueListenableBuilder(
        valueListenable: elevatedEvent,
        builder: (context, elevatedEvent, child) => Opacity(
          opacity: (elevatedEvent == event) ? 0.5 : 1,
          child: child,
        ),
        child: EventView<T>(
          key: eventsKeys[event] ??= GlobalKey(),
          event,
          theme: timelineTheme.floatingEventsTheme,
          onTap: () => onEventTap?.call(event),
          onLongPress: () => elevatedEvent.value = event,
        ),
      );
}

class _EventsLayoutDelegate<T extends FloatingCalendarEvent>
    extends MultiChildLayoutDelegate {
  _EventsLayoutDelegate({
    required this.date,
    required this.breaks,
    required this.events,
    required this.cellExtent,
  }) {
    events.sort(); // Sorting the events before layout
  }

  final DateTime date;
  final List<Break> breaks;
  final List<T> events;
  final int cellExtent;

  @override
  void performLayout(Size size) {
    final minuteExtent = size.height / Duration.minutesPerDay;

    // Laying out all breaks first
    for (final event in breaks) {
      if (hasChild(event)) {
        layoutChild(
          event,
          BoxConstraints.tightFor(
            width: size.width,
            height: event.duration.inMinutes * minuteExtent,
          ),
        );
        positionChild(
          event,
          Offset(0, event.start.difference(date).inMinutes * minuteExtent),
        );
      }
    }

    final layoutsMap = <T, Rect>{};
    var startIndex = 0;

    while (startIndex < events.length) {
      var clusterEndDate = events[startIndex].end;
      var finalIndex = startIndex + 1;
      final rows = <List<T>>[
        [events[startIndex]],
      ];

      // Clustering the events
      while (finalIndex < events.length &&
          events[finalIndex].start.isBefore(clusterEndDate)) {
        final currentEvent = events[finalIndex];

        if (currentEvent.end.isAfter(clusterEndDate)) {
          clusterEndDate = currentEvent.end;
        }

        if (currentEvent.start.isAfter(events[finalIndex - 1].start)) {
          rows.add([]);
        }

        // Grouping the events in rows
        rows.last.add(currentEvent);
        finalIndex++;
      }

      const dxStep = 10.0;

      // Calculating widths and dx offsets of every event layout
      for (var index = 0; index < rows.length; index++) {
        final currentRow = rows[index];
        var dxOffset = 0.0;

        if (index > 0) {
          final currentDate = currentRow.first.start;
          var prev = index - 1;

          // If an event layout intersects with the previous one
          if (currentDate.difference(rows[prev].last.start) <
              rows[prev].last.duration) {
            dxOffset = layoutsMap[rows[prev].last]!.left + dxStep;
          } else {
            // Finding the last intersected event
            while (currentDate.difference(rows[prev].first.start) >=
                rows[prev].first.duration) {
              prev--;
            }

            dxOffset = layoutsMap[rows[prev].first]!.left + dxStep;
          }
        }

        final columnWidth = (size.width - dxOffset) / currentRow.length;

        for (final event in currentRow) {
          layoutsMap[event] = Rect.fromLTWH(
            dxOffset,
            event.start.difference(date).inMinutes * minuteExtent,
            columnWidth,
            max(event.duration.inMinutes, cellExtent) * minuteExtent,
          );
          dxOffset += columnWidth;
        }
      }

      startIndex = finalIndex;
    }

    // Time to layout the events
    for (final entry in layoutsMap.entries) {
      final event = entry.key;

      if (hasChild(event)) {
        final eventBox = entry.value;

        layoutChild(
          event,
          (event.duration == Duration.zero)
              ? BoxConstraints.loose(eventBox.size)
              : BoxConstraints.tight(eventBox.size),
        );
        positionChild(event, eventBox.topLeft);
      }
    }
  }

  @override
  bool shouldRelayout(covariant _EventsLayoutDelegate<T> oldDelegate) {
    if (events.length != oldDelegate.events.length) return true;

    for (var index = 0; index < events.length; index++) {
      if (events[index].compareTo(oldDelegate.events[index]) != 0) {
        return true;
      }
    }

    return false;
  }
}
