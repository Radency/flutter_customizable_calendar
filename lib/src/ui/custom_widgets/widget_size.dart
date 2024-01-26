import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A widget which allow to listen to the size changes of the child widget
///
/// Note: Needs to be replaced later with better solution
/// as it's not a good practice to use
/// [SchedulerBinding.instance.addPostFrameCallback] in the build method.
/// So every place in code where this widget is used needs to be refactored
class WidgetSize extends StatefulWidget {
  /// Creates a [WidgetSize] widget
  const WidgetSize({
    required this.onChange,
    required this.child,
    super.key,
  });

  /// The child widget
  final Widget child;

  /// The on change callback
  final void Function(Size? newSize) onChange;

  @override
  State<WidgetSize> createState() => _WidgetSizeState();
}

class _WidgetSizeState extends State<WidgetSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(_postFrameCallback);
    return Container(
      key: _widgetKey,
      child: widget.child,
    );
  }

  final _widgetKey = GlobalKey(debugLabel: 'dynamic-widget');
  Size? _oldSize;

  void _postFrameCallback(_) {
    try {
      final context = _widgetKey.currentContext;
      if (context == null) return;

      final newSize = context.size;
      if (_oldSize == newSize) return;

      _oldSize = newSize;
      widget.onChange(newSize);
    } on Exception {
      // ignore
    }
  }
}
