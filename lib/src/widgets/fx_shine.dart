import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// A glossy diagonal light band that sweeps across [child] — the "card shine"
/// gloss for buttons, badges, and cards.
///
/// ```dart
/// FxShine(child: myButton);          // repeating gloss
/// FxShine(loop: false, child: card); // a single sweep
/// ```
class FxShine extends StatefulWidget {
  const FxShine({
    super.key,
    required this.child,
    this.color = const Color(0xAAFFFFFF),
    this.duration = const Duration(milliseconds: 1800),
    this.bandWidth = 0.16,
    this.loop = true,
  });

  final Widget child;

  /// The highlight color of the sweeping band.
  final Color color;
  final Duration duration;

  /// Width of the gloss band as a fraction of the diagonal.
  final double bandWidth;
  final bool loop;

  @override
  State<FxShine> createState() => _FxShineState();
}

class _FxShineState extends State<FxShine>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;
  bool _kicked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The mixin only calls onReduceMotionChanged when the flag *flips*, so kick
    // off the initial (non-reduced) run once the context is available.
    if (!_kicked && !reduceMotion) {
      _kicked = true;
      _play();
    }
  }

  void _play() {
    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  // Reacting to reduce-motion *changes* (not just once at mount) means toggling
  // the OS setting at runtime starts/stops the gloss immediately.
  @override
  void onReduceMotionChanged(bool reduceMotion) {
    if (reduceMotion) {
      _controller.stop();
    } else {
      _kicked = true;
      _play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final w = widget.bandWidth;
          final center = _controller.value * (1 + 2 * w) - w;
          final s0 = (center - w).clamp(0.0, 1.0);
          final s1 = center.clamp(0.0, 1.0);
          final s2 = (center + w).clamp(0.0, 1.0);
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withValues(alpha: 0),
                widget.color,
                widget.color.withValues(alpha: 0),
              ],
              stops: [s0, s1, s2],
            ).createShader(bounds),
            child: child,
          );
        },
      ),
    );
  }
}
