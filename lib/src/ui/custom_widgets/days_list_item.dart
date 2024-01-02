import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/themes.dart';

/// An item view of the days list (is used in DaysView).
class DaysListItem extends StatefulWidget {
  /// Creates view of a days list's item.
  const DaysListItem({
    required this.dayDate,
    super.key,
    this.isFocused = false,
    this.theme = const DaysListItemTheme(),
    this.onTap,
  });

  /// The date will be shown
  final DateTime dayDate;

  /// If the item is selected
  final bool isFocused;

  /// Customization params for the view
  final DaysListItemTheme theme;

  /// On item tap callback
  final VoidCallback? onTap;

  @override
  State<DaysListItem> createState() => _DaysListItemState();
}

class _DaysListItemState extends State<DaysListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<Color?> _backgroundAnimation;
  late Animation<Color?> _foregroundAnimation;
  late Animation<ShapeBorder?> _shapeAnimation;
  late Animation<TextStyle> _numberStyleAnimation;
  late Animation<TextStyle> _weekdayStyleAnimation;

  void _initParams() {
    _backgroundAnimation = ColorTween(
      begin: widget.theme.background,
      end: widget.theme.backgroundFocused,
    ).animate(_animationController);
    _foregroundAnimation = ColorTween(
      begin: widget.theme.foreground,
      end: widget.theme.foregroundFocused,
    ).animate(_animationController);
    _shapeAnimation = ShapeBorderTween(
      begin: widget.theme.shape,
      end: widget.theme.shapeFocused,
    ).animate(_animationController);
    _numberStyleAnimation = TextStyleTween(
      begin: widget.theme.numberStyle,
      end: widget.theme.numberStyleFocused,
    ).animate(_animationController);
    _weekdayStyleAnimation = TextStyleTween(
      begin: widget.theme.weekdayStyle,
      end: widget.theme.weekdayStyleFocused,
    ).animate(_animationController);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      value: widget.isFocused ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _initParams();
  }

  @override
  void didUpdateWidget(covariant DaysListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) _initParams();
    widget.isFocused
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Card(
        color: _backgroundAnimation.value,
        elevation: widget.theme.elevation,
        shape: _shapeAnimation.value,
        borderOnForeground: false,
        margin: widget.theme.margin,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: DefaultTextStyle(
            style: TextStyle(color: _foregroundAnimation.value),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  widget.theme.numberFormatter.call(widget.dayDate),
                  style: _numberStyleAnimation.value,
                  textAlign: TextAlign.center,
                ),
                if (!widget.theme.hideWeekday)
                  Text(
                    widget.theme.weekdayFormatter.call(widget.dayDate),
                    style: _weekdayStyleAnimation.value,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
