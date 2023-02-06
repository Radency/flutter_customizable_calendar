part of 'timeline_theme.dart';

/// Wrapper for the floating events views customization parameters
class FloatingEventsTheme extends Equatable {
  /// Customize the floating events views with the parameters
  const FloatingEventsTheme({
    this.elevation,
    this.shape,
    this.margin,
  });

  /// Elevation over a day view
  final double? elevation;

  /// Shape and border of the views
  final ShapeBorder? shape;

  /// Paddings between the views
  final EdgeInsetsGeometry? margin;

  @override
  List<Object?> get props => [
        elevation,
        shape,
        margin,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  FloatingEventsTheme copyWith({
    double? elevation,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
  }) {
    return FloatingEventsTheme(
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
      margin: margin ?? this.margin,
    );
  }
}
