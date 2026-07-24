/// Fluent wrappers for the package's child-wrapping widgets.
///
/// Every widget in `src/widgets/` that takes a `required child` gets a matching
/// method here, so instead of `FxShine(child: myWidget)` you can write
/// `myWidget.fxShine()`. Each method mirrors its widget's constructor exactly —
/// same parameter names, types, and defaults — with the receiver becoming the
/// `child` argument.
library;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_animated_gradient.dart';
import 'package:save_points_animations/src/widgets/fx_aurora.dart';
import 'package:save_points_animations/src/widgets/fx_blob.dart';
import 'package:save_points_animations/src/widgets/fx_border_beam.dart';
import 'package:save_points_animations/src/widgets/fx_bubbles.dart';
import 'package:save_points_animations/src/widgets/fx_confetti.dart';
import 'package:save_points_animations/src/widgets/fx_dot_grid.dart';
import 'package:save_points_animations/src/widgets/fx_draggable_sheet.dart';
import 'package:save_points_animations/src/widgets/fx_fireworks.dart';
import 'package:save_points_animations/src/widgets/fx_glass_card.dart';
import 'package:save_points_animations/src/widgets/fx_glitch.dart';
import 'package:save_points_animations/src/widgets/fx_gradient_border.dart';
import 'package:save_points_animations/src/widgets/fx_gradient_button.dart';
import 'package:save_points_animations/src/widgets/fx_hold_button.dart';
import 'package:save_points_animations/src/widgets/fx_ken_burns.dart';
import 'package:save_points_animations/src/widgets/fx_magnetic_button.dart';
import 'package:save_points_animations/src/widgets/fx_marquee.dart';
import 'package:save_points_animations/src/widgets/fx_particles.dart';
import 'package:save_points_animations/src/widgets/fx_progress_button.dart';
import 'package:save_points_animations/src/widgets/fx_pulse.dart';
import 'package:save_points_animations/src/widgets/fx_ripple.dart';
import 'package:save_points_animations/src/widgets/fx_scratch_card.dart';
import 'package:save_points_animations/src/widgets/fx_shimmer_button.dart';
import 'package:save_points_animations/src/widgets/fx_shine.dart';
import 'package:save_points_animations/src/widgets/fx_snow.dart';
import 'package:save_points_animations/src/widgets/fx_spotlight.dart';
import 'package:save_points_animations/src/widgets/fx_star_field.dart';
import 'package:save_points_animations/src/widgets/fx_swipe.dart';
import 'package:save_points_animations/src/widgets/fx_switcher.dart';
import 'package:save_points_animations/src/widgets/fx_tilt_glare_card.dart';
import 'package:save_points_animations/src/widgets/fx_toast.dart';

/// Fluent `.fxX()` wrappers for the package's child-wrapping widgets.
extension FxWrap on Widget {
  /// Wrap this widget in [FxBorderBeam]: a glowing "comet" beam that travels
  /// around the child's rounded border.
  FxBorderBeam fxBorderBeam({
    Key? key,
    Color color = const Color(0xFF2575FC),
    double borderWidth = 2,
    double borderRadius = 16,
    Duration duration = const Duration(seconds: 3),
  }) => FxBorderBeam(
    key: key,
    color: color,
    borderWidth: borderWidth,
    borderRadius: borderRadius,
    duration: duration,
    child: this,
  );

  /// Wrap this widget in [FxConfetti]: overlays a confetti particle burst above
  /// the child.
  FxConfetti fxConfetti({
    Key? key,
    FxConfettiController? controller,
    int particleCount = 30,
    List<Color> colors = const [
      Color(0xFFE53935),
      Color(0xFF43A047),
      Color(0xFF1E88E5),
      Color(0xFFFDD835),
      Color(0xFF8E24AA),
    ],
    Duration duration = const Duration(milliseconds: 1400),
    bool playOnStart = false,
  }) => FxConfetti(
    key: key,
    controller: controller,
    particleCount: particleCount,
    colors: colors,
    duration: duration,
    playOnStart: playOnStart,
    child: this,
  );

  /// Wrap this widget in [FxDraggableSheet]: a draggable bottom sheet that snaps
  /// between a list of height fractions.
  FxDraggableSheet fxDraggableSheet({
    Key? key,
    List<double> snapSizes = const [0.3, 0.6, 0.92],
    int initialSnap = 0,
    Color background = const Color(0xFFFFFFFF),
    Color handleColor = const Color(0xFFD0D0D0),
    double borderRadius = 24,
    ValueChanged<int>? onSnapChanged,
  }) => FxDraggableSheet(
    key: key,
    snapSizes: snapSizes,
    initialSnap: initialSnap,
    background: background,
    handleColor: handleColor,
    borderRadius: borderRadius,
    onSnapChanged: onSnapChanged,
    child: this,
  );

