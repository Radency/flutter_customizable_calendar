import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());

    return MaterialApp(
      title: 'Flutter customizable calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade50,
      ),
      home: CalendarPage(
        breaks: List.generate(
          7,
          (index) {
            final dayDate =
                DateUtils.addDaysToDate(today, index - today.weekday + 1);
            final isSunday = dayDate.weekday == DateTime.sunday;

            return Break(
              id: 'Break $index',
              start:
                  isSunday ? dayDate : dayDate.add(const Duration(hours: 13)),
              duration:
                  isSunday ? const Duration(days: 1) : const Duration(hours: 1),
              color: Colors.grey.withOpacity(0.25),
            );
          },
        ),
        events: [
          TaskDue(
            id: 'TaskDue 1',
            start: today.add(const Duration(hours: 13)),
          ),
          SimpleEvent(
            id: 'Event 2',
            start: today.add(const Duration(hours: 11, minutes: 59)),
            duration: const Duration(minutes: 30),
            title: 'Event 2',
          ),
          SimpleEvent(
            id: 'Event 1',
            start: today.add(const Duration(hours: 11, minutes: 59)),
            duration: const Duration(minutes: 40),
            title: 'Event 1',
          ),
          SimpleEvent(
            id: 'Event 3',
            start: today.add(const Duration(days: 2, hours: 10, minutes: 59)),
            duration: const Duration(minutes: 45),
            title: 'Event 3',
          ),
        ],
      ),
    );
  }
}

class CalendarPage<T extends FloatingCalendarEvent> extends StatefulWidget {
  const CalendarPage({
    super.key,
    this.breaks = const [],
    this.events = const [],
  });

  final List<Break> breaks;

  final List<T> events;

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
  late final TabController _tabController;
  late ThemeData _theme;

  // The initial date is 1970-01-01 in local time
  static DateTime get _initialDate => DateTime(1970);
  static DateTime? get _endDate => null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
        actions: [
          CupertinoButton(
            onPressed: () => _controllers[_tabController.index]?.reset(),
            child: Text(
              'Now',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
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
  }

  @override
  void dispose() {
    _daysViewController.dispose();
    _weekViewController.dispose();
    _monthViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Map<int, CalendarController> get _controllers => {
        0: _daysViewController,
        1: _weekViewController,
        2: _monthViewController,
      };

  Map<int, String> get _segmentLabels => {
        0: 'Days',
        1: 'Week',
        2: 'Month',
      };

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
          _segmentLabels[index] ?? '???',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _calendarViews() {
    final textStyle = TextStyle(
      fontSize: 12,
      color: Colors.grey.shade700,
    );
    final periodPickerTheme = DisplayedPeriodPickerTheme(
      height: 40,
      foregroundColor: _theme.primaryColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _theme.primaryColor),
        borderRadius: BorderRadius.circular(24),
      ),
      textStyle: TextStyle(
        color: _theme.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );

    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        DaysView(
          controller: _daysViewController,
          monthPickerTheme: periodPickerTheme,
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
            timeScaleTheme: TimeScaleTheme(textStyle: textStyle),
          ),
          breaks: widget.breaks,
          events: widget.events,
          onEventTap: print,
          onDateLongPress: print,
        ),
        WeekView(
          controller: _weekViewController,
          weekPickerTheme: periodPickerTheme,
          divider: Divider(
            height: 2,
            thickness: 2,
            color: Colors.grey.withOpacity(0.33),
          ),
          daysRowTheme: DaysRowTheme(
            weekdayStyle: textStyle,
            numberStyle: textStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _theme.primaryColor,
            ),
          ),
          timelineTheme: TimelineTheme(
            padding: const EdgeInsets.symmetric(vertical: 32),
            timeScaleTheme: TimeScaleTheme(
              width: 48,
              drawHalfHourMarks: false,
              drawQuarterHourMarks: false,
              hourFormatter: (time) => time.hour.toString(),
              textStyle: textStyle,
              marksAlign: MarksAlign.center,
            ),
          ),
          breaks: widget.breaks,
          events: widget.events,
          onEventTap: print,
          onDateLongPress: print,
        ),
        const MonthView(),
      ],
    );
  }
}
