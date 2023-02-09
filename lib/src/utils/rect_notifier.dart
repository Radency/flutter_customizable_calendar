import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// This wrapper needs to update [Rect] parameters more flexibly.
class RectNotifier extends ChangeNotifier implements ValueListenable<Rect> {
  /// Use [RectNotifier] to update [Rect] parameters more flexibly.
  RectNotifier({
    Offset origin = Offset.zero,
    Size size = Size.zero,
  })  : _origin = origin,
        _size = size;

  Offset _origin;
  Size _size;

  @override
  Rect get value => _origin & _size;
  set value(Rect newValue) {
    if (value == newValue) return;
    _origin = newValue.topLeft;
    _size = newValue.size;
    notifyListeners();
  }

  /// Rect [origin] coordinates
  Offset get origin => _origin;
  set origin(Offset newValue) {
    if (origin == newValue) return;
    _origin = newValue;
    notifyListeners();
  }

  /// Rect [size]
  Size get size => _size;
  set size(Size newValue) {
    if (size == newValue) return;
    _size = newValue;
    notifyListeners();
  }

  /// Rect [dx] coordinate
  double get dx => _origin.dx;
  set dx(double newValue) {
    if (dx == newValue) return;
    _origin = Offset(newValue, dy);
    notifyListeners();
  }

  /// Rect [dy] coordinate
  double get dy => _origin.dy;
  set dy(double newValue) {
    if (dy == newValue) return;
    _origin = Offset(dx, newValue);
    notifyListeners();
  }

  /// Rect [width]
  double get width => _size.width;
  set width(double newValue) {
    if (width == newValue) return;
    _size = Size(newValue, height);
    notifyListeners();
  }

  /// Rect [height]
  double get height => _size.height;
  set height(double newValue) {
    if (height == newValue) return;
    _size = Size(width, newValue);
    notifyListeners();
  }

  /// Needs to update a few values.
  /// Use this method to decrease [notifyListeners] calls count.
  void update({
    double? dx,
    double? dy,
    double? width,
    double? height,
  }) {
    value = Rect.fromLTWH(
      dx ?? this.dx,
      dy ?? this.dy,
      width ?? this.width,
      height ?? this.height,
    );
  }
}