  /// Wrap this widget in [FxGlassCard]: a frosted-glass card that blurs whatever
  /// sits behind it and sweeps a soft diagonal sheen across the surface.
  FxGlassCard fxGlassCard({
    Key? key,
    double blur = 14,
    Color tint = const Color(0x33FFFFFF),
    Color borderColor = const Color(0x55FFFFFF),
    double borderRadius = 20,
    EdgeInsets padding = const EdgeInsets.all(20),
    bool sheen = true,
    Duration sheenDuration = const Duration(seconds: 4),
  }) => FxGlassCard(
    key: key,
    blur: blur,
    tint: tint,
    borderColor: borderColor,
    borderRadius: borderRadius,
    padding: padding,
    sheen: sheen,
    sheenDuration: sheenDuration,
    child: this,
  );

  /// Wrap this widget in [FxGlitch]: a looping RGB-split "glitch" effect that
  /// spikes intermittently.
  FxGlitch fxGlitch({
    Key? key,
    double intensity = 4,
    Duration duration = const Duration(milliseconds: 1600),
  }) =>
      FxGlitch(key: key, intensity: intensity, duration: duration, child: this);

  /// Wrap this widget in [FxGradientBorder]: a continuously rotating gradient
  /// border around the child.
  FxGradientBorder fxGradientBorder({
    Key? key,
    List<Color> colors = const [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
      Color(0xFFFF512F),
    ],
    double borderWidth = 3,
    double borderRadius = 16,
    Duration duration = const Duration(seconds: 3),
  }) => FxGradientBorder(
    key: key,
    colors: colors,
    borderWidth: borderWidth,
    borderRadius: borderRadius,
    duration: duration,
    child: this,
  );

