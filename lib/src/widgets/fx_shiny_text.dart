import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// Text with a bright **sheen that sweeps across it** — a metallic / "shiny"
/// highlight repeatedly travels over the glyphs. Unlike `FxGradientText` (a
/// full moving gradient fill) or `FxShine` (a gloss band over a box), the base
/// text keeps its color and only a moving highlight passes through.
///
/// Honors "reduce motion" (the sheen holds still) and repaints in isolation.
///
/// ```dart
/// FxShinyText('PREMIUM', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800));
/// ```
class FxShinyText extends StatefulWidget {
  const FxShinyText(
    this.text, {
    super.key,
    this.style,
    this.shineColor = const Color(0xFFFFFFFF),
    this.band = 0.18,
    this.duration = const Duration(milliseconds: 2200),
  });

  final String text;

  /// Base text style; its `color` (or black) is the resting glyph color.
  final TextStyle? style;

  /// Color of the travelling highlight.
  final Color shineColor;

  /// Half-width of the highlight band, as a fraction of the text width.
  final double band;

  /// Time for one sweep (plus its pause off-screen).
  final Duration duration;

  @override
  State<FxShinyText> createState() => _FxShinyTextState();
}

class _FxShinyTextState extends State<FxShinyText>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant FxShinyText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      if (_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void onReduceMotionChanged(bool reduce) {
    if (reduce) {
      _controller
        ..stop()
        ..value = 0;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.style?.color ?? const Color(0xFF000000);
    final band = widget.band.clamp(0.02, 0.45);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: Text(widget.text, style: widget.style),
        builder: (context, child) {
          // The highlight centre travels from off the left edge to off the
          // right edge so the sweep fully enters and exits.
          final centre = _controller.value * (1 + 2 * band) - band;
          final s0 = (centre - band).clamp(0.0, 1.0);
          final s1 = centre.clamp(0.0, 1.0);
          final s2 = (centre + band).clamp(0.0, 1.0);
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => LinearGradient(
              colors: [base, widget.shineColor, base],
              stops: [s0, s1, s2],
            ).createShader(rect),
            child: child,
          );
        },
      ),
    );
  }
}
