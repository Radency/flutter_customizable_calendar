# flutter_customizable_calendar

**flutter_customizable_calendar** is a feature-rich Flutter package that offers highly customizable calendar views for displaying days, weeks, and months. It allows developers to tailor the appearance of the calendar and supports the addition, dynamic editing, and removal of events and breaks.

---

<table>
    <tr>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/DaysView.gif?raw=true" width="250" title="Basic Days view">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/WeekView.gif?raw=true" width="250" title="Basic Week view">
            <p>Week View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/MonthView.gif?raw=true" width="250" title="Basic Month view">
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
  flutter_customizable_calendar: ^0.2.1
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
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/BasicDaysView.png?raw=true" width="280" title="Basic Days view">
            <p>Basic Days View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/BasicWeekView.png?raw=true" width="280" title="Basic Week view">
            <p>Basic Week View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/BasicMonthView.png?raw=true" width="280" title="Basic Month view">
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
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/DaysViewAddEventDynamically.gif?raw=true" width="250" title="Basic Days view">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/WeekViewAddEventDynamically.gif?raw=true" width="250" title="Basic Week view">
            <p>Week View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/MonthViewAddEventDynamically.gif?raw=true" width="250" title="Basic Month view">
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

---- 

The `TimelineTheme` class provides a comprehensive set of customization parameters for rendering the Timeline view. This theme allows you to fine-tune various aspects of the visual appearance of the Timeline, including the padding, cell extent, time scale, floating events, and draggable events.

**Properties**
* `padding`: External padding of the scrollable view.
* `cellExtent`: In minutes, used to render and position events on the timeline.
* `timeScaleTheme`: Customization parameters of the time scale.
* `floatingEventsTheme`: Customization parameters of all the floating events views.
* `draggableEventTheme`: Customization parameters of the draggable event view.

----

The `TimeScaleTheme` class provides customization options for the TimeScale view, allowing you to control the appearance of the time scale within the Timeline.
**Properties**

* `width`: Width of the view (needed for setting padding).
* `hourExtent`: Distance between two hours.
* `currentTimeMarkTheme`: Customization parameters for the current time mark.
* `drawHalfHourMarks`: Whether a half-hour mark is needed to show.
* `halfHourMarkTheme`: Customization parameters for a half-hour mark.
* `drawQuarterHourMarks`: Whether a quarter-hour mark is needed to show.
* `quarterHourMarkTheme`: Customization parameters for a quarter-hour mark.
* `hourFormatter`: Hour string formatter.
* `textStyle`: Hour text style.
* `marksAlign`: Scale marks alignment.

----

The `TimeMarkTheme` class provides customization options for time marks within the TimeScale.
**Properties**
* `length`: Length of the line.
* `color`: Color of the line.
* `strokeWidth`: Thickness of the line.
* `strokeCap`: The kind of finish to place on the end of the line.

----

The `MonthDayTheme` class provides customization options for the DaysList within the Timeline, allowing you to control the appearance of day cards.

**Properties**
* `dayColor`: Color of the day card.
* `currentDayColor`: Color of the current day card.
* `dayNumberBackgroundColor`: Background color of the day number.
* `currentDayNumberBackgroundColor`: Background color of the current day number.
* `spacingColor`: Color of spacing between day views.
* `dayNumberTextStyle`: Text style of the day number.
* `currentDayNumberTextStyle`: Text style of the current day number.
* `crossAxisSpacing`: Cross-axis spacing between day views.
* `mainAxisSpacing`: Main-axis spacing between day views.
* `dayNumberHeight`: Height of day number container.
* `dayNumberMargin`: Margin of day number container.
* `dayNumberPadding`: Padding of day number container.

----

The `FloatingEventsTheme` class provides customization options for floating events views within the Timeline.

**Properties**
* `elevation`: Elevation over a day view.
* `shape`: Shape and border of the views.
* `margin`: Paddings between the views.
* `dayTheme`: Theme for day events.
* `weekTheme`: Theme for week events.
* `monthTheme`: Theme for month events.

----

The `ViewEventTheme` class provides customization options for event views within the floating events views.

**Properties**
* `titleStyle`: Text style for the event title.

----

The `DraggableEventTheme` class provides customization options for the draggable event view within the Timeline.

Properties
* `elevation`: Elevation over a day view.
* `sizerTheme`: Sizer view's customization parameters.
* `animationDuration`: Duration of the view's animation.
* `animationCurve`: Allows changing the animation's behavior (use a `Curve` which supports changing a value between [0...1]).

