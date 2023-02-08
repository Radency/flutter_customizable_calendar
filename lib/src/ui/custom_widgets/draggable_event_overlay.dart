import 'dart:math';

import 'package:extra_hittest_area/extra_hittest_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/events/event_view.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/themes.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

/// A key holder of all DraggableEventView keys
@visibleForTesting
abstract class DraggableEventOverlayKeys {
  /// A key for the elevated (floating) event view
  static const elevatedEvent = ValueKey('elevatedEvent');
}

/// Wrapper which needs to wrap a scrollable [child] widget and display an
/// elevated event view over it.
class DraggableEventOverlay<T extends FloatingCalendarEvent>
    extends StatefulWidget {
  /// Creates an overlay for draggable event view over given [child] widget.
  const DraggableEventOverlay(
    this.event, {
    super.key,
    this.padding = EdgeInsets.zero,
    required this.timelineTheme,
    this.onDragDown,
    this.onDragUpdate,
    this.onDragEnd,
    this.onSizeUpdate,
    this.onResizingEnd,
    this.onDropped,
    required this.getTimelineBox,
    required this.getLayoutBox,
    required this.getEventBox,
    required this.child,
  });

  /// A notifier which needs to control elevated event
  final FloatingEventNotifier<T> event;

  /// Offset for the overlay
  final EdgeInsets padding;

  /// The timeline customization params
  final TimelineTheme timelineTheme;

  /// Is called just after user start to interact with the event view
  final void Function()? onDragDown;

  /// Is called during user drags the event view
  final void Function(DragUpdateDetails)? onDragUpdate;

  /// Is called just after user stops dragging the event view
  final void Function()? onDragEnd;

  /// Is called during user resizes the event view
  final void Function(DragUpdateDetails)? onSizeUpdate;

  /// Is called just after user stops resizing the event view
  final void Function()? onResizingEnd;

  /// Is called just after the event is dropped
  final void Function(T)? onDropped;

  /// Function which allows to find the timeline's [RenderBox] in context
  final RenderBox? Function() getTimelineBox;

  /// Function which allows to find the layout's [RenderBox] in context
  final RenderBox? Function(DateTime) getLayoutBox;

  /// Function which allows to find the event view's [RenderBox] in context
  final RenderBox? Function(T) getEventBox;

  /// Scrollable view which needs to be wrapped
  final Widget child;

  @override
  State<DraggableEventOverlay<T>> createState() =>
      _DraggableEventOverlayState<T>();
}

