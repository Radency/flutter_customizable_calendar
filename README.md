# flutter_customizable_calendar

**flutter_customizable_calendar** is a feature-rich Flutter package that offers highly customizable calendar views for displaying days, weeks, and months. It allows developers to tailor the appearance of the calendar and supports the addition, dynamic editing, and removal of events and breaks.

---

<table>
    <tr>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/DaysView.gif" width="250" title="Basic Days view">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/WeekView.gif" width="250" title="Basic Week view">
            <p>Week View</p>
        </th>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/MonthView.gif" width="250" title="Basic Month view">
            <p>Month View</p>
        </th>
    </tr>
</table>

---

## Key Features
**Various Views**: The package provides three main views: `DaysView`, `WeekView`, and `MonthView`, each catering to different time spans.

**Customization**: Users can easily customize the appearance of the calendar using themes for different components such as `DaysListTheme`, `TimelineTheme`, `DaysRowTheme`, `MonthDayTheme`, `DraggableEventTheme`, `FloatingEventsTheme`, `TimeMarkTheme`, and `DisplayedPeriodPickerTheme`. 

**Dynamic Event Editing**: The calendar supports dynamic editing of events in each view. Utilizing callbacks like `onEventUpdated` and `onDiscardChanges`, users can seamlessly update or discard changes made to events.

**Event Types**: The package supports various event types, including `SimpleEvent`, `TaskDue`, and `Break`.

**Adding Events Dynamically**: Users can add events dynamically by handling long presses on dates in the views. The provided example showcases how to implement this feature using a bottom sheet.

**Comprehensive Example**: The package comes with a comprehensive example app that demonstrates its usage and features. The example code is available on GitHub.

---


## Getting started

Add the following dependency to your pubspec.yaml file:

```yaml
dependencies:
  flutter_customizable_calendar: ^0.0.1
```

Then, run:

```bash
$ flutter pub get
```

---

## Usage

### Saver config

The SaverConfig allows users to configure a customized appearance for the saving indicator.
Configure the `SaverConfig` for a customized appearance:
```dart
  SaverConfig _saverConfig() => SaverConfig(
        child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(15),
            child: Icon(Icons.done)),
      );
```

---

### Basic views


Display basic views with `DaysView`, `WeekView`, an `MonthView` widgets:

<table>
    <tr>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/BasicDaysView.png" width="280" title="Basic Days view">
            <p>Basic Days View</p>
        </th>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/BasicWeekView.png" width="280" title="Basic Week view">
            <p>Basic Week View</p>
        </th>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/BasicMonthView.png" width="280" title="Basic Month view">
            <p>Basic Month View</p>
        </th>
    </tr>
</table>


```dart
final _daysViewController = DaysViewController(
  initialDate: _initialDate,
  endDate: _endDate,
);
  
SaverConfig _saverConfig() => SaverConfig(
    child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(15),
        child: Icon(Icons.done)),
    );


DaysView<T>(
      saverConfig: _saverConfig(),
      controller: _daysViewController,
      breaks: [],
      events: [],
    );

WeekView<T>(
      controller: _weekViewController,
      saverConfig: _saverConfig(),
      breaks: [],
      events: [],
    );

MonthView<T>(
      controller: _monthViewController,
      saverConfig: _saverConfig(),
      breaks: [],
      events: [],
    );
```

---

### Adding events dynamically

<table>
    <tr>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/DaysViewAddEventDynamically.gif" width="250" title="Basic Days view">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/WeekViewAddEventDynamically.gif" width="250" title="Basic Week view">
            <p>Week View</p>
        </th>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/MonthViewAddEventDynamically.gif" width="250" title="Basic Month view">
            <p>Month View</p>
        </th>
    </tr>
</table>

You can dynamically add events to the calendar by handling long presses on dates in the `DaysView`. 
This code snippet showcases how to handle long presses on dates in the `DaysView` and dynamically add different types of events such as Simple Event, Task Due, and Break. The provided callback (`_onDateLongPress`) creates a bottom sheet with options,and based on the user's selection, it adds the corresponding event to the calendar.

```dart
  Future<CalendarEvent?> _onDateLongPress(DateTime timestamp) async {
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
        ],
      ),
    );
  }

  DaysView<T>(
    //...
    onDateLongPress: _onDateLongPress,
  )
  WeekView<T>(
    //...
    onDateLongPress: _onDateLongPress,
  )
  MonthView<T>(
    //...
    onDateLongPress: _onDateLongPress,
  )
```

