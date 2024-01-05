import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class WidgetSize extends StatefulWidget {
  const WidgetSize({required this.onChange, required this.child, super.key});

  final Widget child;
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
