import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';

class BreakView extends StatelessWidget {
  const BreakView(
    this.event, {
    super.key,
    this.strokeWidth = 5,
    this.child,
  });

  final Break event;
  final double strokeWidth;
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
