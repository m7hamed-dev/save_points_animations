import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';

/// Applies a paint-only frame (an [FxAccumulator]'s transform, fractional
/// translation and opacity) without rebuilding widgets.
///
/// The engine uses this when every effect in a chain is
/// [FxEffect.paintOnly]. With [repaintBoundary] (the default), each animation
/// tick only updates two compositing layers, an opacity and a transform: the
/// child is not rebuilt, laid out or repainted, the way [FadeTransition]
/// updates its opacity. [compose] is called once per tick to build the frame
/// for the animation's current value.
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

  /// Whether this subtree gets its own layers, so a tick updates them instead
  /// of repainting anything. Unlike wrapping it in a [RepaintBoundary]
  /// widget, this keeps hit testing working where the child is drawn, even
  /// outside its layout bounds. When false, each tick repaints the child
  /// along with its nearest repaint boundary.
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
///
/// As a repaint boundary its own layer is an [OpacityLayer], and it paints
/// the child into a [TransformLayer] it keeps. A new frame then only sets
/// those two layers' alpha and matrix ([updateCompositedLayer]), like
/// [RenderAnimatedOpacity]. A fully transparent frame paints nothing and is
/// not a boundary, so an invisible child costs no layer.
class RenderFxPaintComposite extends RenderProxyBox {
  /// Create the render object.
  RenderFxPaintComposite({
    required this._animation,
    required this._compose,
    this._repaintBoundary = true,
    RenderBox? child,
  }) : super(child) {
    _alpha = _alphaOf(frame);
  }

  bool _repaintBoundary;

  /// Whether this object may be a repaint boundary (see
  /// [FxPaintComposite.repaintBoundary]).
  bool get repaintBoundary => _repaintBoundary;
  set repaintBoundary(bool value) {
    if (value == _repaintBoundary) return;
    _repaintBoundary = value;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => _repaintBoundary && child != null && _alpha > 0;

  /// The current frame's opacity as an 8-bit alpha. Kept up to date on every
  /// invalidation, because it decides whether this is a repaint boundary.
  int _alpha = 255;

  static int _alphaOf(FxAccumulator frame) =>
      Color.getAlphaFromOpacity(frame.opacity.clamp(0.0, 1.0));

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
    final oldAlpha = _alpha;
    _alpha = _alphaOf(frame);
    if (child != null && (oldAlpha == 0) != (_alpha == 0)) {
      // Becoming (in)visible toggles isRepaintBoundary.
      markNeedsCompositingBitsUpdate();
    }
    // Falls back to markNeedsPaint when this isn't (or wasn't yet) a boundary.
    markNeedsCompositedLayerUpdate();
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

  /// The offset [paint] last pushed the kept transform layer at (zero in
  /// practice: the framework paints a repaint boundary at its own origin).
  Offset _layerOffset = Offset.zero;

  /// [effectiveTransform] about [offset], as [PaintingContext.pushTransform]
  /// would set it on its layer.
  Matrix4 _layerTransform(Offset offset) =>
      Matrix4.translationValues(offset.dx, offset.dy, 0)
        ..multiply(effectiveTransform)
        ..multiply(Matrix4.translationValues(-offset.dx, -offset.dy, 0));

  @override
  OffsetLayer updateCompositedLayer({
    required covariant OpacityLayer? oldLayer,
  }) {
    final layer = oldLayer ?? OpacityLayer();
    layer.alpha = _alpha;
    // On a layer-only update this is where the matrix changes; when the frame
    // also repaints, paint() sets it again on the same layer.
    _transformLayer.layer?.transform = _layerTransform(_layerOffset);
    return layer;
  }

  void _paintChild(PaintingContext context, Offset offset) =>
      context.paintChild(child!, offset);

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    final alpha = _alpha;
    if (alpha == 0) {
      // Matches Opacity(opacity: 0): nothing is painted.
      _opacityLayer.layer = null;
      _transformLayer.layer = null;
      return;
    }

    if (isRepaintBoundary) {
      // This object's own layer carries the opacity (updateCompositedLayer).
      // Always push the transform layer, even for an identity matrix, so the
      // next frames can update it in place instead of repainting.
      _opacityLayer.layer = null;
      _layerOffset = offset;
      final layer = _transformLayer.layer ??= TransformLayer();
      layer.transform = _layerTransform(offset);
      context.pushLayer(layer, _paintChild, offset);
      return;
    }

    final transform = effectiveTransform;

    void paintTransformed(PaintingContext context, Offset offset) {
      if (transform.isIdentity()) {
        _transformLayer.layer = null;
        _paintChild(context, offset);
        return;
      }
      _transformLayer.layer = context.pushTransform(
        needsCompositing,
        offset,
        transform,
        _paintChild,
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
