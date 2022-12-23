part of 'timeline_theme.dart';

/// How marks on the time scale should be aligned
enum MarksAlign {
  center,
  left,
  right,
}

String _defaultHourFormatter(DateTime value) => DateFormat.Hm().format(value);

/// Wrapper for the TimeScale view customization parameters
class TimeScaleTheme extends Equatable {
  /// Customize the TimeScale with the parameters
  const TimeScaleTheme({
    this.width = 56,
    this.hourExtent = 100,
    this.currentTimeMarkTheme = const TimeMarkTheme(
      length: 48,
      color: Colors.red,
    ),
    this.drawHalfHourMarks = true,
    this.halfHourMarkTheme = const TimeMarkTheme(length: 16),
    this.drawQuarterHourMarks = true,
    this.quarterHourMarkTheme = const TimeMarkTheme(length: 8),
    this.hourFormatter = _defaultHourFormatter,
    this.textStyle,
    this.marksAlign = MarksAlign.left,
  });

  /// Width of the view (is needed to set a padding)
  final double width;

  /// Distance between two hours
  final double hourExtent;

  /// Current time mark customization parameters
  final TimeMarkTheme currentTimeMarkTheme;

  /// Whether a half of an hour mark is need to show
  final bool drawHalfHourMarks;

  /// A half of an hour mark customization parameters
  final TimeMarkTheme halfHourMarkTheme;

  /// Whether a quarter of an hour mark is need to show
  final bool drawQuarterHourMarks;

  /// A quarter of an hour mark customization parameters
  final TimeMarkTheme quarterHourMarkTheme;

  /// Hour string formatter
  final DateFormatter hourFormatter;

  /// Hour text style
  final TextStyle? textStyle;

  /// Scale marks alignment
  final MarksAlign marksAlign;

  @override
  List<Object?> get props => [
        width,
        hourExtent,
        currentTimeMarkTheme,
        drawHalfHourMarks,
        halfHourMarkTheme,
        drawQuarterHourMarks,
        quarterHourMarkTheme,
        hourFormatter,
        textStyle,
        marksAlign,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  TimeScaleTheme copyWith({
    double? width,
    double? hourExtent,
    TimeMarkTheme? currentTimeMarkTheme,
    bool? drawHalfHourMarks,
    TimeMarkTheme? halfHourMarkTheme,
    bool? drawQuarterHourMarks,
    TimeMarkTheme? quarterHourMarkTheme,
    DateFormatter? hourFormatter,
    TextStyle? textStyle,
    MarksAlign? marksAlign,
  }) {
    return TimeScaleTheme(
      width: width ?? this.width,
      hourExtent: hourExtent ?? this.hourExtent,
      currentTimeMarkTheme: currentTimeMarkTheme ?? this.currentTimeMarkTheme,
      drawHalfHourMarks: drawHalfHourMarks ?? this.drawHalfHourMarks,
      halfHourMarkTheme: halfHourMarkTheme ?? this.halfHourMarkTheme,
      drawQuarterHourMarks: drawQuarterHourMarks ?? this.drawQuarterHourMarks,
      quarterHourMarkTheme: quarterHourMarkTheme ?? this.quarterHourMarkTheme,
      hourFormatter: hourFormatter ?? this.hourFormatter,
      textStyle: textStyle ?? this.textStyle,
      marksAlign: marksAlign ?? this.marksAlign,
    );
  }
}
