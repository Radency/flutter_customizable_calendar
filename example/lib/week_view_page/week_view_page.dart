import 'package:example/colors.dart';
import 'package:example/common/event_with_label/all_day_event_with_label.dart';
import 'package:example/common/event_with_label/event_label.dart';
import 'package:example/common/event_with_label/event_with_label.dart';
import 'package:example/common/event_with_label/events_with_label_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:intl/intl.dart';

class WeekViewPage extends StatefulWidget {
  const WeekViewPage({super.key});

  @override
  State<WeekViewPage> createState() => _WeekViewPageState();
}

class _WeekViewPageState extends State<WeekViewPage> {
  late final WeekViewController _controller;

  @override
  void initState() {
    _controller = WeekViewController(visibleDays: 3);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsWithLabelCubit>(
      create: (context) => EventsWithLabelCubit()..init(),
      child: Scaffold(
        backgroundColor: ExampleColors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(child:
                  BlocBuilder<EventsWithLabelCubit, EventsWithLabelState>(
                builder: (context, state) {
                  if (state is! EventsWithLabelInitialized) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return WeekView(
                    controller: _controller,
                    saverConfig: null,
                    events: state.events,
                    pageViewPhysics: const ClampingScrollPhysics(),
                    onEventTap: (event) {
                      print(event);
                    },
                    onEventUpdated: (event) {
                      context.read<EventsWithLabelCubit>().updateEvent(event);
                    },
                    // overrideOnEventLongPress: (details, event) {
                    //   print(event);
                    // },
                    allDayEventsTheme: const AllDayEventsTheme(
                        listMaxRowsVisible: 1,
                        eventHeight: 32,
                        backgroundColor: Colors.white,
                        containerPadding: EdgeInsets.zero,
                        eventPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        eventMargin: EdgeInsets.zero,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        borderRadius: 0,
                        elevation: 0,
                        alwaysShowEmptyRows: true,
                        shape: BeveledRectangleBorder(),
                        showMoreButtonTheme: AllDayEventsShowMoreButtonTheme(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 2.0,
                          ),
                          padding: EdgeInsets.zero,
                          height: 24,
                        )),
                    allDayEventsShowMoreBuilder: (context, visible, events) {
                      return Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: ExampleColors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          "show more (${events.length - visible.length})",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                    weekPickerBuilder: _buildWeekPicker,
                    dayRowBuilder: _dayRowBuilder,
                    timelineTheme: TimelineTheme(
                      timeScaleTheme: TimeScaleTheme(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ExampleColors.black,
                        ),
                        width: 32,
                        drawHalfHourMarks: false,
                        drawQuarterHourMarks: false,
                        marksAlign: MarksAlign.right,
                        currentTimeMarkTheme: TimeMarkTheme(
                          color: ExampleColors.swatch24(),
                          length: 32,
                        ),
                        hourFormatter: (hour) {
                          String formatted = DateFormat.H().format(hour);
                          if (hour.hour < 10) {
                            formatted = formatted.substring(1);
                          }
                          return "$formatted";
                        },
                      ),
                    ),
                    eventBuilders: _getEventBuilders(),
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Map<Type, EventBuilder<CalendarEvent>> _getEventBuilders() {
    return {
      EventWithLabel: (context, data) {
        return _buildEventWithLabel(data);
      },
      AllDayEventWithLabel: (context, data) {
        return _buildEventWithLabel(data, allDay: true);
      },
    };
  }

  Row _buildEventWithLabel(
    CalendarEvent data, {
    bool allDay = false,
  }) {
    final event = data as EventWithLabel;

    return Row(
      children: [
        Container(
          width: 4,
          decoration: BoxDecoration(
            color: event.label.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: event.label.color.withOpacity(0.25),
              borderRadius: BorderRadius.circular(allDay ? 2 : 4),
            ),
            padding: EdgeInsets.all(allDay ? 2 : 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dayRowBuilder(context, day, events) {
    return Column(children: [
      Text(
        DateFormat.EEEE().format(day).substring(0, 3),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: ExampleColors.black.withOpacity(0.5),
        ),
      ),
      Text(
        DateFormat.d().format(day),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(
        height: 8,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          width: double.maxFinite,
          height: 6,
          decoration: BoxDecoration(
            color: DateUtils.isSameDay(DateTime.now(), day)
                ? ExampleColors.swatch24()
                : ExampleColors.black.withOpacity(0.05),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
      )
    ]);
  }

  Widget _buildWeekPicker(context, events, range) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                _controller.prev();
              },
              icon: Icon(Icons.chevron_left),
            ),
            GestureDetector(
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: range.start,
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2100),
                ).then((value) {
                  if (value != null) {
                    _controller.setDisplayedDate(value);
                  }
                });
              },
              child: Text(
                DateFormat.yMMMM().format(range.start),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _controller.next();
              },
              icon: Icon(Icons.chevron_right),
            ),
          ],
        )
      ],
    );
  }
}
