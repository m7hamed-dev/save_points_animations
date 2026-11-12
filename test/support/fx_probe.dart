import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/src/builders/fx_paint_composite.dart';

/// The opacity [finder]'s widget is painted with: the product of every
/// opacity above it, whether it comes from an `Opacity` / `FadeTransition`
/// widget or from the engine's paint-time composite (which builds no widget).
double fxPaintedOpacity(WidgetTester tester, Finder finder) {
  RenderObject? node = tester.renderObject(finder);
  var opacity = 1.0;
  while (node != null) {
    if (node is RenderOpacity) {
      opacity *= node.opacity;
    } else if (node is RenderAnimatedOpacity) {
      opacity *= node.opacity.value;
    } else if (node is RenderFxPaintComposite) {
      opacity *= node.opacity;
    }
    node = node.parent;
  }
  return opacity;
}

/// The nearest engine paint-time composite above [finder], if any.
RenderFxPaintComposite? fxCompositeOf(WidgetTester tester, Finder finder) {
  RenderObject? node = tester.renderObject(finder);
  while (node != null) {
    if (node is RenderFxPaintComposite) return node;
    node = node.parent;
  }
  return null;
}
