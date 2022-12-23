import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// Helper class which is needed to update the UI periodically.
class Clock extends ChangeNotifier implements ValueListenable<DateTime> {
  Clock._create() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );
  }

  /// Creates a [ValueNotifier] which provides current time and notifies it's
  /// listeners every second. Don't forget to [dispose] it.
  factory Clock.instance() {
    if (_counter == 0) _instance = Clock._create();
    _counter++;
    return _instance;
  }

  static late Clock _instance;
  static var _counter = 0;
  Timer? _timer;

  /// Returns a system [DateTime] value
  @override
  DateTime get value => clock.now();

  /// Discard any resources used by the object
  @override
  void dispose() {
    _counter--;
    if (_counter > 0) return; // If the ticker is still used somewhere
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
