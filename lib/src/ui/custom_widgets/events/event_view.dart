import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/custom_widgets/custom_widgets.dart';

class EventView<T extends FloatingCalendarEvent> extends StatelessWidget {
  const EventView(
    this.event, {
    super.key,
    this.elevation,
    this.onTap,
    this.onLongPress,
  });

  /// Calendar event
  final T event;

  /// If shadow is needed
  final double? elevation;

  /// On event view tap callback
  final VoidCallback? onTap;

  /// On event view long press callback
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: event.color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      borderOnForeground: false,
      margin: const EdgeInsets.all(1),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Builder(
          builder: _createBody[event.runtimeType] ??
              (context) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Map<Type, WidgetBuilder> get _createBody => {
        SimpleEvent: (context) => SimpleEventView(event as SimpleEvent),
        TaskDue: (context) => TaskDueView(event as TaskDue),
      };
}
