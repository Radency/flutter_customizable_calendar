import 'package:flutter/material.dart';

/// Wrapper for the ShowMore button customization parameters
class AllDayEventsShowMoreButtonTheme {
  /// Customize the ShowMore button with the parameters
  const AllDayEventsShowMoreButtonTheme({
    this.height = 24,
    this.backgroundColor = const Color(0xFFD1D1D1),
    this.borderRadius = 4,
    this.padding = EdgeInsets.zero,
    this.textStyle,
    this.margin = const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  });

  /// Height of the show more button
  final double height;

  /// TextStyle of the show more button
  final TextStyle? textStyle;

  /// Background color of the show more button
  final Color backgroundColor;

  /// Border radius of the show more button
  final double borderRadius;

  /// Padding of the show more button
  final EdgeInsetsGeometry padding;

  /// Margin of the show more button
  final EdgeInsetsGeometry margin;

  /// Creates a copy of this theme but with the given fields replaced with the
  /// new values
  AllDayEventsShowMoreButtonTheme copyWith({
    double? height,
    TextStyle? textStyle,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return AllDayEventsShowMoreButtonTheme(
      height: height ?? this.height,
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }
}
