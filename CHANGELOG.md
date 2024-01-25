## 0.0.1

* Initial release.

## 0.1.0

- Added:
    * More tests.
    * More documentation.
    * More examples.

## 0.1.1

* Fix linter warnings.
* Fix `README` images links.

## 0.1.3


* Fix `README` images links.

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

## 0.2.1

* Fix linter warnings.

## 0.3.0

- Added

  * Introduced new examples showcasing package usage, combining multiple views:
    * MonthView with ScheduleListView
    * ScheduleListView with DaysView
    * WeekView (optimized for portrait mode with 3 days)
  * Implemented additional custom builders for MonthView, WeekView, and DaysView. See new examples and updated README.md for more details.

- Fixed

  * Addressed issue where WeekView event jumps to the next day upon dragging to the day's end.
  * Fixed the issue when the WeekView event does not drag to the next/previous week correctly.
  * Applied similar fixes to MonthView for consistency with WeekView.

## 0.3.1

- Fixed 
  * Incorrect autoscroll behavior in MonthView and WeekView.

## 0.3.2

- Improved Test Code Coverage
- Fixed:
  * Custom event builders did not work for all-day events.
  * Added `BuildContext` in some builder methods where it was missing.