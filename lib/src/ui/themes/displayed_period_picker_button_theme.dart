part of 'displayed_period_picker_theme.dart';

/// Wrapper for the DisplayedPeriodPicker button view customization parameters
class DisplayedPeriodPickerButtonTheme extends Equatable {
  /// Customize the DisplayedPeriodPicker button with the parameters
  const DisplayedPeriodPickerButtonTheme({
    required this.child,
    this.color,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
  });

  /// Color of the button
  final Color? color;

  /// The amount of space to surround the icon inside the bounds of the button
  final EdgeInsetsGeometry padding;

  /// The radius of the button's corners when it has a background color
  final BorderRadius? borderRadius;

  /// The widget below this widget in the tree
  final Widget child;

  @override
  List<Object?> get props => [
        color,
        padding,
        borderRadius,
        child,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  DisplayedPeriodPickerButtonTheme copyWith({
    Color? color,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    Widget? child,
  }) {
    return DisplayedPeriodPickerButtonTheme(
      color: color ?? this.color,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      child: child ?? this.child,
    );
  }
}
