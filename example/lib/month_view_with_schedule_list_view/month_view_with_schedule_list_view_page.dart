import 'dart:math';

import 'package:example/month_view_with_schedule_list_view/add_event_page.dart';
import 'package:example/month_view_with_schedule_list_view/cubit/events_cubit.dart';
import 'package:example/colors.dart';
import 'package:example/month_view_with_schedule_list_view/custom_events/delivery_event.dart';
import 'package:example/month_view_with_schedule_list_view/custom_events/event_attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:intl/intl.dart';

class MonthViewWithScheduleListViewPage extends StatefulWidget {
  const MonthViewWithScheduleListViewPage({super.key});

  @override
  State<MonthViewWithScheduleListViewPage> createState() =>
      _MonthViewWithScheduleListViewPageState();
}

class _MonthViewWithScheduleListViewPageState
    extends State<MonthViewWithScheduleListViewPage>
    with TickerProviderStateMixin {
  final MonthViewController monthViewController = MonthViewController();
  final ScheduleListViewController scheduleListController =
      ScheduleListViewController();

  final DateFormatter weekDayFormatter =
      (dayDate) => DateFormat.E().format(dayDate).substring(0, 2).toLowerCase();

  late final AnimationController _animationController;

  late final Animation<double> _calendarHeightAnimation;
  late final Animation<double> _monthPickerOpacityAnimation;
  late final Animation<double> _monthPickerSizeYAnimation;
  late final Animation<double> _arrowRotationAnimation;

  final double maxCalendarHeight = 425;
  final double minCalendarHeight = 140;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
    );
    _calendarHeightAnimation = Tween<double>(
      begin: maxCalendarHeight,
      end: minCalendarHeight,
    ).animate(_animationController);
    _monthPickerOpacityAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(_animationController);
    _monthPickerSizeYAnimation = Tween<double>(
      begin: 72,
      end: 0,
    ).animate(_animationController);
    _arrowRotationAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    monthViewController.dispose();
    scheduleListController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsCubit>(
      create: (_) => EventsCubit()..init(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: ExampleColors.white,
        body: BlocBuilder<EventsCubit, EventsState>(
          builder: (context, state) {
            if (state is! EventsInitialized) {
              return Center(
                child: CircularProgressIndicator(
                  color: ExampleColors.swatch24(),
                ),
              );
            }
            return MultiBlocListener(
              listeners: [
                BlocListener<ScheduleListViewController,
                    ScheduleListViewControllerState>(
                  bloc: scheduleListController,
                  listener: (context, state) {
                    if (state is ScheduleListViewControllerCurrentDateIsSet) {
                      _setSelectedDate(
                        state.displayedDate,
                        updateScheduleList: false,
                        updateMonthView: true,
                      );
                    }
                  },
                ),
              ],
              child: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, EventsInitialized state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            SafeArea(
              top: true,
              bottom: false,
              child: AnimatedBuilder(
                animation: _calendarHeightAnimation,
                builder: (context, child) {
                  return SizedBox(
                    height: _calendarHeightAnimation.value,
                    child: child!,
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(24.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ExampleColors.swatch24(),
                      ),
                      child: Column(
                        children: [
                          Expanded(child: _buildMonthView(state)),
                          const SizedBox(
                            height: 12,
                          ),
                          GestureDetector(
                              onVerticalDragUpdate: (details) {
                                double positionY = details.globalPosition.dy -
                                    MediaQuery.of(context).padding.top -
                                    MediaQuery.of(context).padding.bottom -
                                    24;
                                double maxHeight =
                                    MediaQuery.of(context).size.height -
                                        MediaQuery.of(context).padding.top -
                                        MediaQuery.of(context).padding.bottom;

                                if (positionY >= maxCalendarHeight) {
                                  _animationController.value = 0;
                                } else if (positionY <= maxHeight) {
                                  final newPos = 1 -
                                      (positionY /
                                          (maxCalendarHeight +
                                              MediaQuery.of(context)
                                                  .padding
                                                  .top +
                                              MediaQuery.of(context)
                                                  .padding
                                                  .bottom));
                                  if (newPos != _animationController.value)
                                    _animationController.value = newPos;
                                }
                              },
                              onVerticalDragCancel: () {
                                if (_animationController.value > 0.5) {
                                  _animationController.animateTo(1,
                                      duration: Duration(milliseconds: 100));
                                } else {
                                  _animationController.animateBack(0,
                                      duration: Duration(milliseconds: 100));
                                }
                              },
                              onVerticalDragEnd: (details) {
                                if (details.velocity.pixelsPerSecond.dy >
                                    1500) {
                                  _animationController.animateTo(0,
                                      duration: Duration(milliseconds: 100));
                                } else if (_animationController.value > 0.5 ||
                                    (details.velocity.pixelsPerSecond.dy <
                                        -1500)) {
                                  _animationController.animateTo(1,
                                      duration: Duration(milliseconds: 100));
                                } else {
                                  _animationController.animateBack(0,
                                      duration: Duration(milliseconds: 100));
                                }
                              },
                              child: Container(
                                width: double.maxFinite,
                                color: ExampleColors.swatch24(),
                                height: 32,
                                child: AnimatedBuilder(
                                    animation: _arrowRotationAnimation,
                                    builder: (context, child) =>
                                        Transform.rotate(
                                            angle:
                                                _arrowRotationAnimation.value,
                                            child: child!),
                                    child: Icon(
                                      Icons.arrow_upward,
                                      color:
                                          ExampleColors.white.withOpacity(0.6),
                                    )),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: _buildListView(state)),
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => AddEventPage(),
                  ),
                )
                    .then((value) {
                  if (value is DeliveryEvent) {
                    BlocProvider.of<EventsCubit>(context).addEvent(value);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ExampleColors.black.withOpacity(0.25),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ExampleColors.white.withOpacity(0.5),
                      blurRadius: 16,
                      spreadRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  color: ExampleColors.swatch24(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.add_rounded,
                    color: ExampleColors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView(EventsInitialized state) {
    return MonthView<DeliveryEvent<EventAttachment>>(
      controller: monthViewController,
      events: state.events,
      weekStartsOnSunday: true,
      daysRowTheme: DaysRowTheme(
        height: 32,
        backgroundColor: ExampleColors.swatch24(),
        weekdayFormatter: weekDayFormatter,
        weekdayStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ExampleColors.white,
        ),
      ),
      pageViewPhysics: const BouncingScrollPhysics(),
      showMoreTheme: MonthShowMoreTheme(eventHeight: 0),
      monthDayTheme: MonthDayTheme(
        dayNumberHeight: 48,
        dayNumberMargin: EdgeInsets.zero,
        spacingColor: ExampleColors.swatch24(),
        dayColor: ExampleColors.swatch24(),
        currentDayColor: ExampleColors.swatch24(),
        dayNumberPadding: const EdgeInsets.only(top: 0),
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      monthDayBuilder: (context, events, day) {
        final bool selected = DateUtils.isSameDay(_selectedDate, day);

        final eventsStartedToday = events.where((event) {
          final eventStart = DateTime(
            event.start.year,
            event.start.month,
            event.start.day,
          );
          return eventStart.isAtSameMomentAs(day);
        });

        final highlight = eventsStartedToday.isNotEmpty || selected;
        return GestureDetector(
          onTap: () {
            _setSelectedDate(
              day,
              updateMonthView: false,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ExampleColors.swatch24(),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          selected ? ExampleColors.swatch1 : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontWeight: highlight ? FontWeight.bold : null,
                        color: ExampleColors.white.withOpacity(
                          highlight ? 1 : .5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(),
              if (eventsStartedToday.isNotEmpty)
                Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ExampleColors.white,
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                ),
              Spacer(),
            ],
          ),
        );
      },
      monthPickerBuilder: (context, prev, next, focus) {
        return AnimatedBuilder(
          animation: _monthPickerSizeYAnimation,
          builder: (context, child) {
            return Container(
              height: _monthPickerSizeYAnimation.value,
              decoration: BoxDecoration(
                color: ExampleColors.swatch24(),
              ),
              child: child!,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: AnimatedBuilder(
              animation: _monthPickerOpacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _monthPickerOpacityAnimation.value,
                  child: child!,
                );
              },
              child: Row(
                children: [
                  const SizedBox(
                    width: 32,
                  ),
                  Text(
                    DateFormat.yMMMd().format(focus),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: ExampleColors.white,
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      _buildNavButton(
                          prev,
                          Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 16,
                            color: ExampleColors.white,
                          )),
                      const SizedBox(
                        width: 24,
                      ),
                      _buildNavButton(
                          next,
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: ExampleColors.white,
                          )),
                    ],
                  ),
                  const SizedBox(
                    width: 32,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _setSelectedDate(
    DateTime day, {
    bool updateScheduleList = true,
    bool updateMonthView = true,
  }) {
    _selectedDate = day;
    if (updateScheduleList) {
      scheduleListController.setDisplayedDate(day);
    }
    if (updateMonthView) {
      monthViewController.setFocusedDate(day);
    }
    if (mounted) {
      setState(() {});
    }
  }

  ScheduleListView<DeliveryEvent<EventAttachment>> _buildListView(
      EventsInitialized state) {
    return ScheduleListView(
      controller: scheduleListController,
      monthPickerBuilder: (
        context,
        next,
        prev,
        toTime,
        currentTime,
      ) =>
          const SizedBox(),
      events: state.events,
      ignoreDaysWithoutEvents: false,
      dayBuilder: (context, events, day) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDayEventsTitle(day),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ExampleColors.black,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              if (events.isEmpty)
                _buildEmptyListViewState()
              else
                ...events.whereType<DeliveryEvent>().map(
                  (event) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildListItemEvent(event),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Padding _buildEmptyListViewState() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "No events",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ExampleColors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDayEventsTitle(DateTime day) {
    final now = DateTime.now();
    final bool today = day.isAtSameMomentAs(
      DateTime(now.year, now.month, now.day),
    );
    final bool tomorrow = day.isAtSameMomentAs(
      DateTime(now.year, now.month, now.day + 1),
    );
    final bool yesterday = day.isAtSameMomentAs(
      DateTime(now.year, now.month, now.day - 1),
    );

    return today
        ? "Today"
        : tomorrow
            ? "Tomorrow"
            : yesterday
                ? "Yesterday"
                : DateFormat("EEEE d").format(day);
  }

  Widget _buildListItemEvent(DeliveryEvent<EventAttachment> event) {
    return Row(
      children: [
        const SizedBox(
          width: 12,
        ),
        if (event.completed)
          Icon(
            Icons.check,
            size: 24,
            color: ExampleColors.swatch24(),
          )
        else
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: ExampleColors.swatch24(),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(
          width: 20,
        ),
        Container(
          decoration: BoxDecoration(
            color: Color(0XFFF6F7F7),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: ExampleColors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .6,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: ExampleColors.black,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  "${DateFormat("ha").format(event.start)} - ${DateFormat("ha").format(event.start.add(event.duration))}"
                                      .toLowerCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: ExampleColors.black.withAlpha(200),
                                  )),
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: ExampleColors.black.withAlpha(200),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                event.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: ExampleColors.black.withAlpha(200),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: ExampleColors.black.withOpacity(0.1),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            )
                          ],
                          color: ExampleColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: ExampleColors.white,
                                image: DecorationImage(
                                  image: Image.asset(
                                    event.iconAsset,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ).image,
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 48,
                      child: Stack(
                        children: [
                          for (int i = 0; i < event.attachments.length; i++)
                            Positioned(
                              bottom: 0,
                              left: i * 24.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ExampleColors.white,
                                  border: Border.all(
                                    color: ExampleColors.swatch3,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          ExampleColors.white.withOpacity(0.5),
                                      blurRadius: 24,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      height: 24,
                                      width: 24,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: Image.asset(
                                            event.attachments[i].iconAsset,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                          ).image,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      child: Text(
                        "${event.attachments.map((e) => e.title).join(", ")}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ExampleColors.black.withAlpha(200),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  InkWell _buildNavButton(void Function() onTap, Widget child) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: ExampleColors.white.withAlpha(50),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: ExampleColors.swatch4.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }
}
