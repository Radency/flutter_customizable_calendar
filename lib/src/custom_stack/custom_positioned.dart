import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/src/custom_stack/custom_stack.dart';

class CustomPositioned extends Positioned {
  /// Creates a widget that controls where a child of a [Stack] is positioned.
  ///
  /// Only two out of the three horizontal values ([left], [right],
  /// [width]), and only two out of the three vertical values ([top],
  /// [bottom], [height]), can be set. In each case, at least one of
  /// the three must be null.
  ///
  /// See also:
  ///
  ///  * [Positioned.directional], which specifies the widget's horizontal
  ///    position using `start` and `end` rather than `left` and `right`.
  ///  * [PositionedDirectional], which is similar to [Positioned.directional]
  ///    but adapts to the ambient [Directionality].
  const CustomPositioned({
    super.key,
    super.left,
    super.top,
    super.right,
    super.bottom,
    super.width,
    super.height,
    required super.child,
  });

  /// Creates a Positioned object with the values from the given [Rect].
  ///
  /// This sets the [left], [top], [width], and [height] properties
  /// from the given [Rect]. The [right] and [bottom] properties are
  /// set to null.
  CustomPositioned.fromRect({
    super.key,
    required Rect rect,
    required super.child,
  }) : super(
    left: rect.left,
    top: rect.top,
    width: rect.width,
    height: rect.height,
    right: null,
    bottom: null,
  );

  /// Creates a Positioned object with the values from the given [RelativeRect].
  ///
  /// This sets the [left], [top], [right], and [bottom] properties from the
  /// given [RelativeRect]. The [height] and [width] properties are set to null.
  CustomPositioned.fromRelativeRect({
    super.key,
    required Rect rect,
    required super.child,
  }) : super(
    left: rect.left,
    top: rect.top,
    width: rect.width,
    height: rect.height,
    right: null,
    bottom: null,
  );

  /// Creates a Positioned object with [left], [top], [right], and [bottom] set
  /// to 0.0 unless a value for them is passed.
  const CustomPositioned.fill({
    super.key,
    super.left = 0.0,
    super.top = 0.0,
    super.right = 0.0,
    super.bottom = 0.0,
    required super.child,
  });

  /// Creates a widget that controls where a child of a [Stack] is positioned.
  ///
  /// Only two out of the three horizontal values (`start`, `end`,
  /// [width]), and only two out of the three vertical values ([top],
  /// [bottom], [height]), can be set. In each case, at least one of
  /// the three must be null.
  ///
  /// If `textDirection` is [TextDirection.rtl], then the `start` argument is
  /// used for the [right] property and the `end` argument is used for the
  /// [left] property. Otherwise, if `textDirection` is [TextDirection.ltr],
  /// then the `start` argument is used for the [left] property and the `end`
  /// argument is used for the [right] property.
  ///
  /// The `textDirection` argument must not be null.
  ///
  /// See also:
  ///
  ///  * [PositionedDirectional], which adapts to the ambient [Directionality].
  factory CustomPositioned.directional({
    Key? key,
    required TextDirection textDirection,
    double? start,
    double? top,
    double? end,
    double? bottom,
    double? width,
    double? height,
    required Widget child,
  }) {
    assert(textDirection != null);
    double? left;
    double? right;
    switch (textDirection) {
      case TextDirection.rtl:
        left = end;
        right = start;
        break;
      case TextDirection.ltr:
        left = start;
        right = end;
        break;
    }
    return CustomPositioned(
      key: key,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  // /// The distance that the child's left edge is inset from the left of the stack.
  // ///
  // /// Only two out of the three horizontal values ([left], [right], [width]) can be
  // /// set. The third must be null.
  // ///
  // /// If all three are null, the [Stack.alignment] is used to position the child
  // /// horizontally.
  // final double? left;
  //
  // /// The distance that the child's top edge is inset from the top of the stack.
  // ///
  // /// Only two out of the three vertical values ([top], [bottom], [height]) can be
  // /// set. The third must be null.
  // ///
  // /// If all three are null, the [Stack.alignment] is used to position the child
  // /// vertically.
  // final double? top;
  //
  // /// The distance that the child's right edge is inset from the right of the stack.
  // ///
  // /// Only two out of the three horizontal values ([left], [right], [width]) can be
  // /// set. The third must be null.
  // ///
  // /// If all three are null, the [Stack.alignment] is used to position the child
  // /// horizontally.
  // final double? right;
  //
  // /// The distance that the child's bottom edge is inset from the bottom of the stack.
  // ///
  // /// Only two out of the three vertical values ([top], [bottom], [height]) can be
  // /// set. The third must be null.
  // ///
  // /// If all three are null, the [Stack.alignment] is used to position the child
  // /// vertically.
  // final double? bottom;
  //
  // /// The child's width.
  // ///
  // /// Only two out of the three horizontal values ([left], [right], [width]) can be
  // /// set. The third must be null.
  // ///
  // /// If all three are null, the [Stack.alignment] is used to position the child
  // /// horizontally.
  // final double? width;
  //
  // /// The child's height.
  // ///
  // /// Only two out of the three vertical values ([top], [bottom], [height]) can be
  // /// set. The third must be null.
  // ///
  // /// If all three are null, the [Stack.alignment] is used to position the child
  // /// vertically.
  // final double? height;

  // @override
  // void applyParentData(RenderObject renderObject) {
  //   assert(renderObject.parentData is StackParentData);
  //   final StackParentData parentData = renderObject.parentData! as StackParentData;
  //   bool needsLayout = false;
  //
  //   if (parentData.left != left) {
  //     parentData.left = left;
  //     needsLayout = true;
  //   }
  //
  //   if (parentData.top != top) {
  //     parentData.top = top;
  //     needsLayout = true;
  //   }
  //
  //   if (parentData.right != right) {
  //     parentData.right = right;
  //     needsLayout = true;
  //   }
  //
  //   if (parentData.bottom != bottom) {
  //     parentData.bottom = bottom;
  //     needsLayout = true;
  //   }
  //
  //   if (parentData.width != width) {
  //     parentData.width = width;
  //     needsLayout = true;
  //   }
  //
  //   if (parentData.height != height) {
  //     parentData.height = height;
  //     needsLayout = true;
  //   }
  //
  //   if (needsLayout) {
  //     final AbstractNode? targetParent = renderObject.parent;
  //     if (targetParent is RenderObject) {
  //       targetParent.markNeedsLayout();
  //     }
  //   }
  // }

  @override
  Type get debugTypicalAncestorWidgetClass => CustomStack;

  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(DoubleProperty('left', left, defaultValue: null));
  //   properties.add(DoubleProperty('top', top, defaultValue: null));
  //   properties.add(DoubleProperty('right', right, defaultValue: null));
  //   properties.add(DoubleProperty('bottom', bottom, defaultValue: null));
  //   properties.add(DoubleProperty('width', width, defaultValue: null));
  //   properties.add(DoubleProperty('height', height, defaultValue: null));
  // }
}