----

The `DisplayedPeriodPickerTheme` class provides customization options for the DisplayedPeriodPicker within the Timeline.

**Properties**
* `margin`: External padding.
* `elevation`: The z-coordinate at which to place the view.
* `backgroundColor`: Background color.
* `foregroundColor`: Foreground color.
* `shape`: Shape and border of the view.
* `width`: View width.
* `height`: View height.
* `periodFormatter`: Displayed period formatter.
* `textStyle`: Typographical style for text.
* `prevButtonTheme`: Theme for the left button.
* `nextButtonTheme`: Theme for the right button.

----

The `DisplayedPeriodPickerButtonTheme` class provides customization options for buttons within the DisplayedPeriodPicker.

**Properties**
* `color`: Color of the button.
* `padding`: Space to surround the icon inside the bounds of the button.
* `borderRadius`: Radius of the button's corners when it has a background color.
* `child`: Widget below this widget in the tree.

----

The `DaysRowTheme` class provides customization options for the days row within the Timeline.

**Properties**
* `height`: Row height.
* `hideWeekday`: Whether weekday is needed to show.
* `weekdayFormatter`: Weekday string formatter.
* `weekdayStyle`: Weekday text style.
* `hideNumber`: Whether number is needed to show.
* `numberFormatter`: Number string formatter.
* `numberStyle`: Number text style.

----

The `DaysListTheme` class provides customization options for the DaysList within the Timeline.

**Properties**
* `padding`: List item padding.
* `height`: List height.
* `physics`: How the page view should respond to user input.
* `itemExtent`: List item extent.
* `itemTheme`: Theme of the list item.

----

The `DaysListItemTheme` class provides further customization options for list items within the DaysList of the Timeline.

**Properties**
* `margin`: List item external padding.
* `elevation`: The z-coordinate at which to place the event view.
* `background`: Background color.
* `backgroundFocused`: Background color if the item is focused. If null, the foreground color is used.
* `foreground`: Foreground color (used to set text color).
* `foregroundFocused`: Foreground color if the item is focused. If null, the background color is used.
* `shape`: Shape and border of the item.
* `shapeFocused`: Shape and border if the item is focused. If null, the shape property is used.
* `numberFormatter`: Number string formatter.
* `numberStyle`: Number text style.
* `numberStyleFocused`: Number text style if the item is focused.
* `hideWeekday`: Whether weekday is needed to show.
* `weekdayFormatter`: Weekday string formatter.
* `weekdayStyle`: Weekday text style.
* `weekdayStyleFocused`: Weekday text style if the item is focused.

----

<table>
    <tr>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/DaysViewTheme.png?raw=true" width="280" title="Basic Days view">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/WeekViewTheme.png?raw=true" width="280" title="Basic Week view">
            <p>Week View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/MonthViewTheme.png?raw=true" width="280" title="Basic Month view">
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
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/DaysViewEditEvent.gif?raw=true" width="250" title="Basic Days view">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/WeekViewEditEvent.gif?raw=true" width="250" title="Basic Week view">
            <p>Week View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/MonthViewEditEvent.gif?raw=true" width="250" title="Basic Month view">
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


### All-Day Events

The package supports all-day events for `DaysView` and `WeekView`. The following code snippet demonstrates how to create an all-day event:

```dart
SimpleAllDayEvent(
  id: 'All-day 1',
  start: today,
  duration: const Duration(days: 2),
  title: 'Event 1',
  color: Colors.redAccent.shade200,
)
```

This events can be added to the `events` list of the `DaysView` or `WeekView`:

<table>
    <tr>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/DaysViewAllDayEventExample.png?raw=true" width="250" title="Days View">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/WeekViewAllDayEventExample.png?raw=true" width="250" title="Week View">
            <p>Week View</p>
        </th>
    </tr>
    <tr>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/DaysViewAddAllDayEvents.gif?raw=true" width="250" title="Days View">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/WeekViewAddAllDayEvents.gif?raw=true" width="250" title="Week View">
            <p>Week View</p>
        </th>
    </tr>
</table>

```dart
DaysView<T>(
  //...
  events: [
    SimpleAllDayEvent(
      id: 'All-day 1',
      start: today,
      duration: const Duration(days: 2),
      title: 'Event 1',
      color: Colors.redAccent.shade200,
    ),
  ],
)

WeekView<T>(
  //...
  events: [
    SimpleAllDayEvent(
      id: 'All-day 1',
      start: today,
      duration: const Duration(days: 2),
      title: 'Event 1',
      color: Colors.redAccent.shade200,
    ),
  ],
)
```

