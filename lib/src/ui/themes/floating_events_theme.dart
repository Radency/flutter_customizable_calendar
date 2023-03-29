part of 'timeline_theme.dart';

/// Wrapper for the floating events views customization parameters
class FloatingEventsTheme extends Equatable {
  /// Customize the floating events views with the parameters
  const FloatingEventsTheme({
    this.elevation,
    this.shape,
    this.margin,
    this.dayTheme = const ViewEventTheme(),
    this.weekTheme = const ViewEventTheme(),
    this.monthTheme = const ViewEventTheme(),
  });

  /// Elevation over a day view
  final double? elevation;

  /// Shape and border of the views
  final ShapeBorder? shape;

  /// Paddings between the views
  final EdgeInsetsGeometry? margin;

  final ViewEventTheme dayTheme;
  final ViewEventTheme weekTheme;
  final ViewEventTheme monthTheme;

  @override
  List<Object?> get props => [
    elevation,
    shape,
    margin,
    dayTheme,
    weekTheme,
    monthTheme,
  ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  FloatingEventsTheme copyWith({
    double? elevation,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    ViewEventTheme? dayTheme,
    ViewEventTheme? weekTheme,
    ViewEventTheme? monthTheme,
  }) {
    return FloatingEventsTheme(
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
      margin: margin ?? this.margin,
      dayTheme: dayTheme ?? this.dayTheme,
      weekTheme: weekTheme ?? this.weekTheme,
      monthTheme: monthTheme ?? this.monthTheme,
    );
  }
}

class ViewEventTheme extends Equatable {
  const ViewEventTheme({this.titleStyle = const TextStyle()});

  final TextStyle titleStyle;

  @override
  List<Object?> get props => [titleStyle];
}
