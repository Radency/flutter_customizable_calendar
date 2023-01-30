import 'package:extra_hittest_area/extra_hittest_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/events/event_view.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

/// A key holder of all DraggableEventView keys
@visibleForTesting
abstract class DraggableEventViewKeys {
  /// A key for the elevated (floating) event view
  static final elevatedEvent = UniqueKey();
}

class DraggableEventView<T extends FloatingCalendarEvent>
    extends StatefulWidget {
  const DraggableEventView(
    this.event, {
    super.key,
    this.elevation,
    required this.bounds,
    this.animationDuration = const Duration(milliseconds: 200),
    this.curve = Curves.linear,
    required this.getEventBounds,
    required this.expandTo,
    this.onDragDown,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDraggableCanceled,
    this.onResizingStart,
    this.onSizeUpdate,
    this.onResizingEnd,
    this.onResizingCancel,
    this.onDropped,
  });

  final ValueNotifier<T?> event;
  final double? elevation;
  final RectNotifier bounds;
  final Duration animationDuration;
  final Curve curve;
  final Rect? Function(T) getEventBounds;
  final Rect? Function(T) expandTo;
  final void Function(DragDownDetails)? onDragDown;
  final void Function()? onDragStart;
  final void Function(DragUpdateDetails)? onDragUpdate;
  final void Function(DraggableDetails)? onDragEnd;
  final void Function(Velocity, Offset)? onDraggableCanceled;
  final void Function(DragStartDetails)? onResizingStart;
  final void Function(DragUpdateDetails)? onSizeUpdate;
  final void Function(DragEndDetails)? onResizingEnd;
  final void Function()? onResizingCancel;
  final void Function()? onDropped;

  @override
  State<DraggableEventView<T>> createState() => _DraggableEventViewState<T>();
}

class _DraggableEventViewState<T extends FloatingCalendarEvent>
    extends State<DraggableEventView<T>> with SingleTickerProviderStateMixin {
  final _overlayKey = GlobalKey<OverlayState>();
  final _layerLink = LayerLink();
  late AnimationController _animationController;
  late Animation<double> _animation;
  late RectTween _rectTween;
  T? _elevatedEvent;
  OverlayEntry? _eventEntry;
  OverlayEntry? _sizerEntry;

  static const _sizerDimension = 8.0;

  OverlayState get _overlay => _overlayKey.currentState!;

  void _elevatedEventListener() {
    if (widget.event.value == null) return;
    _elevatedEvent = widget.event.value;
    _elevate(_elevatedEvent!);
  }

  void _animationListener() =>
      widget.bounds.value = _rectTween.transform(_animation.value)!;

  void _initAnimationController() => _animationController = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      )..addListener(_animationListener);

  void _initAnimation() => _animation = CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      );

  void _elevate(T event) {
    if (_animationController.isAnimating) {
      _removeEntries();
      _animationController.reset();
    }

    _eventEntry = OverlayEntry(builder: _floatingEventBuilder);
    _overlay.insert(_eventEntry!);

    // Non-editable events can't be resized
    if (event is EditableCalendarEvent) {
      _sizerEntry = OverlayEntry(builder: _sizerBuilder);
      _overlay.insert(_sizerEntry!);
    }

    _rectTween = RectTween(
      begin: widget.getEventBounds(event),
      end: widget.expandTo(event),
    );

    _animationController.forward();
  }

  void _drop(T event) {
    if (_animationController.isAnimating) _animationController.stop();

    _rectTween = RectTween(
      end: widget.bounds.value,
      begin: widget.getEventBounds(event),
    );

    _animationController.reverse().whenComplete(() {
      _removeEntries();
      widget.onDropped?.call();
    });
  }

  void _removeEntries() {
    _eventEntry?.remove();
    _eventEntry = null;
    _sizerEntry?.remove();
    _sizerEntry = null;
  }

  @override
  void initState() {
    super.initState();
    _initAnimationController();
    _initAnimation();
    widget.event.addListener(_elevatedEventListener);
  }

  @override
  void didUpdateWidget(covariant DraggableEventView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.dispose();
      _initAnimationController();
    }

    if (widget.curve != oldWidget.curve) _initAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.event,
      builder: (context, event, child) => (event == null)
          ? child!
          : GestureDetector(
              onTap: () => _drop(event),
              behavior: HitTestBehavior.translucent,
              child: child,
            ),
      child: Overlay(key: _overlayKey),
    );
  }

  @override
  void dispose() {
    widget.event.removeListener(_elevatedEventListener);
    _animationController.dispose();
    super.dispose();
  }

  Widget _eventView() => EventView(
        _elevatedEvent!,
        key: DraggableEventViewKeys.elevatedEvent,
        elevation: widget.elevation,
        onTap: () {},
      );

  Widget _sizerView() => const DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      );

  Widget _floatingEventBuilder(BuildContext context) => ValueListenableBuilder(
        valueListenable: widget.bounds,
        builder: (context, rect, child) => Positioned.fromRect(
          rect: rect,
          child: child!,
        ),
        child: Draggable(
          data: _elevatedEvent,
          onDragStarted: widget.onDragStart,
          onDragUpdate: widget.onDragUpdate,
          onDragEnd: widget.onDragEnd,
          onDraggableCanceled: widget.onDraggableCanceled,
          feedback: Builder(builder: _feedbackBuilder),
          childWhenDragging: const SizedBox.shrink(),
          child: CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onPanDown: widget.onDragDown,
              child: _eventView(),
            ),
          ),
        ),
      );

  Widget _feedbackBuilder(BuildContext context) => Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          SizedBox.fromSize(
            size: widget.bounds.size,
            child: _eventView(),
          ),
          if (_sizerEntry != null)
            Positioned(
              bottom: -(_sizerDimension / 2),
              width: _sizerDimension,
              height: _sizerDimension,
              child: _sizerView(),
            ),
        ],
      );

  Widget _sizerBuilder(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Positioned(
          width: _sizerDimension * _animation.value,
          height: _sizerDimension * _animation.value,
          child: child!,
        ),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.center,
          child: GestureDetectorHitTestWithoutSizeLimit(
            onVerticalDragDown: widget.onDragDown,
            onVerticalDragStart: widget.onResizingStart,
            onVerticalDragUpdate: widget.onSizeUpdate,
            onVerticalDragEnd: widget.onResizingEnd,
            onVerticalDragCancel: widget.onResizingCancel,
            extraHitTestArea: const EdgeInsets.all(4),
            child: _sizerView(),
          ),
        ),
      );
}
