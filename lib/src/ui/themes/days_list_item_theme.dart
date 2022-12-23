part of 'days_list_theme.dart';

String _defaultNumberFormatter(DateTime dayDate) =>
    DateFormat.d().format(dayDate);

String _defaultWeekdayFormatter(DateTime dayDate) =>
    DateFormat.E().format(dayDate).capitalized();

/// Wrapper for the DaysList item view customization parameters
class DaysListItemTheme extends Equatable {
  /// Customize the DaysList item with the parameters
  const DaysListItemTheme({
    this.margin = const EdgeInsets.symmetric(horizontal: 2),
    this.elevation,
    this.background = Colors.white,
    Color? backgroundFocused,
    this.foreground = Colors.blue,
    Color? foregroundFocused,
    this.shape,
    ShapeBorder? shapeFocused,
    this.numberFormatter = _defaultNumberFormatter,
    this.numberStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    TextStyle? numberStyleFocused,
    this.hideWeekday = false,
    this.weekdayFormatter = _defaultWeekdayFormatter,
    this.weekdayStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    TextStyle? weekdayStyleFocused,
  })  : backgroundFocused = backgroundFocused ?? foreground,
        foregroundFocused = foregroundFocused ?? background,
        shapeFocused = shapeFocused ?? shape,
        numberStyleFocused = numberStyleFocused ?? numberStyle,
        weekdayStyleFocused = weekdayStyleFocused ?? weekdayStyle;

  /// The list item external padding
  final EdgeInsetsGeometry margin;

  /// The z-coordinate at which to place the event view
  final double? elevation;

  /// Background color
  final Color background;

  /// Background color if the item is focused.
  /// If null [foreground] color is used.
  final Color backgroundFocused;

  /// Foreground color (is used to set a text color)
  final Color foreground;

  /// Foreground color if the item is focused.
  /// If null [background] color is used.
  final Color foregroundFocused;

  /// Shape and border of the item
  final ShapeBorder? shape;

  /// Shape and border if the item is focused
  final ShapeBorder? shapeFocused;

  /// Number string formatter
  final DateFormatter numberFormatter;

  /// Number text style
  final TextStyle numberStyle;

  /// Number text style if the item is focused
  final TextStyle numberStyleFocused;

  /// Whether weekday is need to show
  final bool hideWeekday;

  /// Weekday string formatter
  final DateFormatter weekdayFormatter;

  /// Weekday text style
  final TextStyle weekdayStyle;

  /// Weekday text style if the item is focused
  final TextStyle weekdayStyleFocused;

  @override
  List<Object?> get props => [
        margin,
        elevation,
        background,
        backgroundFocused,
        foreground,
        foregroundFocused,
        shape,
        shapeFocused,
        numberFormatter,
        numberStyle,
        numberStyleFocused,
        hideWeekday,
        weekdayFormatter,
        weekdayStyle,
        weekdayStyleFocused,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  DaysListItemTheme copyWith({
    EdgeInsetsGeometry? margin,
    double? elevation,
    Color? background,
    Color? backgroundFocused,
    Color? foreground,
    Color? foregroundFocused,
    ShapeBorder? shape,
    ShapeBorder? shapeFocused,
    DateFormatter? numberFormatter,
    TextStyle? numberStyle,
    TextStyle? numberStyleFocused,
    bool? hideWeekday,
    DateFormatter? weekdayFormatter,
    TextStyle? weekdayStyle,
    TextStyle? weekdayStyleFocused,
  }) {
    return DaysListItemTheme(
      margin: margin ?? this.margin,
      elevation: elevation ?? this.elevation,
      background: background ?? this.background,
      backgroundFocused: backgroundFocused ?? this.backgroundFocused,
      foreground: foreground ?? this.foreground,
      foregroundFocused: foregroundFocused ?? this.foregroundFocused,
      shape: shape ?? this.shape,
      shapeFocused: shapeFocused ?? this.shapeFocused,
      numberFormatter: numberFormatter ?? this.numberFormatter,
      numberStyle: numberStyle ?? this.numberStyle,
      numberStyleFocused: numberStyleFocused ?? this.numberStyleFocused,
      hideWeekday: hideWeekday ?? this.hideWeekday,
      weekdayFormatter: weekdayFormatter ?? this.weekdayFormatter,
      weekdayStyle: weekdayStyle ?? this.weekdayStyle,
      weekdayStyleFocused: weekdayStyleFocused ?? this.weekdayStyleFocused,
    );
  }
}
