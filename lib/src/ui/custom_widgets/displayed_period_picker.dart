import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/domain/models/models.dart';
import 'package:flutter_customizable_calendar/src/ui/themes/themes.dart';

/// A view of a toggle which allows to switch between displayed periods.
/// The [period] value mustn't be null.
class DisplayedPeriodPicker extends StatelessWidget {
  /// Creates a view of a displayed period picker.
  const DisplayedPeriodPicker({
    required this.period,
    super.key,
    this.theme = const DisplayedPeriodPickerTheme(),
    this.reverseAnimation = false,
    this.onLeftButtonPressed,
    this.onRightButtonPressed,
  });

  /// Date range which needs to be displayed
  final DisplayedPeriod period;

  /// Customization params for the view
  final DisplayedPeriodPickerTheme theme;

  /// Set to true if reversed animation is needed
  final bool reverseAnimation;

  /// On left arrow tap callback
  final VoidCallback? onLeftButtonPressed;

  /// On right arrow tap callback
  final VoidCallback? onRightButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.backgroundColor,
      margin: theme.margin,
      elevation: 0,
      shape: theme.shape,
      child: SizedBox(
        width: theme.width,
        height: theme.height,
        child: CupertinoTheme(
          data: CupertinoTheme.of(context)
              .copyWith(primaryColor: theme.foregroundColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                onPressed: onLeftButtonPressed,
                padding: theme.prevButtonTheme.padding,
                color: theme.prevButtonTheme.color,
                borderRadius: theme.prevButtonTheme.borderRadius,
                child: theme.prevButtonTheme.child,
              ),
              PageTransitionSwitcher(
                transitionBuilder: (child, animation, secondaryAnimation) =>
                    SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                ),
                reverse: reverseAnimation,
                child: Text(
                  theme.periodFormatter.call(period),
                  key: ValueKey(period),
                  style: theme.textStyle,
                ),
              ),
              CupertinoButton(
                onPressed: onRightButtonPressed,
                padding: theme.nextButtonTheme.padding,
                color: theme.nextButtonTheme.color,
                borderRadius: theme.nextButtonTheme.borderRadius,
                child: theme.nextButtonTheme.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
