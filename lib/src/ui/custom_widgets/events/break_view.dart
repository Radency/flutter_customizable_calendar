import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';

/// A widget which allows to display a [Break] event
class BreakView extends StatelessWidget {
  /// Creates a [BreakView] widget
  const BreakView(
    this.event, {
    super.key,
    this.strokeWidth = 5,
    this.child,
  });

  /// The [Break] event to display
  final Break event;

  /// The stroke width
  final double strokeWidth;

  /// The child widget
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HatchingPainter(
        color: event.color,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _HatchingPainter extends CustomPainter {
  const _HatchingPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final linePainter = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    final dxOffset = strokeWidth * 1.4142;
    final end = size.width + size.height; // It needs to fill the whole area
    final height = size.height + strokeWidth; // It needs to cut a line end

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (var dx = 0.0; dx < end; dx += dxOffset * 2) {
      canvas.drawLine(
        Offset(dx + strokeWidth, -strokeWidth),
        Offset(dx - height, height),
        linePainter,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HatchingPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
