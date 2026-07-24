import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A "like" heart that pops and emits a small burst when toggled on.
///
/// ```dart
/// FxHeartButton(isLiked: liked, onChanged: (v) => setState(() => liked = v));
/// ```
class FxHeartButton extends StatefulWidget {
  const FxHeartButton({
    super.key,
    required this.isLiked,
    required this.onChanged,
    this.size = 32,
    this.color = const Color(0xFFE53935),
    this.inactiveColor = const Color(0xFFBDBDBD),
  });

  final bool isLiked;
  final ValueChanged<bool> onChanged;
  final double size;
  final Color color;
  final Color inactiveColor;

  @override
  State<FxHeartButton> createState() => _FxHeartButtonState();
}

class _FxHeartButtonState extends State<FxHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  void _tap() {
    final next = !widget.isLiked;
    widget.onChanged(next);
    if (next) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tap,
        child: SizedBox.square(
          dimension: widget.size * 1.8,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final v = _controller.value;
              final scale = 1 + math.sin(v.clamp(0.0, 1.0) * math.pi) * 0.45;
              return CustomPaint(
                painter: _BurstPainter(progress: v, color: widget.color),
                child: Center(
                  child: Transform.scale(
                    scale: widget.isLiked ? scale : 1.0,
                    child: CustomPaint(
                      size: Size.square(widget.size),
                      painter: _HeartPainter(
                        color: widget.isLiked
                            ? widget.color
                            : widget.inactiveColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.36)
      ..cubicTo(w * 0.5, h * 0.28, w * 0.35, h * 0.08, w * 0.19, h * 0.24)
      ..cubicTo(w * 0.02, h * 0.42, w * 0.14, h * 0.68, w * 0.5, h * 0.92)
      ..cubicTo(w * 0.86, h * 0.68, w * 0.98, h * 0.42, w * 0.81, h * 0.24)
      ..cubicTo(w * 0.65, h * 0.08, w * 0.5, h * 0.28, w * 0.5, h * 0.36)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_HeartPainter oldDelegate) => oldDelegate.color != color;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - progress) * 0.8);
    const dots = 8;
    for (var i = 0; i < dots; i++) {
      final angle = i / dots * 2 * math.pi;
      final r = maxR * progress;
      final pos = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      canvas.drawCircle(pos, 2.5 * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