Here is an example of how to customize the appearance of all-day events:


<table>
    <tr>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/DaysViewAllDayEventTheme.png?raw=true" width="250" title="Days View">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/WeekViewAllDayEventTheme.png?raw=true" width="250" title="Week View">
            <p>Week View</p>
        </th>
    </tr>
</table>


```dart

  //...
    allDayEventsTheme: AllDayEventsTheme(
        listMaxRowsVisible: 1,
        eventMargin: const EdgeInsets.all(2),
        eventPadding: const EdgeInsets.all(2),
        borderRadius: 8,
        containerPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
        eventHeight: 32,
        textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _theme.secondaryHeaderColor,
        ),
    ),
  //...
```
The `AllDayEventsTheme` class provides a customizable theme for rendering all-day events in a day view. This theme allows you to control various aspects of the visual appearance of the all-day events.

**Properties**
* `showMoreButtonTheme`: An instance of AllDayEventsShowMoreButtonTheme that provides customization options for the "Show More" button.
* `listMaxRowsVisible`: Maximum number of rows to show for all-day events.
* `eventHeight`: Height of each individual all-day event.
* `textStyle`: Text style for the all-day events.
* `containerPadding`: Padding for the container of all-day events.
* `eventPadding`: Padding for each all-day event.
* `eventMargin`: Margin for each all-day event.
* `borderRadius`: Border radius for the all-day events.
* `elevation`: Elevation over a day view.
* `shape`: Shape and border of the views.
* `margin`: Padding between the views.

The `AllDayEventsShowMoreButtonTheme` class provides customization options for the "Show More" button, which is used when there are more all-day events than can be displayed.

**Properties**
* `height`: Height of the "Show More" button.
* `textStyle`: Text style for the "Show More" button.
* `backgroundColor`: Background color of the "Show More" button.
* `borderRadius`: Border radius for the "Show More" button.
* `padding`: Padding for the "Show More" button.
* `margin`: Margin for the "Show More" button.

You can also create a custom builder for `Show more` button.
In this case, you need to handle button clicks yourself.

<table>
    <tr>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/DaysViewCustomAllDayEventShowMoreButton.png?raw=true" width="250" title="Days View">
            <p>Days View</p>
        </th>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/WeekViewCustomAllDayEventShowMoreButton.png?raw=true" width="250" title="Week View">
            <p>Week View</p>
        </th>
    </tr>
</table>


```dart

 //...
  allDayEventsShowMoreBuilder: _getCustomAllDayEventsShowMoreBuilder,
 //...

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


```


There are two callbacks that allow you to handle all-day events: `onAllDayEventTap` and `onAllDayEventsShowMoreTap`

```dart

  //...
  onAllDayEventTap: (event) {
    //...
  },
  onAllDayEventsShowMoreTap: (visibleEvents, allEvents) {
    //...
  },
  //...

```

---

### Custom events

The package supports custom events. To create a custom event, you need to extend the `EditableCalendarEvent` class. The following code snippet demonstrates how to create a custom event with image background:

```dart

class ImageCalendarEvent extends EditableCalendarEvent {
  ImageCalendarEvent(
      {required super.id,
      required super.start,
      required super.duration,
      required super.color,
      required this.title,
      required this.imgAsset});

  final String title;
  final String imgAsset;

  @override
  EditableCalendarEvent copyWith({DateTime? start, Duration? duration}) {
    return ImageCalendarEvent(
        id: id,
        start: start ?? this.start,
        duration: duration ?? this.duration,
        color: color,
        title: title,
        imgAsset: imgAsset);
  }
}

```

Then you just need create a custom builder for your event:

<table>
    <tr>
        <th>
            <img src="https://github.com/Radency/flutter_customizable_calendar/blob/main/doc/assets/DaysViewCustomImageCalendarEvent.png?raw=true" width="250" title="Days View">
            <p>Days View</p>
        </th>
    </tr>
</table>

```dart

  //...
  eventBuilders: _getEventBuilders(),
  //...
  
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

  //...

```
---

### Custom long press actions

You can override the default long-press actions for each view. The following code snippet demonstrates how to override the default long-press `overrideOnEventLongPress` callback. This can be also used if you don't need editor functionality.

```dart

//...
    overrideOnEventLongPress: (details, event) {
        print(event);
    },
//...

```


[See the complete example](https://github.com/Radency/flutter_customizable_calendar/blob/main/example/lib/main.dart).
