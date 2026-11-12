import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';

/// Applies a paint-only frame (an [FxAccumulator]'s transform, fractional
/// translation and opacity) at paint time.
///
/// The engine uses this when every effect in a chain is
/// [FxEffect.paintOnly]: each animation tick then only repaints (and updates
/// two layers) instead of rebuilding widgets. [compose] is called lazily, at
/// most once per tick, to build the frame for the animation's current value.
class FxPaintComposite extends SingleChildRenderObjectWidget {
  /// Repaint [child] with the frame [compose] returns whenever [animation]
  /// notifies.
  const FxPaintComposite({
    super.key,
    required this.animation,
    required this.compose,
    this.repaintBoundary = true,
    super.child,
  });

  /// Repaints whenever this notifies.
  final Listenable animation;

  /// Builds the frame for the current animation value. Must only write the
  /// paint-only parts of the accumulator.
  final FxAccumulator Function() compose;

  /// Whether to isolate each tick's repaint to this subtree. Unlike wrapping
  /// it in a [RepaintBoundary] widget, this keeps hit testing working where
  /// the child is drawn, even outside its layout bounds.
  final bool repaintBoundary;

  @override
  RenderFxPaintComposite createRenderObject(BuildContext context) =>
      RenderFxPaintComposite(
        animation: animation,
        compose: compose,
        repaintBoundary: repaintBoundary,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFxPaintComposite renderObject,
  ) {
    renderObject
      ..animation = animation
      ..compose = compose
      ..repaintBoundary = repaintBoundary;
  }
}

/// The render object behind [FxPaintComposite].
///
/// Like a [RenderTransform] around a [RenderOpacity], except both values come
/// from the current frame instead of widget properties, so they change without
/// a rebuild. Hit testing and [applyPaintTransform] follow the transform, the
/// same way [Transform] does.
class RenderFxPaintComposite extends RenderProxyBox {
  /// Create the render object.
  RenderFxPaintComposite({
    required this._animation,
    required this._compose,
    this._repaintBoundary = true,
    RenderBox? child,
  }) : super(child);

  bool _repaintBoundary;

  /// Whether this object is a repaint boundary (see
  /// [FxPaintComposite.repaintBoundary]).
  bool get repaintBoundary => _repaintBoundary;
  set repaintBoundary(bool value) {
    if (value == _repaintBoundary) return;
    _repaintBoundary = value;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => _repaintBoundary;

  Listenable _animation;

  /// The listenable that marks this object as needing paint.
  Listenable get animation => _animation;
  set animation(Listenable value) {
    if (identical(value, _animation)) return;
    if (attached) {
      _animation.removeListener(_invalidate);
      value.addListener(_invalidate);
    }
    _animation = value;
    _invalidate();
  }

  FxAccumulator Function() _compose;

  /// Builds the current frame. Always invalidates, because a new callback
  /// usually closes over a new chain or text direction.
  set compose(FxAccumulator Function() value) {
    _compose = value;
    _invalidate();
  }

  FxAccumulator? _frame;

  /// The frame for the animation's current value.
  FxAccumulator get frame => _frame ??= _compose();

  /// The composed opacity of the current frame, in `0..1`.
  double get opacity => frame.opacity.clamp(0.0, 1.0);

  final LayerHandle<OpacityLayer> _opacityLayer = LayerHandle<OpacityLayer>();
  final LayerHandle<TransformLayer> _transformLayer =
      LayerHandle<TransformLayer>();

  void _invalidate() {
    _frame = null;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(_invalidate);
  }

  @override
  void detach() {
    _animation.removeListener(_invalidate);
    super.detach();
  }

  @override
  void dispose() {
    _opacityLayer.layer = null;
    _transformLayer.layer = null;
    super.dispose();
  }

  // The layers pushed below change every tick, so ancestors must composite
  // (e.g. clip with layers rather than on the canvas) to contain them.
  @override
  bool get alwaysNeedsCompositing => child != null;

  /// The full transform for the current frame: the accumulated matrix about
  /// the center, applied after the size-relative translation.
  Matrix4 get effectiveTransform {
    final f = frame;
    final w = size.width;
    final h = size.height;
    final fx = f.fractionalTranslation.dx * w;
    final fy = f.fractionalTranslation.dy * h;
    if (f.transform.isIdentity()) {
      return Matrix4.translationValues(fx, fy, 0);
    }
    return Matrix4.translationValues(w / 2, h / 2, 0)
      ..multiply(f.transform)
      ..multiply(Matrix4.translationValues(fx - w / 2, fy - h / 2, 0));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    final alpha = Color.getAlphaFromOpacity(opacity);
    if (alpha == 0) {
      // Matches Opacity(opacity: 0): nothing is painted.
      _opacityLayer.layer = null;
      _transformLayer.layer = null;
      return;
    }
    final transform = effectiveTransform;

    void paintChild(PaintingContext context, Offset offset) =>
        context.paintChild(child, offset);

    void paintTransformed(PaintingContext context, Offset offset) {
      if (transform.isIdentity()) {
        _transformLayer.layer = null;
        paintChild(context, offset);
        return;
      }
      _transformLayer.layer = context.pushTransform(
        needsCompositing,
        offset,
        transform,
        paintChild,
        oldLayer: _transformLayer.layer,
      );
    }

    if (alpha == 255) {
      _opacityLayer.layer = null;
      paintTransformed(context, offset);
      return;
    }
    _opacityLayer.layer = context.pushOpacity(
      offset,
      alpha,
      paintTransformed,
      oldLayer: _opacityLayer.layer,
    );
  }

  // Like RenderTransform: don't test our own (untransformed) bounds, so a
  // child moved outside them can still be hit where it is drawn.
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) =>
      hitTestChildren(result, position: position);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      result.addWithPaintTransform(
        transform: effectiveTransform,
        position: position,
        hitTest: (result, position) =>
            super.hitTestChildren(result, position: position),
      );

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(effectiveTransform);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('opacity', opacity))
      ..add(
        DiagnosticsProperty<Offset>(
          'fractionalTranslation',
          frame.fractionalTranslation,
        ),
      )
      ..add(TransformProperty('transform', frame.transform));
  }
}
