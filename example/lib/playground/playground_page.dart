import 'package:example/playground/bloc/list_cubit/list_cubit.dart';
import 'package:example/playground/image_calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:example/playground/events_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PlaygroundPage extends StatelessWidget {
  const PlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today =
        DateUtils.dateOnly(DateTime.now().subtract(Duration(days: 1)));
    final breaks = List.generate(
      7,
      (index) {
        final dayDate =
            DateUtils.addDaysToDate(today, index - today.weekday + 1);
        final isSunday = dayDate.weekday == DateTime.sunday;

        return Break(
          id: 'Break $index',
          start: isSunday ? dayDate : dayDate.add(const Duration(hours: 13)),
          duration:
              isSunday ? const Duration(days: 1) : const Duration(hours: 1),
          color: Colors.grey.withOpacity(0.25),
        );
      },
    );

    final events = [
      SimpleAllDayEvent(
        id: 'All-day 1',
        start: today,
        duration: const Duration(days: 2),
        title: 'Event 1 (all-day) 1 - long title to test the text overflow',
        color: Colors.redAccent.shade200,
      ),
      SimpleAllDayEvent(
        id: 'All-day 4',
        start: today,
        duration: const Duration(days: 2),
        title: 'Event 4',
        color: Colors.greenAccent.shade200,
      ),
      SimpleAllDayEvent(
        id: 'All-day 5',
        start: today.add(Duration(days: 1)),
        duration: const Duration(days: 2),
        title: 'Event 5',
        color: Colors.greenAccent.shade200,
      ),
      SimpleAllDayEvent(
        id: 'All-day 6',
        start: today.add(Duration(days: 4)),
        duration: const Duration(days: 4),
        title: 'Event 6',
        color: Colors.greenAccent.shade200,
      ),
      SimpleAllDayEvent(
        id: 'All-day 7',
        start: today.add(Duration(days: 4)),
        duration: const Duration(days: 1),
        title: 'Event 7',
        color: Colors.greenAccent.shade200,
      ),
      SimpleAllDayEvent(
        id: 'All-day 8',
        start: today.add(Duration(days: 5)),
        duration: const Duration(days: 3),
        title: 'Event 8',
        color: Colors.greenAccent.shade200,
      ),
      SimpleAllDayEvent(
        id: 'All-day 9',
        start: today,
        duration: const Duration(days: 7),
        title: 'Event 9',
        color: Colors.greenAccent.shade200,
      ),
      SimpleAllDayEvent(
        id: 'All-day 10',
        start: today.add(Duration(days: 5)),
        duration: const Duration(days: 14),
        title: 'Event 9',
        color: Colors.greenAccent.shade200,
      ),
      ImageCalendarEvent(
        id: "Task1",
        title: "Workout",
        imgAsset: 'assets/images/gym.jpg',
        start: today.add(Duration(hours: 13)),
        duration: Duration(hours: 1),
        color: Colors.black,
      ),
      TaskDue(
        id: 'TaskDue 1',
        start: today.add(const Duration(hours: 13)),
      ),
      SimpleEvent(
        id: 'Event 4',
        start: today.add(const Duration(hours: 70)),
        duration: const Duration(hours: 26),
        title: 'Event 4',
      ),
      SimpleEvent(
        id: 'Event 3',
        start: today.add(const Duration(hours: 12)),
        duration: const Duration(days: 1, minutes: 30),
        title: 'Event 3',
      ),
      SimpleEvent(
        id: 'Event 2',
        start: today.add(const Duration(hours: 12)),
        duration: const Duration(minutes: 30),
        title: 'Event 2',
      ),
      SimpleEvent(
        id: 'Event 1',
        start: today.add(const Duration(hours: 38)),
        duration: const Duration(hours: 70),
        title: 'Event 1',
      ),
    ];

    return BlocProvider<ListCubit>(
      create: (context) => ListCubit()
        ..saveAll(
          events: events,
          breaks: breaks,
        ),
      child: CalendarPage<FloatingCalendarEvent>(),
    );
  }
}

class CalendarPage<T extends FloatingCalendarEvent> extends StatefulWidget {
  const CalendarPage({
    super.key,
  });

  @override
  State<CalendarPage<T>> createState() => _CalendarPageState<T>();
}