  /// Wrap this widget in [FxGradientButton]: a pill button whose gradient slowly
  /// rotates, giving a living "aurora" fill.
  FxGradientButton fxGradientButton({
    Key? key,
    VoidCallback? onPressed,
    List<Color> colors = const [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
      Color(0xFFEC008C),
    ],
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 28,
      vertical: 16,
    ),
    double borderRadius = 30,
    Duration duration = const Duration(seconds: 4),
    Color textColor = const Color(0xFFFFFFFF),
  }) => FxGradientButton(
    key: key,
    onPressed: onPressed,
    colors: colors,
    padding: padding,
    borderRadius: borderRadius,
    duration: duration,
    textColor: textColor,
    child: this,
  );

  /// Wrap this widget in [FxHoldButton]: press and hold to confirm — a ring
  /// fills while held and fires `onConfirmed` when complete.
  FxHoldButton fxHoldButton({
    Key? key,
    required VoidCallback onConfirmed,
    Duration holdDuration = const Duration(milliseconds: 1200),
    double size = 64,
    Color color = const Color(0xFF448AFF),
    Color backgroundColor = const Color(0x22448AFF),
    double strokeWidth = 4,
  }) => FxHoldButton(
    key: key,
    onConfirmed: onConfirmed,
    holdDuration: holdDuration,
    size: size,
    color: color,
    backgroundColor: backgroundColor,
    strokeWidth: strokeWidth,
    child: this,
  );

  /// Wrap this widget in [FxKenBurns]: a slow, cinematic zoom-and-pan over the
  /// child (the "Ken Burns" effect).
  FxKenBurns fxKenBurns({
    Key? key,
    Duration duration = const Duration(seconds: 12),
    double maxScale = 1.25,
    double panX = 0.06,
    double panY = 0.04,
    Curve curve = Curves.easeInOut,
  }) => FxKenBurns(
    key: key,
    duration: duration,
    maxScale: maxScale,
    panX: panX,
    panY: panY,
    curve: curve,
    child: this,
  );

  /// Wrap this widget in [FxMagneticButton]: a target that leans toward the
  /// pointer while hovered and springs back to center when it leaves.
  FxMagneticButton fxMagneticButton({
    Key? key,
    VoidCallback? onTap,
    double strength = 18,
    double scaleOnHover = 1.06,
  }) => FxMagneticButton(
    key: key,
    onTap: onTap,
    strength: strength,
    scaleOnHover: scaleOnHover,
    child: this,
  );

  /// Wrap this widget in [FxMarquee]: continuously scrolls the child
  /// horizontally — a marquee / ticker.
  FxMarquee fxMarquee({Key? key, double velocity = 40, double gap = 48}) =>
      FxMarquee(key: key, velocity: velocity, gap: gap, child: this);

  /// Wrap this widget in [FxProgressButton]: a button that morphs into a loading
  /// spinner, then a success check (or error cross), driven by `state`.
  FxProgressButton fxProgressButton({
    Key? key,
    required FxButtonState state,
    required VoidCallback onPressed,
    Color color = const Color(0xFF448AFF),
    Color successColor = const Color(0xFF43A047),
    Color errorColor = const Color(0xFFE53935),
    double height = 48,
    double borderRadius = 12,
    Duration duration = const Duration(milliseconds: 300),
  }) => FxProgressButton(
    key: key,
    state: state,
    onPressed: onPressed,
    color: color,
    successColor: successColor,
    errorColor: errorColor,
    height: height,
    borderRadius: borderRadius,
    duration: duration,
    child: this,
  );

  /// Wrap this widget in [FxPulse]: a looping "sonar" pulse of expanding, fading
  /// rings behind the child.
  FxPulse fxPulse({
    Key? key,
    Color color = const Color(0xFF448AFF),
    double maxRadius = 18,
    int rings = 2,
    Duration duration = const Duration(milliseconds: 1600),
  }) => FxPulse(
    key: key,
    color: color,
    maxRadius: maxRadius,
    rings: rings,
    duration: duration,
    child: this,
  );

  /// Wrap this widget in [FxRipple]: emits an expanding, fading ripple from each
  /// tap point over the child.
  FxRipple fxRipple({
    Key? key,
    Color color = const Color(0x33448AFF),
    Duration duration = const Duration(milliseconds: 600),
    VoidCallback? onTap,
  }) => FxRipple(
    key: key,
    color: color,
    duration: duration,
    onTap: onTap,
    child: this,
  );

  /// Wrap this widget in [FxScratchCard]: a scratch-to-reveal card — drag across
  /// the cover to erase it and reveal the child beneath.
  FxScratchCard fxScratchCard({
    Key? key,
    Color coverColor = const Color(0xFFB0B0B0),
    double brushSize = 28,
  }) => FxScratchCard(
    key: key,
    coverColor: coverColor,
    brushSize: brushSize,
    child: this,
  );

  /// Wrap this widget in [FxShimmerButton]: a gradient call-to-action button
  /// with a continuously sweeping sheen.
  FxShimmerButton fxShimmerButton({
    Key? key,
    required VoidCallback onPressed,
    Gradient gradient = const LinearGradient(
      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
    ),
    double borderRadius = 12,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 14,
    ),
    Duration duration = const Duration(milliseconds: 2200),
  }) => FxShimmerButton(
    key: key,
    onPressed: onPressed,
    gradient: gradient,
    borderRadius: borderRadius,
    padding: padding,
    duration: duration,
    child: this,
  );

  /// Wrap this widget in [FxShine]: a glossy diagonal light band that sweeps
  /// across the child.
  FxShine fxShine({
    Key? key,
    Color color = const Color(0xAAFFFFFF),
    Duration duration = const Duration(milliseconds: 1800),
    double bandWidth = 0.16,
    bool loop = true,
  }) => FxShine(
    key: key,
    color: color,
    duration: duration,
    bandWidth: bandWidth,
    loop: loop,
    child: this,
  );

  /// Wrap this widget in [FxSpotlight]: a soft radial spotlight that drifts over
  /// the child (or follows the pointer).
  FxSpotlight fxSpotlight({
    Key? key,
    Color color = const Color(0x55FFFFFF),
    double radius = 0.5,
    Duration duration = const Duration(seconds: 6),
    bool followPointer = false,
  }) => FxSpotlight(
    key: key,
    color: color,
    radius: radius,
    duration: duration,
    followPointer: followPointer,
    child: this,
  );

  /// Wrap this widget in [FxSwipeToDismiss]: swipe the child horizontally to
  /// dismiss it — it fades as it moves and flings away past a threshold.
  FxSwipeToDismiss fxSwipeToDismiss({
    Key? key,
    VoidCallback? onDismissed,
    double threshold = 0.4,
  }) => FxSwipeToDismiss(
    key: key,
    onDismissed: onDismissed,
    threshold: threshold,
    child: this,
  );

  /// Wrap this widget in [FxSwitcher]: animates between children when the child
  /// changes, with the package's motion presets.
  FxSwitcher fxSwitcher({
    Key? key,
    FxSwitcherEffect effect = FxSwitcherEffect.scaleFade,
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
    AlignmentGeometry alignment = Alignment.center,
  }) => FxSwitcher(
    key: key,
    effect: effect,
    duration: duration,
    curve: curve,
    alignment: alignment,
    child: this,
  );

  /// Wrap this widget in [FxTiltGlareCard]: a pointer-driven 3D tilt card with a
  /// moving glare highlight.
  FxTiltGlareCard fxTiltGlareCard({
    Key? key,
    double maxTilt = 0.18,
    Color glareColor = const Color(0x55FFFFFF),
    double perspective = 0.001,
  }) => FxTiltGlareCard(
    key: key,
    maxTilt: maxTilt,
    glareColor: glareColor,
    perspective: perspective,
    child: this,
  );

  /// Wrap this widget in [FxToast]: a declarative toast/banner that slides and
  /// fades in when `visible` is true and animates back out when it becomes false.
  FxToast fxToast({
    Key? key,
    required bool visible,
    FxToastSide side = FxToastSide.bottom,
    Color background = const Color(0xFF2B2B2B),
    Color textColor = const Color(0xFFFFFFFF),
    Widget? icon,
    EdgeInsets margin = const EdgeInsets.all(16),
    Duration duration = const Duration(milliseconds: 320),
    VoidCallback? onTap,
  }) => FxToast(
    key: key,
    visible: visible,
    side: side,
    background: background,
    textColor: textColor,
    icon: icon,
    margin: margin,
    duration: duration,
    onTap: onTap,
    child: this,
  );

  // ── Backdrop effects ──────────────────────────────────────────────────────
  // These render a full-bleed animated effect with this widget layered on top.

  /// Layer this widget over [FxAnimatedGradient]: an animated multi-color
  /// gradient background that slowly shifts.
  FxAnimatedGradient fxAnimatedGradient({
    Key? key,
    required List<Color> colors,
    Duration duration = const Duration(seconds: 6),
  }) => FxAnimatedGradient(
    key: key,
    colors: colors,
    duration: duration,
    child: this,
  );

  /// Layer this widget over [FxAurora]: soft, drifting aurora-like color clouds.
  FxAurora fxAurora({
    Key? key,
    List<Color> colors = const [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
      Color(0xFFFF512F),
    ],
    double blur = 60,
    Duration duration = const Duration(seconds: 10),
  }) => FxAurora(
    key: key,
    colors: colors,
    blur: blur,
    duration: duration,
    child: this,
  );

  /// Layer this widget over [FxBlob]: an organic, morphing blob shape.
  FxBlob fxBlob({
    Key? key,
    double size = 120,
    Color color = const Color(0xFF7E57C2),
    double amplitude = 0.08,
    Duration duration = const Duration(seconds: 6),
  }) => FxBlob(
    key: key,
    size: size,
    color: color,
    amplitude: amplitude,
    duration: duration,
    child: this,
  );

  /// Layer this widget over [FxBubbles]: slowly rising translucent bubbles.
  FxBubbles fxBubbles({
    Key? key,
    int count = 22,
    Color color = const Color(0x33FFFFFF),
    double maxRadius = 14,
    double speed = 0.14,
  }) => FxBubbles(
    key: key,
    count: count,
    color: color,
    maxRadius: maxRadius,
    speed: speed,
    child: this,
  );

  /// Layer this widget over [FxDotGrid]: an animated grid of pulsing dots.
  FxDotGrid fxDotGrid({
    Key? key,
    double spacing = 26,
    double dotRadius = 2,
    Color color = const Color(0x33448AFF),
    Duration duration = const Duration(seconds: 4),
  }) => FxDotGrid(
    key: key,
    spacing: spacing,
    dotRadius: dotRadius,
    color: color,
    duration: duration,
    child: this,
  );

  /// Layer this widget over [FxFireworks]: periodic bursting firework particles.
  FxFireworks fxFireworks({
    Key? key,
    List<Color> colors = const [
      Color(0xFFE53935),
      Color(0xFF43A047),
      Color(0xFF1E88E5),
      Color(0xFFFDD835),
      Color(0xFF8E24AA),
    ],
    Duration interval = const Duration(milliseconds: 850),
    int particlesPerBurst = 26,
  }) => FxFireworks(
    key: key,
    colors: colors,
    interval: interval,
    particlesPerBurst: particlesPerBurst,
    child: this,
  );

  /// Layer this widget over [FxParticles]: a drifting field of soft particles.
  FxParticles fxParticles({
    Key? key,
    int count = 30,
    Color color = const Color(0x33FFFFFF),
    double maxRadius = 3,
    double speed = 0.03,
  }) => FxParticles(
    key: key,
    count: count,
    color: color,
    maxRadius: maxRadius,
    speed: speed,
    child: this,
  );

  /// Layer this widget over [FxSnow]: gently falling snow particles.
  FxSnow fxSnow({
    Key? key,
    int count = 40,
    Color color = const Color(0xCCFFFFFF),
    double maxRadius = 3,
    double speed = 0.08,
  }) => FxSnow(
    key: key,
    count: count,
    color: color,
    maxRadius: maxRadius,
    speed: speed,
    child: this,
  );

  /// Layer this widget over [FxStarField]: a parallax field of moving stars.
  FxStarField fxStarField({
    Key? key,
    int count = 140,
    Color color = const Color(0xFFFFFFFF),
    double speed = 0.6,
  }) => FxStarField(
    key: key,
    count: count,
    color: color,
    speed: speed,
    child: this,
  );
}
