import 'package:example/colors.dart';
import 'package:example/common/event_with_label/event_label.dart';
import 'package:example/common/event_with_label/event_with_label.dart';
import 'package:example/common/event_with_label/events_with_label_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:intl/intl.dart';

class DaysViewPage extends StatefulWidget {
  const DaysViewPage({
    super.key,
    required this.eventsCubit,
    required this.focusedDay,
    required this.onAddClicked,
  });

  final void Function(
    BuildContext context,
    DateTime focusDate,
  ) onAddClicked;
  final EventsWithLabelCubit eventsCubit;
  final DateTime focusedDay;

  @override
  State<DaysViewPage> createState() => _DaysViewPageState();
}

class _DaysViewPageState extends State<DaysViewPage> {
  late final DaysViewController _controller;

  @override
  void initState() {
    _controller = DaysViewController(
      focusedDate: widget.focusedDay,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExampleColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<EventsWithLabelCubit, EventsWithLabelState>(
                bloc: widget.eventsCubit,
                builder: (context, state) {
                  if (state is! EventsWithLabelInitialized) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return DaysView(
                    controller: _controller,
                    saverConfig: null,
                    events: state.events,
                    onEventUpdated: (event) {
                      widget.eventsCubit.updateEvent(event);
                    },
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
                          return "$formatted ";
                        },
                      ),
                    ),
                    monthPickerBuilder: (
                      BuildContext context,
                      DateTime focusedDate,
                      List<CalendarEvent> events,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                        ),
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_left,
                                        color: ExampleColors.swatch24(),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Back",
                                        style: TextStyle(
                                          color: ExampleColors.swatch24(),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    daysListBuilder: (
                      context,
                      focusedDate,
                      events,
                    ) {
                      return Column(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(
                                width: 24,
                              ),
                              Text(
                                DateFormat.d().format(focusedDate),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                DateFormat.EEEE()
                                    .format(focusedDate)
                                    .substring(0, 3),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: ExampleColors.black.withOpacity(.5),
                                ),
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                              Text(
                                "${events.length} events",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: ExampleColors.black.withOpacity(.5),
                                ),
                              ),
                              Spacer(),
                              InkWell(
                                onTap: () {
                                  widget.onAddClicked(
                                    context,
                                    focusedDate,
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ExampleColors.swatch24(),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ExampleColors.black
                                            .withOpacity(0.25),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(
                                      Icons.add_outlined,
                                      color: ExampleColors.white,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      );
                    },
                    eventBuilders: {
                      EventWithLabel: (context, data) {
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
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
