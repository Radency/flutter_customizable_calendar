import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';

/// This wrapper needs to update [Rect] parameters more flexibly.
class MultiRectNotifier extends ChangeNotifier implements ValueListenable<List<Rect>> {
  /// Use [RectNotifier] to update [Rect] parameters more flexibly.
  MultiRectNotifier({
    List<Rect> rects = const []
  })  : _rects = rects;

  List<Rect> _rects;

  @override
  List<Rect> get value => _rects;
  set value(List<Rect> newValue) {
    // if (value.equals(newValue)) return;
    _rects = [...newValue];
    notifyListeners();
  }

  /// Needs to update a few values.
  /// Use this method to decrease [notifyListeners] calls count.
  // void update({
  //   double? dx,
  //   double? dy,
  //   double? width,
  //   double? height,
  // }) {
  //   value = Rect.fromLTWH(
  //     dx ?? this.dx,
  //     dy ?? this.dy,
  //     width ?? this.width,
  //     height ?? this.height,
  //   );
  // }
}
