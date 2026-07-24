import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A soft radial spotlight that drifts over [child] (or follows the pointer),
/// adding a moving highlight. Best over darker content.
///
/// ```dart
/// FxSpotlight(child: const Card(child: SizedBox(height: 120)));
/// ```
class FxSpotlight extends StatefulWidget {
  const FxSpotlight({
    super.key,
    required this.child,
    this.color = const Color(0x55FFFFFF),
    this.radius = 0.5,
    this.duration = const Duration(seconds: 6),
    this.followPointer = false,
  });

  final Widget child;
  final Color color;

  /// Highlight radius as a fraction of the shortest side.
  final double radius;
  final Duration duration;
  final bool followPointer;

  @override
  State<FxSpotlight> createState() => _FxSpotlightState();
}

class _FxSpotlightState extends State<FxSpotlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();
  Alignment _pointer = Alignment.center;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final overlay = Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final align = widget.followPointer
                    ? _pointer
                    : Alignment(
                        math.sin(_controller.value * 2 * math.pi),
                        math.cos(_controller.value * 2 * math.pi * 1.3),
                      );
                return CustomPaint(
                  painter: _SpotPainter(
                    align: align,
                    color: widget.color,
                    radius: widget.radius,
                  ),
                );
              },
            ),
          ),
        );

        final stack = Stack(
          fit: StackFit.passthrough,
          children: [widget.child, overlay],
        );

        if (!widget.followPointer) return stack;

        final size = constraints.biggest;
        return MouseRegion(
          onHover: (event) {
            if (size.isEmpty) return;
            setState(() {
              _pointer = Alignment(
                (event.localPosition.dx / size.width) * 2 - 1,
                (event.localPosition.dy / size.height) * 2 - 1,
              );
            });
          },
          child: stack,
        );
        },
      ),
    );
  }
}

class _SpotPainter extends CustomPainter {
  _SpotPainter({
    required this.align,
    required this.color,
    required this.radius,
  });

  final Alignment align;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        size.center(Offset.zero) +
        Offset(align.x * size.width / 2, align.y * size.height / 2);
    final r = radius * size.shortestSide;
    final shader = RadialGradient(
      colors: [color, color.withValues(alpha: 0)],
    ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(_SpotPainter oldDelegate) =>
      oldDelegate.align != align ||
      oldDelegate.color != color ||
      oldDelegate.radius != radius;
}
