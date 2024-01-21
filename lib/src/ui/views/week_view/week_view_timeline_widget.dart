import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class WeekViewTimelineWidget extends StatefulWidget {
  const WeekViewTimelineWidget({
    required this.scrollTo,
    required this.controller,
    required this.timelineKey,
    required this.theme,
    required this.days,
    required this.initialScrollOffset,
    required this.buildChild,
    super.key,
  });

  final List<DateTime> days;
  final double initialScrollOffset;
  final void Function(double) scrollTo;
  final GlobalKey timelineKey;
  final TimelineTheme theme;
  final WeekViewController controller;
  final Widget Function(DateTime dayTime) buildChild;

  @override
  State<WeekViewTimelineWidget> createState() => _WeekViewTimelineWidgetState();
}

class _WeekViewTimelineWidgetState extends State<WeekViewTimelineWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );

    _scrollController.addListener(() {
      widget.scrollTo(_scrollController.offset);
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: widget.timelineKey,
      controller: _scrollController,
      child: Container(
        color: Colors.transparent,
        height: 2400,
        child: Row(
          children: [
            ...widget.days.map(widget.buildChild),
          ],
        ),
      ),
    );
  }
}
