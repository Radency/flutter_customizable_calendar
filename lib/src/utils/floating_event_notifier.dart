import 'package:flutter/foundation.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';

/// This class duplicates functionality of default ValueNotifier but allows
/// to update [value] anytime and notifies its listeners only if it's needed.
/// It needs optimize an amount of UI rebuilds.
class FloatingEventNotifier<T extends FloatingCalendarEvent>
    extends ChangeNotifier implements ValueListenable<T?> {
  /// Creates a [FloatingEventNotifier] instance
  FloatingEventNotifier([this._value]);

  T? _value;

  @override
  T? get value => _value;
  set value(T? newValue) {
    final oldValue = _value;
    _value = newValue;
    if (oldValue != newValue) notifyListeners();
  }
}
