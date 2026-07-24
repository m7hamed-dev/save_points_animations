import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Periodic firework bursts over [child] — celebratory particles that radiate,
/// arc under gravity, and fade.
///
/// ```dart
/// FxFireworks(child: const Center(child: Text('Congrats!')));
/// ```
class FxFireworks extends StatefulWidget {
  const FxFireworks({
    super.key,
    this.colors = const [
      Color(0xFFE53935),
      Color(0xFF43A047),
      Color(0xFF1E88E5),
      Color(0xFFFDD835),
      Color(0xFF8E24AA),
    ],
    this.interval = const Duration(milliseconds: 850),
    this.particlesPerBurst = 26,
    this.child,
  });

  final List<Color> colors;
  final Duration interval;
  final int particlesPerBurst;
  final Widget? child;

  @override
  State<FxFireworks> createState() => _FxFireworksState();
}

class _FxFireworksState extends State<FxFireworks>
    with SingleTickerProviderStateMixin {
  final math.Random _random = math.Random();
  late final Ticker _ticker;
  final List<_Burst> _bursts = [];
  double _now = 0;
  double _lastSpawn = 0;
  static const double _life = 1.5;

  // Bumped each tick to drive the painter's `repaint:` without rebuilding the
  // widget subtree (the burst list is mutated in place).
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
        _ticker.start();
      }
    });
  }

  void _tick(Duration elapsed) {
    _now = elapsed.inMicroseconds / 1e6;
    final intervalS = widget.interval.inMicroseconds / 1e6;
    if (_now - _lastSpawn >= intervalS) {
      _lastSpawn = _now;
      _spawn();
    }
    _bursts.removeWhere((b) => _now - b.birth > _life);
    _frame.value++;
  }

  void _spawn() {
    final color = widget.colors[_random.nextInt(widget.colors.length)];
    _bursts.add(
      _Burst(
        birth: _now,
        center: Offset(
          0.15 + _random.nextDouble() * 0.7,
          0.15 + _random.nextDouble() * 0.45,
        ),
        color: color,
        particles: List.generate(widget.particlesPerBurst, (i) {
          final angle = i / widget.particlesPerBurst * 2 * math.pi;
          return _Spark(angle: angle, speed: 0.2 + _random.nextDouble() * 0.2);
        }),
      ),
    );
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
                painter: _FireworksPainter(
                  bursts: _bursts,
                  now: _now,
                  life: _life,
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

class _Spark {
  const _Spark({required this.angle, required this.speed});
  final double angle;
  final double speed;
}

class _Burst {
  const _Burst({
    required this.birth,
    required this.center,
    required this.color,
    required this.particles,
  });
  final double birth;
  final Offset center;
  final Color color;
  final List<_Spark> particles;
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter({
    required this.bursts,
    required this.now,
    required this.life,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<_Burst> bursts;
  final double now;
  final double life;

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bursts) {
      final t = ((now - b.birth) / life).clamp(0.0, 1.0);
      final origin = Offset(
        b.center.dx * size.width,
        b.center.dy * size.height,
      );
      final paint = Paint()..color = b.color.withValues(alpha: 1 - t);
      final spread = size.shortestSide;
      for (final s in b.particles) {
        final dist = s.speed * spread * t;
        final gravity = 0.5 * spread * t * t;
        final pos =
            origin +
            Offset(
              math.cos(s.angle) * dist,
              math.sin(s.angle) * dist + gravity,
            );
        canvas.drawCircle(pos, 2.2 * (1 - t), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_FireworksPainter oldDelegate) =>
      oldDelegate.bursts != bursts ||
      oldDelegate.now != now ||
      oldDelegate.life != life;
}