class _CalendarPageState<T extends FloatingCalendarEvent>
    extends State<CalendarPage<T>> with SingleTickerProviderStateMixin {
  final _daysViewController = DaysViewController(
    initialDate: _initialDate,
    endDate: _endDate,
  );
  final _weekViewController = WeekViewController(
    initialDate: _initialDate,
    endDate: _endDate,
  );
  final _monthViewController = MonthViewController(
    initialDate: _initialDate,
    endDate: _endDate,
  );

  final _scheduleListViewController = ScheduleListViewController(
    initialDate: _initialDate,
    endDate: _endDate,
  );

  late final TabController _tabController;
  late ThemeData _theme;

  // The initial date is 1970-01-01 in local time
  static DateTime get _initialDate => DateTime(1970);

  static DateTime? get _endDate => null;

  Map<int, CalendarController> get _controllers => {
        0: _daysViewController,
        1: _weekViewController,
        2: _monthViewController,
        3: _scheduleListViewController,
      };

  Map<int, String> get _segmentLabels => {
        0: CalendarView.days.name,
        1: CalendarView.week.name,
        2: CalendarView.month.name,
        3: "List",
      };

  late final ListCubit listCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    listCubit = context.read<ListCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListCubit, ListState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Schedule'),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: _theme.scaffoldBackgroundColor,
          actions: [
            CupertinoButton(
              onPressed: () => _controllers[_tabController.index]?.reset(),
              child: Text(
                'Now',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              _calendarViewPicker(),
              Expanded(child: _calendarViews()),
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _daysViewController.dispose();
    _weekViewController.dispose();
    _monthViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _calendarViewPicker() => StatefulBuilder(
        builder: (context, setState) => CupertinoSegmentedControl<int>(
          children: Map.fromEntries(
            List.generate(
              _tabController.length,
              (index) => MapEntry(index, _segment(index)),
            ),
          ),
          onValueChanged: (index) {
            _tabController.animateTo(index);
            setState(() {});
          },
          groupValue: _tabController.index,
        ),
      );

  Widget _segment(int index) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 20,
        ),
        child: Text(
          _segmentLabels[index]?.capitalized() ?? '???',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _calendarViews() => TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _daysView(),
          _weekView(),
          _monthView(),
          _scheduleListView(),
        ],
      );

  final dayDateTimeFormatter = DateFormat('hh:mm a');
  final monthDateTimeFormatter = DateFormat('MMM dd');

  Widget _scheduleListView() => ScheduleListView(
        breaks: listCubit.state.breaks.values.toList(),
        events: listCubit.state.events.values.cast<T>().toList(),
        controller: _scheduleListViewController,
        floatingEventsTheme: _floatingEventsTheme,
        ignoreDaysWithoutEvents: true,
        eventBuilders: {
          ..._getEventBuilders(),
          SimpleAllDayEvent: (context, event) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    4,
                  ),
                  color: Colors.black12,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'All-day',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (event as SimpleAllDayEvent).title,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Divider(color: Colors.black),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                              '${monthDateTimeFormatter.format(event.start)} - '
                              '${monthDateTimeFormatter.format(event.end)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          Break: (context, brk) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    4,
                  ),
                  color: Colors.black12,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Break'),
                      Row(
                        children: [
                          Text('${dayDateTimeFormatter.format(brk.start)} - '
                              '${dayDateTimeFormatter.format(brk.end)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
        monthPickerTheme: _periodPickerTheme,
        monthPickerBuilder: (nextMonth, prevMonth, toTime, currentTime) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: prevMonth,
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                Text(
                  currentTime.year != DateTime.now().year
                      ? DateFormat('MMMM yyyy').format(currentTime)
                      : DateFormat('MMMM').format(currentTime),
                  style: _textStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: nextMonth,
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          );
        },
      );

  Widget _daysView() => Stack(
        children: [
          DaysView<T>(
            saverConfig: _saverConfig(),
            controller: _daysViewController,
            monthPickerTheme: _periodPickerTheme,
            allDayEventsTheme: _getAllDayEventsTheme(),
            // overrideOnEventLongPress: (details, event) {
            //   // ignore
            //   print(event);
            // },
            onAllDayEventsShowMoreTap: (visibleEvents, events) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EventsListPage(
                        events: events,
                        day: events.first.start,
                      )));
            },
            onAllDayEventTap: print,
            allDayEventsShowMoreBuilder: _getCustomAllDayEventsShowMoreBuilder,
            eventBuilders: _getEventBuilders(),
            daysListTheme: DaysListTheme(
              itemTheme: DaysListItemTheme(
                foreground: _theme.primaryColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: _theme.primaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            timelineTheme: TimelineTheme(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              timeScaleTheme: TimeScaleTheme(
                textStyle: _textStyle,
                currentTimeMarkTheme: _currentTimeMarkTheme,
              ),
              floatingEventsTheme: _floatingEventsTheme,
              draggableEventTheme: _draggableEventTheme,
            ),
            breaks: listCubit.state.breaks.values.toList(),
            events: listCubit.state.events.values.cast<T>().toList(),
            onDateLongPress: _onDateLongPress,
            onEventTap: print,
            onEventUpdated: (obj) {
              print(obj);
              context.read<ListCubit>().save(obj);
            },
            onDiscardChanges: (obj) {
              print(obj);
            },
          ),
        ],
      );

  AllDayEventsTheme _getAllDayEventsTheme() {
    return AllDayEventsTheme(
      listMaxRowsVisible: 3,
      eventMargin: const EdgeInsets.all(4),
      eventPadding: const EdgeInsets.symmetric(horizontal: 4),
      borderRadius: 8,
      containerPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      eventHeight: 32,
      elevation: 2,
      textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _getCustomAllDayEventsShowMoreBuilder(visibleEvents, events) =>
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EventsListPage(
                    events: events,
                    day: events.first.start,
                  )));
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(4),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Show more (${events.length - visibleEvents.length})',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Map<Type, EventBuilder<CalendarEvent>> _getEventBuilders() {
    return {
      ImageCalendarEvent: <CustomEvent>(context, event) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage(event.imgAsset),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.1),
              padding: const EdgeInsets.all(4),
              child: Text(
                event.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 8,
                    ),
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
    };
  }

  Widget _weekView() {
    return WeekView<T>(
      saverConfig: _saverConfig(),
      controller: _weekViewController,
      eventBuilders: _getEventBuilders(),
      pageViewPhysics: const BouncingScrollPhysics(),
      // allDayEventsTheme: _getAllDayEventsTheme(),
      weekPickerTheme: _periodPickerTheme,
      // overrideOnEventLongPress: (details, event) {
      //   // ignore
      //   print(event);
      // },
      onAllDayEventsShowMoreTap: (visibleEvents, events) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EventsListPage(
                  events: events,
                  day: events.first.start,
                )));
      },
      onAllDayEventTap: print,
      // allDayEventsShowMoreBuilder: _getCustomAllDayEventsShowMoreBuilder,
      divider: Divider(
        height: 2,
        thickness: 2,
        color: Colors.grey.withOpacity(0.33),
      ),
      daysRowTheme: DaysRowTheme(
        weekdayStyle: _textStyle,
        numberStyle: _textStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _theme.primaryColor,
        ),
      ),
      timelineTheme: TimelineTheme(
        padding: const EdgeInsets.symmetric(vertical: 32),
        timeScaleTheme: TimeScaleTheme(
          width: 48,
          currentTimeMarkTheme: _currentTimeMarkTheme,
          drawHalfHourMarks: false,
          drawQuarterHourMarks: false,
          hourFormatter: (time) => time.hour.toString(),
          textStyle: _textStyle,
          marksAlign: MarksAlign.center,
        ),
        floatingEventsTheme: _floatingEventsTheme,
        draggableEventTheme: _draggableEventTheme,
      ),
      breaks: listCubit.state.breaks.values.toList(),
      events: listCubit.state.events.values.cast<T>().toList(),
      onDateLongPress: _onDateLongPress,
      onEventTap: print,
      onEventUpdated: (obj) {
        print(obj);
        context.read<ListCubit>().save(obj);
      },
      onDiscardChanges: (obj) {
        print(obj);
      },
    );
  }

  Widget _monthView() {
    return MonthView<T>(
      saverConfig: _saverConfig(),
      controller: _monthViewController,
      // overrideOnEventLongPress: (details, event) {
      //   // ignore
      //   print(event);
      // },
      showMoreTheme: MonthShowMoreTheme(
        borderRadius: 12,
      ),
      pageViewPhysics: BouncingScrollPhysics(),
      monthPickerTheme: _periodPickerTheme,
      eventBuilders: _getEventBuilders(),
      onShowMoreTap: (events, day) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EventsListPage(
                  events: events,
                  day: day,
                )));
      },
      divider: Divider(
        height: 2,
        thickness: 2,
      ),
      daysRowTheme: DaysRowTheme(
        weekdayStyle: _textStyle,
        numberStyle: _textStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _theme.primaryColor,
        ),
      ),
      timelineTheme: TimelineTheme(
        padding: const EdgeInsets.symmetric(vertical: 32),
        timeScaleTheme: TimeScaleTheme(
          width: 48,
          currentTimeMarkTheme: _currentTimeMarkTheme,
          drawHalfHourMarks: false,
          drawQuarterHourMarks: false,
          hourFormatter: (time) => time.hour.toString(),
          textStyle: _textStyle,
          marksAlign: MarksAlign.center,
        ),
        floatingEventsTheme: _floatingEventsTheme,
        draggableEventTheme: _draggableEventTheme,
      ),
      monthDayTheme: MonthDayTheme(
        selectedDayNumberTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        // currentDayColor: Colors.grey,
        // dayColor: Colors.white,
        // spacingColor: Colors.orange,
        dayNumberHeight: 24,
        dayNumberMargin: EdgeInsets.all(3),
        dayNumberBackgroundColor: Colors.grey.withOpacity(0.3),
      ),
      breaks: listCubit.state.breaks.values.toList(),
      events: listCubit.state.events.values.cast<T>().toList(),
      onDateLongPress: _onDateLongPress,
      onEventTap: print,
      onEventUpdated: (obj) {
        print(obj);
        context.read<ListCubit>().save(obj);
      },
      onDiscardChanges: (obj) {
        print(obj);
      },
    );
  }

  Future<CalendarEvent?> _onDateLongPress(DateTime timestamp) async {
    print(timestamp);
    final _minute = timestamp.minute;
    return await showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 32,
          ),
          ListTile(
            title: Text("Simple Event"),
            onTap: () {
              final T newItem = SimpleEvent(
                id: const Uuid().v1(),
                start: timestamp.subtract(Duration(minutes: _minute)),
                duration: Duration(hours: 1),
                title: "Simple event",
              ) as T;
              listCubit.save(newItem);
              Navigator.of(context).pop(newItem);
            },
          ),
          ListTile(
            title: Text("Task Due"),
            onTap: () {
              final T newItem = TaskDue(
                id: const Uuid().v1(),
                start: timestamp.subtract(Duration(minutes: _minute)),
              ) as T;
              listCubit.save(newItem);
              Navigator.of(context).pop(newItem);
            },
          ),
          ListTile(
            title: Text("Break"),
            onTap: () {
              final Break newItem = Break(
                id: const Uuid().v1(),
                start: timestamp.subtract(Duration(minutes: _minute)),
                duration: Duration(hours: 1),
              );
              listCubit.save(newItem);
              Navigator.of(context).pop(newItem);
            },
          ),
          ListTile(
            title: Text("Image Event"),
            onTap: () {
              final T newItem = ImageCalendarEvent(
                id: const Uuid().v1(),
                start: timestamp.subtract(Duration(minutes: _minute)),
                duration: Duration(hours: 1),
                title: "Image event",
                imgAsset: 'assets/images/gym.jpg',
                color: Colors.blueAccent,
              ) as T;
              listCubit.save(newItem);
              Navigator.of(context).pop(newItem);
            },
          ),
          ListTile(
            title: Text("Simple All Day Event"),
            onTap: () {
              final T newItem = SimpleAllDayEvent(
                id: const Uuid().v1(),
                start: timestamp.subtract(Duration(minutes: _minute)),
                duration: Duration(days: 5),
                title: "Simple All Day Event",
                color: Colors.blueAccent,
              ) as T;
              listCubit.save(newItem);
              Navigator.of(context).pop(newItem);
            },
          ),
        ],
      ),
    );
  }

  SaverConfig _saverConfig() => SaverConfig(
        child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(15),
            child: Icon(Icons.done)),
      );

  TextStyle get _textStyle => TextStyle(
        fontSize: 12,
        color: Colors.grey.shade700,
      );

  DisplayedPeriodPickerTheme get _periodPickerTheme =>
      DisplayedPeriodPickerTheme(
        height: 40,
        foregroundColor: _theme.primaryColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _theme.primaryColor),
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: TextStyle(
          color: _theme.primaryColor,
          fontWeight: FontWeight.w600,
          backgroundColor: Colors.transparent,
        ),
      );

  TimeMarkTheme get _currentTimeMarkTheme => TimeMarkTheme(
        length: 48,
        color: _theme.colorScheme.error,
      );

  FloatingEventsTheme get _floatingEventsTheme => FloatingEventsTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        margin: const EdgeInsets.all(1),
        // monthTheme: ViewEventTheme(
        //   titleStyle: TextStyle(
        //     fontSize: 10,
        //   ),
        // )
      );

  DraggableEventTheme get _draggableEventTheme => DraggableEventTheme(
        elevation: 5,
        sizerTheme: SizerTheme(
          decoration: BoxDecoration(
            color: _theme.colorScheme.error,
            shape: BoxShape.circle,
          ),
        ),
      );
}
