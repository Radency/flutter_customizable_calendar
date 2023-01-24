import 'package:extra_hittest_area/extra_hittest_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/events/event_view.dart';
import 'package:flutter_customizable_calendar/src/utils/utils.dart';

class DraggableEventView<T extends FloatingCalendarEvent>
    extends StatefulWidget {
  const DraggableEventView(
    this.event, {
    super.key,
    this.elevation,
    required this.bounds,
    required this.animation,
    this.onDragDown,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDraggableCanceled,
    this.onResizingStart,
    this.onSizeUpdate,
    this.onResizingEnd,
    this.onResizingCancel,
  });

  final T event;
  final double? elevation;
  final RectNotifier bounds;
  final Animation<double> animation;
  final void Function(DragDownDetails)? onDragDown;
  final void Function()? onDragStart;
  final void Function(DragUpdateDetails)? onDragUpdate;
  final void Function(DraggableDetails)? onDragEnd;
  final void Function(Velocity, Offset)? onDraggableCanceled;
  final void Function(DragStartDetails)? onResizingStart;
  final void Function(DragUpdateDetails)? onSizeUpdate;
  final void Function(DragEndDetails)? onResizingEnd;
  final void Function()? onResizingCancel;

  @override
  State<DraggableEventView<T>> createState() => _DraggableEventViewState<T>();
}

class _DraggableEventViewState<T extends FloatingCalendarEvent>
    extends State<DraggableEventView<T>> {
  final _link = LayerLink();
  OverlayEntry? _sizerEntry;

  static const _sizerDimension = 8.0;

  @override
  void initState() {
    super.initState();
    // Non-editable events can't be resized
    if (widget.event is EditableCalendarEvent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sizerEntry = OverlayEntry(builder: _sizerBuilder);
        Overlay.of(context)!.insert(_sizerEntry!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.bounds,
      builder: (context, rect, child) => Positioned.fromRect(
        rect: rect,
        child: child!,
      ),
      child: Draggable(
        data: widget.event,
        onDragStarted: widget.onDragStart,
        onDragUpdate: widget.onDragUpdate,
        onDragEnd: widget.onDragEnd,
        onDraggableCanceled: widget.onDraggableCanceled,
        feedback: Builder(builder: _feedbackBuilder),
        childWhenDragging: const SizedBox.shrink(),
        child: CompositedTransformTarget(
          link: _link,
          child: GestureDetector(
            onPanDown: widget.onDragDown,
            child: _eventView(),
          ),
        ),
        // onDragCompleted: ,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _sizerEntry?.remove();
    super.dispose();
  }

  Widget _eventView() => EventView(
        widget.event,
        elevation: widget.elevation,
        onTap: () {},
      );

  Widget _sizerView() => const DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
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
        animation: widget.animation,
        builder: (context, child) => Positioned(
          width: _sizerDimension * widget.animation.value,
          height: _sizerDimension * widget.animation.value,
          child: child!,
        ),
        child: CompositedTransformFollower(
          link: _link,
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
