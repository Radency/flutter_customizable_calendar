import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/themes.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

/// The view is shown to the left of it's [child] widget.
/// It displays a time scale of a day view (with hours and minutes marks).
class TimeScale extends StatefulWidget {
  /// Creates view of a time scale.
  const TimeScale({
    super.key,
    this.showCurrentTimeMark = true,
    this.theme = const TimeScaleTheme(),
    required this.child,
  });

  /// Whether current time mark needs to be shown
  final bool showCurrentTimeMark;

  /// Customization params for the view
  final TimeScaleTheme theme;

  /// A day view widget
  final Widget child;

  @override
  State<TimeScale> createState() => _TimeScaleState();
}

class _TimeScaleState extends State<TimeScale> {
  final _clock = ClockNotifier.instance();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomPaint(
          size: Size.fromWidth(widget.theme.width),
          painter: _scale,
          foregroundPainter:
              widget.showCurrentTimeMark ? _currentTimeMark : null,
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  CustomPainter get _scale => _ScalePainter(
        dayDate: _clock.value,
        theme: widget.theme,
      );

  CustomPainter get _currentTimeMark => _CurrentTimeMarkPainter(
        currentTime: _clock,
        theme: widget.theme.currentTimeMarkTheme,
      );
}

class _ScalePainter extends CustomPainter {
  const _ScalePainter({
    required this.dayDate,
    required this.theme,
  });

  final DateTime dayDate;

  final TimeScaleTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final hourExtent = size.height / Duration.hoursPerDay;
    final quarterHeight = hourExtent / 4;

    for (var hour = 0; hour < Duration.hoursPerDay; hour++) {
      final time = DateTime(dayDate.year, dayDate.month, dayDate.day, hour);
      final hourTextPainter = TextPainter(
        text: TextSpan(
          text: theme.hourFormatter.call(time),
          style: theme.textStyle,
        ),
        textAlign: _textAlign,
        textDirection: TextDirection.ltr,
      );
      final hourOffset = hourExtent * hour;

      // Draw an hour text
      hourTextPainter
        ..layout(
          minWidth: size.width,
          maxWidth: size.width,
        )
        ..paint(
          canvas,
          Offset(-1, hourOffset - hourTextPainter.height / 2),
        );

      if (theme.drawHalfHourMarks) {
        final line = theme.halfHourMarkTheme;
        final dx = _calculateLineDx(size.width, line.length);
        final dy = hourOffset + quarterHeight * 2 - line.strokeWidth / 2;

        canvas.drawLine(
          Offset(dx, dy),
          Offset(dx + line.length, dy),
          line.painter,
        );
      }

      if (theme.drawQuarterHourMarks) {
        final line = theme.quarterHourMarkTheme;
        final dx = _calculateLineDx(size.width, line.length);
        final dy1 = hourOffset + quarterHeight - line.strokeWidth / 2;
        final dy2 = hourOffset + quarterHeight * 3 - line.strokeWidth / 2;

        canvas
          ..drawLine(
            Offset(dx, dy1),
            Offset(dx + line.length, dy1),
            line.painter,
          )
          ..drawLine(
            Offset(dx, dy2),
            Offset(dx + line.length, dy2),
            line.painter,
          );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScalePainter oldDelegate) =>
      theme != oldDelegate.theme || dayDate != oldDelegate.dayDate;

  TextAlign get _textAlign {
    switch (theme.marksAlign) {
      case MarksAlign.center:
        return TextAlign.center;
      case MarksAlign.left:
        return TextAlign.left;
      case MarksAlign.right:
        return TextAlign.right;
    }
  }

  double _calculateLineDx(double canvasWidth, double lineLength) {
    switch (theme.marksAlign) {
      case MarksAlign.center:
        return (canvasWidth - lineLength) / 2;
      case MarksAlign.left:
        return 0;
      case MarksAlign.right:
        return canvasWidth - lineLength;
    }
  }
}

class _CurrentTimeMarkPainter extends CustomPainter {
  const _CurrentTimeMarkPainter({
    required this.currentTime,
    required this.theme,
  }) : super(repaint: currentTime);

  final ValueListenable<DateTime> currentTime;

  final TimeMarkTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final secondExtent = size.height / Duration.secondsPerDay;
    final dayDate = DateUtils.dateOnly(currentTime.value);
    final timeDiff = currentTime.value.difference(dayDate);
    final currentTimeOffset = timeDiff.inSeconds * secondExtent;
    final dy = currentTimeOffset - theme.strokeWidth / 2;

    canvas.drawLine(
      Offset(0, dy),
      Offset(theme.length, dy),
      theme.painter,
    );
  }

  @override
  bool shouldRepaint(covariant _CurrentTimeMarkPainter oldDelegate) =>
      theme != oldDelegate.theme || currentTime != oldDelegate.currentTime;
}
