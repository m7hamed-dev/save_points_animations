import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// Triggers confetti bursts on an [FxConfetti].
class FxConfettiController extends ChangeNotifier {
  int _bursts = 0;

  /// How many bursts have been requested (changes on each [play]).
  int get bursts => _bursts;

  /// Fire a confetti burst.
  void play() {
    _bursts++;
    notifyListeners();
  }
}

/// Overlays a confetti particle burst above [child].
///
/// The burst is pure decoration, so when the platform asks for reduced motion
/// ([fxReduceMotion]) bursts are skipped and one already in flight is cleared;
/// [child] is shown as usual.
class FxConfetti extends StatefulWidget {
  const FxConfetti({
    super.key,
    required this.child,
    this.controller,
    this.particleCount = 30,
    this.colors = const [
      Color(0xFFE53935),
      Color(0xFF43A047),
      Color(0xFF1E88E5),
      Color(0xFFFDD835),
      Color(0xFF8E24AA),
    ],
    this.duration = const Duration(milliseconds: 1400),
    this.playOnStart = false,
    this.seed,
  });

  final Widget child;

  /// Fire bursts imperatively; if null, use [playOnStart].
  final FxConfettiController? controller;
  final int particleCount;
  final List<Color> colors;
  final Duration duration;
  final bool playOnStart;

  /// Optional seed for the random burst, so it's reproducible.
  /// When null (the default) the burst is random each time.
  final int? seed;

  @override
  State<FxConfetti> createState() => _FxConfettiState();
}

class _FxConfettiState extends State<FxConfetti>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _anim;
  late final math.Random _random = math.Random(widget.seed);
  List<_Particle> _particles = const [];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: widget.duration);
    widget.controller?.addListener(_burst);
    if (widget.playOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _burst();
      });
    }
  }

  @override
  void didUpdateWidget(covariant FxConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_burst);
      widget.controller?.addListener(_burst);
    }
  }

  @override
  void onReduceMotionChanged(bool reduceMotion) {
    // Clears a burst in flight: the painter draws nothing at t == 0.
    if (reduceMotion) _anim.value = 0;
  }

  void _burst() {
    if (reduceMotion) return;
    _particles = List.generate(widget.particleCount, (_) {
      final angle = -math.pi / 2 + (_random.nextDouble() - 0.5) * math.pi;
      return _Particle(
        angle: angle,
        speed: 0.4 + _random.nextDouble() * 0.6,
        color: widget.colors[_random.nextInt(widget.colors.length)],
        size: 5 + _random.nextDouble() * 6,
        spin: (_random.nextDouble() - 0.5) * 12,
      );
    });
    _anim.forward(from: 0);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_burst);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(_particles, _anim.value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.spin,
  });

  final double angle;
  final double speed;
  final Color color;
  final double size;
  final double spin;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t);

  final List<_Particle> particles;
  final double t;

  // One Paint reused for every particle every frame; only its color is mutated.
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0 || particles.isEmpty) return;
    final origin = Offset(size.width / 2, size.height / 2);
    final gravity = size.height * 1.2;
    // Eased fade (quadratic) reads more natural than a linear ramp.
    final alpha = 1 - t * t;

    for (final p in particles) {
      final dx = math.cos(p.angle) * p.speed * size.width * t;
      final dy =
          math.sin(p.angle) * p.speed * size.height * t + 0.5 * gravity * t * t;
      final pos = origin + Offset(dx, dy);
      _paint.color = p.color.withValues(alpha: alpha);

      canvas
        ..save()
        ..translate(pos.dx, pos.dy)
        ..rotate(p.spin * t)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          _paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.particles != particles;
}
