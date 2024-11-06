import 'package:example/month_view_with_schedule_list_view/month_view_with_schedule_list_view_page.dart';
import 'package:example/week_view_page/week_view_page.dart';
import 'package:flutter/material.dart';

import 'schedule_list_view_with_days_view/schedule_list_view_with_days_view_page.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter customizable calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade50,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter customizable calendar'),
      ),
      body: ListView(
        children: [
          // ListTile(
          //   title: const Text('Playground'),
          //   onTap: () => Navigator.of(context).push(
          //       MaterialPageRoute(builder: (context) => PlaygroundPage())),
          // ),
          ListTile(
            title: const Text('MonthView + ScheduleListView'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    const MonthViewWithScheduleListViewPage())),
          ),
          ListTile(
            title: const Text("ScheduleListView + DaysView"),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ScheduleListViewWithDaysView())),
          ),
          ListTile(
            title: const Text("WeekView"),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const WeekViewPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
