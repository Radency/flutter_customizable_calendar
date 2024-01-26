import 'package:flutter/material.dart';

/// A widget which allow to create a custom Widget for [SaverConfig]
class Saver extends StatelessWidget {

  /// Creates a [Saver] widget
  const Saver({
    required this.onPressed,
    required this.child,
    super.key,
    this.alignment = Alignment.bottomRight,
  });

  /// The child widget
  final Widget child;

  /// The on pressed callback
  final void Function() onPressed;

  /// The [Alignment] alignment
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    );
  }
}

class SaverConfig {
  const SaverConfig({
    required this.child,
    this.alignment = Alignment.bottomRight,
  });

  factory SaverConfig.def() {
    return SaverConfig(
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(15),
        child: const Icon(Icons.done),
      ),
    );
  }

  final Widget child;
  final Alignment alignment;
}
