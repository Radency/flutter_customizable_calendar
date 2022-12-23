import 'package:example/src/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
        ],
      ),
    );
  }
}
