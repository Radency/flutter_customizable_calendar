import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// [RenderIdProvider] needs to find a concrete [RenderBox] on hitTesting.
class RenderIdProvider<T> extends SingleChildRenderObjectWidget {
  /// Creates [RenderId] object with given [id] which wraps the [child].
  const RenderIdProvider({
    super.key,
    required this.id,
    super.child,
  });

  /// Data needs to identify the [RenderObject]
  final T id;

  @override
  RenderId<T> createRenderObject(BuildContext context) => RenderId(id);
}

/// [RenderId] is a type of [RenderBox] which contains a [id] inside.
class RenderId<T> extends RenderProxyBox {
  /// Creates a new instance of [RenderProxyBox] with given [id].
  RenderId(this.id);

  /// An identification value
  final T id;
}
