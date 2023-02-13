part of 'timeline_theme.dart';

/// Wrapper for the draggable event view customization parameters
class DraggableEventTheme extends Equatable {
  /// Customize the draggable event view with the parameters
  const DraggableEventTheme({
    this.elevation,
    this.sizerTheme = const SizerTheme(),
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.fastOutSlowIn,
  });

  /// Elevation over a day view
  final double? elevation;

  /// Sizer view's customization parameters
  final SizerTheme sizerTheme;

  /// Duration of the view's animation
  final Duration animationDuration;

  /// Allows to change the animation's behavior
  /// (use a [Curve] which supports changing a value between [0...1])
  final Curve animationCurve;

  @override
  List<Object?> get props => [
        elevation,
        sizerTheme,
        animationDuration,
        animationCurve,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  DraggableEventTheme copyWith({
    double? elevation,
    SizerTheme? sizerTheme,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return DraggableEventTheme(
      elevation: elevation ?? this.elevation,
      sizerTheme: sizerTheme ?? this.sizerTheme,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }
}
