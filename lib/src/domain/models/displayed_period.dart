import 'package:equatable/equatable.dart';

/// Wrapper which joins two [DateTime] values
class DisplayedPeriod extends Equatable {
  /// Set a [DateTime] value or a date range which needs to be displayed
  const DisplayedPeriod(this.begin, [this.end]);

  /// Period [begin] date. Use only this value if you need
  /// to show a specific date (like a specific month).
  final DateTime begin;

  /// Period [end] date (optional). Use this value
  /// to set displayed period range.
  final DateTime? end;

  @override
  List<Object?> get props => [begin, end];
}
