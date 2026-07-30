import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// An ambient field of slowly drifting particles — a subtle living backdrop
/// for hero sections, splash screens, or empty states.
///
/// ```dart
/// FxParticles(child: const Center(child: Text('Welcome')));
/// ```
class FxParticles extends StatefulWidget {
  const FxParticles({
    super.key,
    this.count = 30,
    this.color = const Color(0x33FFFFFF),
    this.maxRadius = 3,
    this.speed = 0.03,
    this.seed,
    this.child,
  });

  final int count;
  final Color color;
  final double maxRadius;

  /// Drift speed in fractions of the box per second.
  final double speed;

  /// Optional seed for the random layout, so it's reproducible.
  /// When null (the default) the layout is random each time.
  final int? seed;
  final Widget? child;

  @override
  State<FxParticles> createState() => _FxParticlesState();
}

class _FxParticlesState extends State<FxParticles>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final math.Random _random = math.Random(widget.seed);
  late final Ticker _ticker;
  late List<_Particle> _particles;
  Duration _last = Duration.zero;

  // Bumped each tick to drive the painter's `repaint:` without rebuilding the
  // widget subtree (the particle list is mutated in place).
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _particles = List.generate(widget.count, (_) {
      return _Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        vx: (_random.nextDouble() - 0.5) * widget.speed,
        vy: (_random.nextDouble() - 0.5) * widget.speed,
        radius: 1 + _random.nextDouble() * widget.maxRadius,
      );
    });
    _ticker.start();
  }

  @override
  void onReduceMotionChanged(bool reduce) {
    if (reduce) {
      _ticker.stop();
    } else if (!_ticker.isTicking) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    for (final p in _particles) {
      p.x = (p.x + p.vx * dt + 1) % 1;
      p.y = (p.y + p.vy * dt + 1) % 1;
    }
    _frame.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(
                  _particles,
                  widget.color,
                  repaint: _frame,
                ),
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
  });

  double x;
  double y;
  final double vx;
  final double vy;
  final double radius;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.color, {required Listenable repaint})
    : super(repaint: repaint);

  final List<_Particle> particles;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final p in particles) {
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.particles != particles;
}
