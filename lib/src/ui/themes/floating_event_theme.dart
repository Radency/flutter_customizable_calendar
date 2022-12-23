import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class FloatingEventTheme extends Equatable {
  const FloatingEventTheme({
    this.elevation,
    double? elevationWhenElevated,
    this.shape,
    this.margin,
  }) : elevationWhenElevated = elevationWhenElevated ?? elevation;

  final double? elevation;

  final double? elevationWhenElevated;

  final ShapeBorder? shape;

  final EdgeInsetsGeometry? margin;

  @override
  List<Object?> get props => [
        elevation,
        elevationWhenElevated,
        shape,
        margin,
      ];

  FloatingEventTheme copyWith({
    double? elevation,
    double? elevationWhenElevated,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
  }) {
    return FloatingEventTheme(
      elevation: elevation ?? this.elevation,
      elevationWhenElevated:
          elevationWhenElevated ?? this.elevationWhenElevated,
      shape: shape ?? this.shape,
      margin: margin ?? this.margin,
    );
  }
}
