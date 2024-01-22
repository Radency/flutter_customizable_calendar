import 'package:flutter/material.dart';

/// Wrapper for the ShowMore button customization parameters
class MonthShowMoreTheme {
  /// Customize the ShowMore button with the parameters
  const MonthShowMoreTheme({
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
    this.backgroundColor = const Color(0xFFD1D1D1),
    this.borderRadius = 4,
    this.padding = const EdgeInsets.symmetric(
      vertical: 2,
      horizontal: 2,
    ),
    this.height = 24,
    this.eventHeight = 28,
  });

  /// Height of the show more button
  final double height;

  /// Height of the event
  final double eventHeight;

  /// TextStyle of the show more button
  final TextStyle textStyle;

  /// Background color of the show more button
  final Color backgroundColor;

  /// Border radius of the show more button
  final double borderRadius;

  /// Padding of the show more button
  final EdgeInsetsGeometry padding;

  MonthShowMoreTheme copyWith({
    double? height,
    TextStyle? textStyle,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return MonthShowMoreTheme(
      height: height ?? this.height,
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }
}
