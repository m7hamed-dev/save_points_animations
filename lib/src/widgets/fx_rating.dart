import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// An animated star rating. Tapping a star sets the value and makes it pop.
///
/// Pass [onChanged] to make it interactive; omit it for a read-only display.
///
/// ```dart
/// FxRating(value: rating, onChanged: (v) => setState(() => rating = v));
/// ```
class FxRating extends StatefulWidget {
  const FxRating({
    super.key,
    this.value = 0,
    this.count = 5,
    this.size = 28,
    this.spacing = 2,
    this.color = const Color(0xFFFFC107),
    this.emptyColor = const Color(0xFFCFCFCF),
    this.onChanged,
  });

  final int value;
  final int count;
  final double size;
  final double spacing;
  final Color color;
  final Color emptyColor;
  final ValueChanged<int>? onChanged;

  @override
  State<FxRating> createState() => _FxRatingState();
}

class _FxRatingState extends State<FxRating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _popped = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  void _select(int index) {
    if (widget.onChanged == null) return;
    HapticFeedback.selectionClick();
    setState(() => _popped = index);
    if (!fxReduceMotion(context)) {
      _controller.forward(from: 0);
    }
    widget.onChanged!(index + 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.count; i++)
            Semantics(
              button: widget.onChanged != null,
              label: 'Rate ${i + 1}',
              selected: i < widget.value,
              child: GestureDetector(
                onTap: () => _select(i),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.spacing),
                  child: _star(i),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _star(int i) {
    final star = CustomPaint(
      size: Size.square(widget.size),
      painter: _StarPainter(
        filled: i < widget.value,
        color: widget.color,
        emptyColor: widget.emptyColor,
      ),
    );
    // Only the star that just popped listens to the controller, so the other
    // stars aren't rebuilt on every animation tick.
    if (i != _popped) return star;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1 + math.sin(_controller.value * math.pi) * 0.4;
        return Transform.scale(scale: scale, child: child);
      },
      child: star,
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({
    required this.filled,
    required this.color,
    required this.emptyColor,
  });

  final bool filled;
  final Color color;
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.shortestSide / 2;
    final inner = outer * 0.4;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = filled ? color : emptyColor);
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) =>
      oldDelegate.filled != filled ||
      oldDelegate.color != color ||
      oldDelegate.emptyColor != emptyColor;
}
