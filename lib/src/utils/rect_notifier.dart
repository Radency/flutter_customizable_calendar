import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class RectNotifier extends ChangeNotifier implements ValueListenable<Rect> {
  RectNotifier({
    Offset origin = Offset.zero,
    Size size = Size.zero,
  })  : _origin = origin,
        _size = size;

  Offset _origin;
  Size _size;

  Offset get origin => _origin;
  set origin(Offset newValue) {
    if (origin == newValue) return;
    _origin = newValue;
    notifyListeners();
  }

  Size get size => _size;
  set size(Size newValue) {
    if (size == newValue) return;
    _size = newValue;
    notifyListeners();
  }

  double get dx => _origin.dx;
  set dx(double newValue) {
    if (dx == newValue) return;
    _origin = Offset(newValue, dy);
    notifyListeners();
  }

  double get dy => _origin.dy;
  set dy(double newValue) {
    if (dy == newValue) return;
    _origin = Offset(dx, newValue);
    notifyListeners();
  }

  double get width => _size.width;
  set width(double newValue) {
    if (width == newValue) return;
    _size = Size(newValue, height);
    notifyListeners();
  }

  double get height => _size.height;
  set height(double newValue) {
    if (height == newValue) return;
    _size = Size(width, newValue);
    notifyListeners();
  }

  @override
  Rect get value => _origin & _size;
  set value(Rect newValue) {
    if (value == newValue) return;
    _origin = newValue.topLeft;
    _size = newValue.size;
    notifyListeners();
  }
}