class _DraggableEventOverlayState<T extends FloatingCalendarEvent>
    extends State<DraggableEventOverlay<T>>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _overlayKey = GlobalKey<OverlayState>();
  final _layerLink = LayerLink();
  final _eventBounds = RectNotifier();
  late AnimationController _animationController;
  late Animation<double> _animation;
  late RectTween _boundsTween;
  late T _elevatedEvent;
  var _dragging = false;
  var _resizing = false;
  OverlayEntry? _eventEntry;
  OverlayEntry? _sizerEntry;

  OverlayState get _overlay => _overlayKey.currentState!;

  double get _minuteExtent => _hourExtent / Duration.minutesPerHour;
  double get _hourExtent => widget.timelineTheme.timeScaleTheme.hourExtent;

  int get _cellExtent => widget.timelineTheme.cellExtent;

  DraggableEventTheme get _draggableEventTheme =>
      widget.timelineTheme.draggableEventTheme;

  Rect _getEventBounds(T event) {
    final eventBox = widget.getEventBox(event);

    if (eventBox == null) return Rect.zero;

    final eventPosition = eventBox.localToGlobal(
      Offset.zero,
      ancestor: widget.getTimelineBox(),
    );

    return eventPosition & eventBox.size;
  }

  Rect _getExpandedEventBounds(T event) {
    final dayDate = DateUtils.dateOnly(event.start);
    final layoutBox = widget.getLayoutBox(dayDate)!;
    final layoutPosition = layoutBox.localToGlobal(
      Offset.zero,
      ancestor: widget.getTimelineBox(),
    );
    final eventBox = widget.getEventBox(event)!;
    final eventPosition = eventBox.localToGlobal(
      layoutPosition,
      ancestor: layoutBox,
    );

    return Rect.fromLTWH(
      layoutPosition.dx,
      eventPosition.dy,
      layoutBox.size.width,
      eventBox.size.height,
    );
  }

  void _resetElevatedEvent() {
    if (widget.event.value == null) return;
    _elevatedEvent = widget.event.value!;
    _elevate(_elevatedEvent);
  }

  void _animateBounds() =>
      _eventBounds.value = _boundsTween.transform(_animation.value)!;

  void _initAnimationController() => _animationController = AnimationController(
        duration: _draggableEventTheme.animationDuration,
        vsync: this,
      )..addListener(_animateBounds);

  void _initAnimation() => _animation = CurvedAnimation(
        parent: _animationController,
        curve: _draggableEventTheme.animationCurve,
      );

  void _elevate(T event) {
    if (_animationController.isAnimating) {
      _removeEntries();
      _animationController.reset();
    }

    _boundsTween = RectTween(
      begin: _getEventBounds(event),
      end: _getExpandedEventBounds(event),
    );
    _createEntriesFor(event);
    _animationController.forward();
  }

  void _drop(T event) {
    if (_animationController.isAnimating) _animationController.stop();

    _boundsTween = RectTween(
      end: _eventBounds.value,
      begin: _getEventBounds(event),
    );
    _animationController.reverse().whenComplete(() {
      widget.event.value = null;
      _removeEntries();
      widget.onDropped?.call(event);
    });
  }

  void _createEntriesFor(T event) {
    _eventEntry = OverlayEntry(builder: _floatingEventBuilder);
    _overlay.insert(_eventEntry!);

    // Non-editable event can't be resized
    if (event is EditableCalendarEvent) {
      _sizerEntry = OverlayEntry(builder: _sizerBuilder);
      _overlay.insert(_sizerEntry!);
    }
  }

  void _removeEntries() {
    _eventEntry?.remove();
    _eventEntry = null;
    _sizerEntry?.remove();
    _sizerEntry = null;
  }

  void _updateEventOrigin() {
    _elevatedEvent = widget.event.value!;

    final timelineBox = widget.getTimelineBox()!;
    final dayDate = DateUtils.dateOnly(_elevatedEvent.start);
    final layoutBox = widget.getLayoutBox(dayDate)!;
    final minutesFromDayStart = _elevatedEvent.start.minute +
        _elevatedEvent.start.hour * Duration.minutesPerHour;
    final offset = Offset(0, minutesFromDayStart * _minuteExtent);

    _eventBounds.origin =
        timelineBox.globalToLocal(layoutBox.localToGlobal(offset));
  }

  void _updateEventHeightAndDuration() {
    final dayDate = DateUtils.dateOnly(_elevatedEvent.start);
    final minutesFromDayStart = _elevatedEvent.start.minute +
        _elevatedEvent.start.hour * Duration.minutesPerHour +
        _eventBounds.height ~/ _minuteExtent;
    final roundedMinutes =
        (minutesFromDayStart / _cellExtent).round() * _cellExtent;
    final eventEndDate = dayDate.add(Duration(minutes: roundedMinutes));
    final eventDuration = eventEndDate.difference(_elevatedEvent.start);

    _eventBounds.height = eventDuration.inMinutes * _minuteExtent;
    _elevatedEvent = (_elevatedEvent as EditableCalendarEvent)
        .copyWith(duration: eventDuration) as T;

    widget.event.value = _elevatedEvent;
  }

  void _eventHeightLimiter() => _eventBounds.height =
      max(_eventBounds.height, _minuteExtent * _cellExtent);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.event.addListener(_resetElevatedEvent);
    _initAnimationController();
    _initAnimation();
    _eventBounds.addListener(_eventHeightLimiter);
  }

  @override
  void didUpdateWidget(covariant DraggableEventOverlay<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_draggableEventTheme != oldWidget.timelineTheme.draggableEventTheme) {
      _animationController.dispose();
      _initAnimationController();
      _initAnimation();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    if (_eventEntry == null) return;

    final dayDate = DateUtils.dateOnly(_elevatedEvent.start);
    final layoutBox = widget.getLayoutBox(dayDate);

    if (layoutBox == null) return;

    final layoutPosition = layoutBox.localToGlobal(
      Offset.zero,
      ancestor: widget.getTimelineBox(),
    );

    _eventBounds
      ..dx = layoutPosition.dx
      ..width = layoutBox.size.width;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.event,
      builder: (context, event, child) => GestureDetector(
        onTap: (event != null) ? () => _drop(event) : null,
        behavior: HitTestBehavior.translucent,
        child: child,
      ),
      child: Stack(
        children: [
          NotificationListener<ScrollUpdateNotification>(
            onNotification: (event) {
              final axis = event.metrics.axis;
              final scrollDelta = event.scrollDelta ?? 0;

              if (axis == Axis.vertical && scrollDelta != 0) {
                final delta = Offset(0, scrollDelta);

                if (!_dragging) {
                  _eventBounds.origin -= delta;
                  if (_resizing) _eventBounds.size += delta;
                }
              }

              return true;
            },
            child: widget.child,
          ),
          Positioned.fill(
            left: widget.padding.left,
            top: widget.padding.top,
            right: widget.padding.right,
            bottom: widget.padding.bottom,
            child: Overlay(key: _overlayKey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.event.removeListener(_resetElevatedEvent);
    _animationController.dispose();
    _eventBounds.dispose();
    super.dispose();
  }

  Widget _eventView() => EventView<T>(
        _elevatedEvent,
        key: DraggableEventOverlayKeys.elevatedEvent,
        theme: widget.timelineTheme.floatingEventsTheme.copyWith(
          elevation: _draggableEventTheme.elevation,
        ),
        onTap: () {},
      );

  Widget _sizerView() => DecoratedBox(
        decoration: BoxDecoration(
          color: _draggableEventTheme.sizerColor,
          shape: BoxShape.circle,
        ),
      );

  Widget _feedback() => Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          ValueListenableBuilder(
            valueListenable: _eventBounds,
            builder: (context, rect, child) => SizedBox.fromSize(
              size: rect.size,
              child: child,
            ),
            child: _eventView(),
          ),
          if (_sizerEntry != null)
            Positioned(
              bottom: -(_draggableEventTheme.sizerDimension / 2),
              width: _draggableEventTheme.sizerDimension,
              height: _draggableEventTheme.sizerDimension,
              child: _sizerView(),
            ),
        ],
      );

  Widget _floatingEventBuilder(BuildContext context) => ValueListenableBuilder(
        valueListenable: _eventBounds,
        builder: (context, rect, child) => Positioned.fromRect(
          rect: rect,
          child: child!,
        ),
        child: Draggable<T>(
          data: _elevatedEvent,
          onDragStarted: () => _dragging = true,
          onDragUpdate: (details) {
            widget.onDragUpdate?.call(details);
            _eventBounds.origin += details.delta;
          },
          onDragEnd: (details) {
            widget.onDragEnd?.call();
            _dragging = false;
            _updateEventOrigin();
          },
          onDraggableCanceled: (velocity, offset) => _dragging = false,
          feedback: _feedback(),
          childWhenDragging: const SizedBox.shrink(),
          child: CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onPanDown: (details) => widget.onDragDown?.call(),
              child: _eventView(),
            ),
          ),
        ),
      );

  Widget _sizerBuilder(BuildContext context) => ValueListenableBuilder(
        valueListenable: _animation,
        builder: (context, scale, child) => Positioned(
          width: _draggableEventTheme.sizerDimension * scale,
          height: _draggableEventTheme.sizerDimension * scale,
          child: child!,
        ),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.center,
          child: GestureDetectorHitTestWithoutSizeLimit(
            onVerticalDragDown: (details) => widget.onDragDown?.call(),
            onVerticalDragStart: (details) => _resizing = true,
            onVerticalDragUpdate: (details) {
              widget.onSizeUpdate?.call(details);
              _eventBounds.size += details.delta;
            },
            onVerticalDragEnd: (details) {
              widget.onResizingEnd?.call();
              _resizing = false;
              _updateEventHeightAndDuration();
            },
            onVerticalDragCancel: () => _resizing = false,
            extraHitTestArea: const EdgeInsets.all(4),
            child: _sizerView(),
          ),
        ),
      );
}
