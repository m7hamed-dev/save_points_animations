import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// Glowing neon-sign text with a subtle, irregular flicker.
///
/// ```dart
/// FxNeonText('OPEN', color: const Color(0xFFFF3CAC));
/// ```
class FxNeonText extends StatefulWidget {
  const FxNeonText(
    this.text, {
    super.key,
    this.color = const Color(0xFF00E5FF),
    this.style,
    this.flicker = true,
    this.duration = const Duration(milliseconds: 2400),
  });

  final String text;
  final Color color;
  final TextStyle? style;
  final bool flicker;
  final Duration duration;

  @override
  State<FxNeonText> createState() => _FxNeonTextState();
}

class _FxNeonTextState extends State<FxNeonText>
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
    // FxMotionAware only reports reduce-motion *flips*, so start the first
    // flicker loop here once the flag is known.
    if (!_kicked) {
      _kicked = true;
      _sync();
    }
  }

  @override
  void onReduceMotionChanged(bool reduceMotion) => _sync();

  @override
  void didUpdateWidget(covariant FxNeonText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      if (_controller.isAnimating) _controller.repeat();
    }
    if (widget.flicker != oldWidget.flicker) _sync();
  }

  void _sync() {
    if (reduceMotion || !widget.flicker) {
      // Settle to a static, fully-bright frame.
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Mostly bright with occasional quick dips.
  double _intensity(double t) {
    final flick = math.sin(t * 2 * math.pi * 7) * math.sin(t * 2 * math.pi * 3);
    final dip = flick > 0.85 ? 0.4 : 0.0;
    return (1 - dip).clamp(0.4, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final i = (widget.flicker && !reduceMotion)
              ? _intensity(_controller.value)
              : 1.0;
          final base = (widget.style ?? const TextStyle(fontSize: 32)).copyWith(
            color: const Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          );
          return Text(
            widget.text,
            style: base.copyWith(
              shadows: [
                for (final blur in const [6.0, 14.0, 26.0])
                  Shadow(
                    color: widget.color.withValues(alpha: i),
                    blurRadius: blur * i,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
