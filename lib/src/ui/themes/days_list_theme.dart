import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';
import 'package:intl/intl.dart';

part 'days_list_item_theme.dart';

/// Wrapper for the DaysList view customization parameters
class DaysListTheme extends Equatable {
  /// Customize the DaysList with the parameters
  const DaysListTheme({
    this.height = 80,
    this.physics,
    this.itemExtent = 56,
    this.itemTheme = const DaysListItemTheme(),
  });

  /// The list height
  final double height;

  /// How the page view should respond to user input
  final ScrollPhysics? physics;

  /// The list item extent
  final double itemExtent;

  /// Theme of the list item
  final DaysListItemTheme itemTheme;

  @override
  List<Object?> get props => [
        height,
        physics,
        itemExtent,
        itemTheme,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  DaysListTheme copyWith({
    double? height,
    ScrollPhysics? physics,
    double? itemExtent,
    DaysListItemTheme? itemTheme,
  }) {
    return DaysListTheme(
      height: height ?? this.height,
      physics: physics ?? this.physics,
      itemExtent: itemExtent ?? this.itemExtent,
      itemTheme: itemTheme ?? this.itemTheme,
    );
  }
}
