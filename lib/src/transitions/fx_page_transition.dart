/// The built-in page transition styles.
enum FxPageTransition {
  /// Cross-fade.
  fade,

  /// Fade + subtle scale-up.
  scale,

  /// Fade-through zoom (scale from small).
  zoom,

  /// Full-screen directional slide (see `slideFrom`).
  slide,

  /// Rotate + scale + fade.
  rotation,

  /// Material shared-axis along X (incoming slides in, outgoing slides out).
  sharedAxisHorizontal,

  /// Material shared-axis along Y.
  sharedAxisVertical,

  /// Material 3 fade-through: outgoing fades + scales out, then incoming
  /// fades + scales in.
  fadeThrough,

  /// iOS-style parallax: incoming slides fully in from the right while the
  /// outgoing page parallax-slides partway out to the left.
  cupertino,

  /// Depth: incoming rises + scales up from below while the outgoing page
  /// recedes and fades.
  depth,

  /// Modal sheet: incoming slides up from the bottom; the page behind scales
  /// down slightly.
  sheet,

  /// Circular reveal: the incoming page expands from a growing circle.
  circularReveal,

  /// 3D cube-style rotation between pages.
  cube3D,

  /// Blur cross-fade: incoming sharpens in while outgoing blurs away.
  blur,

  /// Container transform: the incoming page expands from `originRect`
  /// (e.g. a tapped card) into the full screen, with rounded corners easing
  /// out. Falls back to a centered grow when no rect is given.
  containerTransform,

  /// Frosted glass: the incoming page materializes through a blur that peaks
  /// mid-transition and clears.
  glass,
}