---

### Custom Themes

Enhance the visual appeal of your calendar views by customizing various themes for the `DaysView`, `WeekView`, and `MonthView` widgets. The flexibility of `flutter_customizable_calendar` allows you to achieve a personalized look for each view. Below are examples showcasing the visual changes applied to each view along with the corresponding code snippets:

<table>
    <tr>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/DaysViewTheme.png" width="280" title="Basic Days view">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/WeekViewTheme.png" width="280" title="Basic Week view">
            <p>Week View</p>
        </th>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/MonthViewTheme.png" width="280" title="Basic Month view">
            <p>Month View</p>
        </th>
    </tr>
</table>


```dart
DaysView<T>(
  saverConfig: _saverConfig(),
  controller: _daysViewController,
  monthPickerTheme: _periodPickerTheme,
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
  onDateLongPress: _onDateLongPress
)


WeekView<T>(
  saverConfig: _saverConfig(),
  controller: _weekViewController,
  weekPickerTheme: _periodPickerTheme,
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
  onDateLongPress: _onDateLongPress
);


MonthView<T>(
      saverConfig: _saverConfig(),
      controller: _monthViewController,
      monthPickerTheme: _periodPickerTheme,
      divider: Divider(
        height: 2,
        thickness: 2,
        color: Colors.grey.withOpacity(0.33),
        // color: Colors.green,
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
        currentDayNumberTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        // currentDayColor: Colors.grey,
        // dayColor: Colors.white,
        // spacingColor: Colors.orange,
        dayNumberHeight: 23,
        dayNumberMargin: EdgeInsets.all(3),
        dayNumberBackgroundColor: Colors.grey.withOpacity(0.3),
      ),
      breaks: listCubit.state.breaks.values.toList(),
      events: listCubit.state.events.values.cast<T>().toList(),
      onDateLongPress: _onDateLongPress
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
```

These code snippets provide examples of how to customize the appearance of each view by adjusting themes `DaysListTheme`, `TimelineTheme`, `DaysRowTheme`, `MonthDayTheme`, `DraggableEventTheme`, `FloatingEventsTheme`, `TimeMarkTheme`, and `DisplayedPeriodPickerTheme`. Feel free to experiment with these themes to achieve the desired visual style for your calendar.

---

### Editing Events Dynamically

Effortlessly edit events dynamically in the calendar by utilizing the provided callbacks for each view: `DaysView`, `WeekView`, and `MonthView`. The visual representation below illustrates the dynamic editing feature across different views:


<table>
    <tr>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/DaysViewEditEvent.gif" width="250" title="Basic Days view">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/WeekViewEditEvent.gif" width="250" title="Basic Week view">
            <p>Week View</p>
        </th>
        <th>
            <img src="https://raw.githubusercontent.com/Radency/flutter_customizable_calendar/doc/assets/MonthViewEditEvent.gif" width="250" title="Basic Month view">
            <p>Month View</p>
        </th>
    </tr>
</table>

To enable dynamic editing, you need to utilize the provided callbacks for each view. By implementing these callbacks, you can capture events when they are updated or discarded, allowing for seamless dynamic editing within your calendar views. The following code snippets demonstrate how to integrate the event editing functionality using the `onEventUpdated` and `onDiscardChanges` callbacks:

```dart

// List Cubit
void save(CalendarEvent event) {
  if (event is Break) {
    emit(state.copyWith(breaks: state.breaks..[event.id] = event));
  }
  if (event is FloatingCalendarEvent) {
    emit(state.copyWith(events: state.events..[event.id] = event));
  }
}

DaysView<T>(
    //...
    onEventUpdated: (obj) {
      print(obj);
      context.read<ListCubit>().save(obj);
    },
    onDiscardChanges: (obj) {
      print(obj);
    },
  )

WeekView<T>(
    //...
    onEventTap: print,
    onEventUpdated: (obj) {
      print(obj);
      context.read<ListCubit>().save(obj);
    },
    onDiscardChanges: (obj) {
      print(obj);
    },
  );

MonthView<T>(
    //...
    onEventTap: print,
    onEventUpdated: (obj) {
      print(obj);
      context.read<ListCubit>().save(obj);
    },
    onDiscardChanges: (obj) {
      print(obj);
    },
  );
```

---

[See the complete example](https://github.com/Radency/flutter_customizable_calendar/blob/main/example/lib/main.dart).
