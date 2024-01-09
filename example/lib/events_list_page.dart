import 'package:example/image_calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key, required this.events, required this.day});

  final DateTime day;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Events ${_formatDateTime(day)}")),
        body: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    padding: EdgeInsets.all(8),
                    height: event is ImageCalendarEvent ? 200 : 50,
                    decoration: BoxDecoration(
                      image: event is ImageCalendarEvent
                          ? DecorationImage(
                              image: AssetImage(event.imgAsset),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: event.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_getEventText(event)),
                                    if (event is SimpleEvent ||
                                        event is ImageCalendarEvent) ...[
                                      SizedBox(width: 8),
                                      Text(_formatEventDate(event))
                                    ],
                                    if (event is AllDayCalendarEvent) ...[
                                      SizedBox(width: 8),
                                      Text(
                                        'All Day',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ]
                                  ],
                                )),
                          ],
                        ),
                        if (event is SimpleEvent || event is ImageCalendarEvent)
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(_formatEventDuration(event)),
                          )
                      ],
                    )),
              );
            }));
  }

  String _formatEventDuration(CalendarEvent event) {
    final duration = event.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes - hours * 60;

    return '$hours h $minutes${minutes < 10 ? "0" : ""} min';
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day;
    final month = dateTime.month;
    final year = dateTime.year;

    return '$day/$month/$year';
  }

  String _formatEventDate(CalendarEvent event) {
    final start = event.start;
    final end = event.end;

    final startString =
        '${start.hour}:${start.minute}${start.minute < 10 ? '0' : ''}';
    final endString = '${end.hour}:${end.minute}${end.minute < 10 ? '0' : ''}';

    return '$startString - $endString';
  }

  String _getEventText(CalendarEvent event) {
    return event is SimpleEvent
        ? event.title
        : event is TaskDue
            ? 'Task Due'
            : event is Break
                ? 'Break'
                : event is ImageCalendarEvent
                    ? event.title
                    : event is SimpleAllDayEvent
                        ? event.title
                        : 'Unknown Event';
  }
}
