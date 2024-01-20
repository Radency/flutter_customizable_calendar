import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class WeekViewTimelineWidget extends StatefulWidget {
  const WeekViewTimelineWidget({
    required this.scrollTo,
    required this.controller,
    required this.timelineKey,
    required this.theme,
    required this.height,
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
  final double height;
  final Widget Function(DateTime dayTime) buildChild;

  @override
  State<WeekViewTimelineWidget> createState() => _WeekViewTimelineWidgetState();
}

class _WeekViewTimelineWidgetState extends State<WeekViewTimelineWidget> {
  late final ScrollController _timelineController;

  bool _initialized = false;

  @override
  void initState() {

    _timelineController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );

    _timelineController.addListener(() {
      if (!_initialized) {
        _timelineController.jumpTo(widget.initialScrollOffset);
        _initialized = true;
      } else {
        widget.scrollTo(_timelineController.offset);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _timelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: widget.timelineKey,
      controller: _timelineController,
      child: SizedBox(
        height: widget.height,
        child: Row(
          children: [
            ...widget.days.map(widget.buildChild),
          ],
        ),
      ),
    );
  }
}
