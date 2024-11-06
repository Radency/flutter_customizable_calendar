## 0.3.6

- Fixed:
  - **ScheduleListView** state points to incorrect date when changing days while scrolling.
  - **MonthView** grid has an incorrect row height in collapsed mode.
  - **MonthView** grid does not synchronize position correctly when switching between expanded/collapsed modes after scrolling
## 0.3.5

- Added option to change the number of day rows visible in **MonthView**. Defaults to 6 rows.
  Constrained to 5 - 9 rows.

## 0.3.4

- Fixed issues related to the support of Dart SDK 3.0.0 and higher.

## 0.3.3

- Improved Test Code Coverage
- Updated in-code docs.

## 0.3.2

- Improved Test Code Coverage
- Added
    * Added an option to disable floating events so that the event will be saved once the user
      releases the tap.
- Fixed:
    * Custom event builders did not work for all-day events.
    * Added `BuildContext` in some builder methods where it was missing.

## 0.3.1

- Fixed
    * Incorrect autoscroll behavior in MonthView and WeekView.

## 0.3.0

- Added

    * Introduced new examples showcasing package usage, combining multiple views:
        * MonthView with ScheduleListView
        * ScheduleListView with DaysView
        * WeekView (optimized for portrait mode with 3 days)
    * Implemented additional custom builders for MonthView, WeekView, and DaysView. See new examples
      and updated README.md for more details.

- Fixed

    * Addressed issue where WeekView event jumps to the next day upon dragging to the day's end.
    * Fixed the issue when the WeekView event does not drag to the next/previous week correctly.
    * Applied similar fixes to MonthView for consistency with WeekView.

## 0.2.1

* Fix linter warnings.

## 0.2.0

- Added
    * An option to override the `onEventLongPress` handler.
    * All-day events for `DaysView`.
    * All-day events for `WeekView`.

- Fixed
    * Events list is not getting updated after saving an event using `LongPressActionSheet`.
    * `MonthView` layout changes abruptly when switching months.
    * `WeekView` layout changes abruptly when switching weeks.
    * `PageView.builder` resets to initialPosition when interacting with `OverlayEntry`

## 0.1.3

* Fix `README` images links.

## 0.1.1

* Fix linter warnings.
* Fix `README` images links.

## 0.1.0

- Added:
    * More tests.
    * More documentation.
    * More examples.

## 0.0.1

* Initial release.

