/// This is a wrapper for the values which all CalendarViewControllers
/// must have implemented.
mixin CalendarController {
  /// Calendar initial date
  DateTime get initialDate;

  /// If the [endDate] is omitted calendar is infinite
  DateTime? get endDate;

  /// Discards any resources used by the controller
  void dispose();

  /// Returns the view to current time point
  void reset();

  /// Switches the view to display the previous period
  void prev();

  /// Switches the view to display the next period
  void next();
}
