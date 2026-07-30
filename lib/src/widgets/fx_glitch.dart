import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

const List<double> _redMatrix = [
  1, 0, 0, 0, 0, //
  0, 0, 0, 0, 0, //
  0, 0, 0, 0, 0, //
  0, 0, 0, 1, 0, //
];

const List<double> _cyanMatrix = [
  0, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// A looping RGB-split "glitch" effect that spikes intermittently — trendy for
/// headers, avatars, and cyberpunk/retro UIs.
///
/// ```dart
/// FxGlitch(child: Text('SYSTEM', style: bigStyle));
/// ```
class FxGlitch extends StatefulWidget {
  const FxGlitch({
    super.key,
    required this.child,
    this.intensity = 4,
    this.duration = const Duration(milliseconds: 1600),
  });

  final Widget child;

  /// Peak channel offset in logical pixels during a glitch spike.
  final double intensity;
  final Duration duration;

  @override
  State<FxGlitch> createState() => _FxGlitchState();
}

class _FxGlitchState extends State<FxGlitch>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void onReduceMotionChanged(bool reduce) {
    if (reduce) {
      // Rapid RGB-split flashing is a photosensitivity hazard: fully stop and
      // reset so no split frame lingers.
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

  // A decaying spike a few times per loop.
  double _burst(double t) {
    final phase = (t * 4) % 1;
    return phase < 0.12 ? (1 - phase / 0.12) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          // Reduced motion: render the un-split, static frame only.
          if (reduceMotion) return child!;
          final b = _burst(_controller.value);
          final dx = math.sin(_controller.value * 80) * widget.intensity * b;
          final dy = b * widget.intensity * 0.4;
          return Stack(
            children: [
              child!,
              if (b > 0.01) ...[
                Opacity(
                  opacity: 0.7,
                  child: Transform.translate(
                    offset: Offset(-dx, 0),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(_redMatrix),
                      child: child,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.7,
                  child: Transform.translate(
                    offset: Offset(dx, dy),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(_cyanMatrix),
                      child: child,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
