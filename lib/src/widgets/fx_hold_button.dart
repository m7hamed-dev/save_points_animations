import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Press and hold to confirm — a ring fills while held and fires [onConfirmed]
/// when complete; releasing early rewinds it. Good for destructive actions.
///
/// ```dart
/// FxHoldButton(onConfirmed: delete, child: const Icon(Icons.delete));
/// ```
class FxHoldButton extends StatefulWidget {
  const FxHoldButton({
    super.key,
    required this.child,
    required this.onConfirmed,
    this.holdDuration = const Duration(milliseconds: 1200),
    this.size = 64,
    this.color = const Color(0xFF448AFF),
    this.backgroundColor = const Color(0x22448AFF),
    this.strokeWidth = 4,
  });

  final Widget child;
  final VoidCallback onConfirmed;
  final Duration holdDuration;
  final double size;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  State<FxHoldButton> createState() => _FxHoldButtonState();
}

class _FxHoldButtonState extends State<FxHoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
        widget.onConfirmed();
        _controller.reset();
      }
    });
  }

  void _start() => _controller.forward();

  void _cancel() {
    if (!_controller.isCompleted) _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: RepaintBoundary(
        child: GestureDetector(
          onTapDown: (_) => _start(),
          onTapUp: (_) => _cancel(),
          onTapCancel: _cancel,
          child: SizedBox.square(
            dimension: widget.size,
            child: CustomPaint(
              painter: _HoldRingPainter(
                repaint: _controller,
                animation: _controller,
                color: widget.color,
                backgroundColor: widget.backgroundColor,
                strokeWidth: widget.strokeWidth,
              ),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

class _HoldRingPainter extends CustomPainter {
  _HoldRingPainter({
    required super.repaint,
    required this.animation,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final Animation<double> animation;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(_HoldRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
