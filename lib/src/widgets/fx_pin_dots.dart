import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// An animated PIN / OTP progress indicator — filled dots pop as digits are
/// entered, and the whole row shakes on [error].
///
/// ```dart
/// FxPinDots(length: 4, filled: enteredCount, error: wrong);
/// ```
class FxPinDots extends StatefulWidget {
  const FxPinDots({
    super.key,
    required this.length,
    required this.filled,
    this.size = 16,
    this.spacing = 10,
    this.color = const Color(0xFF448AFF),
    this.inactiveColor = const Color(0x33448AFF),
    this.errorColor = const Color(0xFFE53935),
    this.error = false,
  });

  final int length;
  final int filled;
  final double size;
  final double spacing;
  final Color color;
  final Color inactiveColor;
  final Color errorColor;
  final bool error;

  @override
  State<FxPinDots> createState() => _FxPinDotsState();
}

class _FxPinDotsState extends State<FxPinDots> with TickerProviderStateMixin {
  late final AnimationController _pop;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant FxPinDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reduceMotion = fxReduceMotion(context);
    if (widget.filled > oldWidget.filled && !reduceMotion) {
      _pop.forward(from: 0);
    }
    if (widget.error && !oldWidget.error && !reduceMotion) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.length; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
            child: _dot(i),
          ),
      ],
    );
    // Only the outer translate listens to the shake controller, so the whole
    // row isn't rebuilt for the per-dot pop (each dot listens to _pop itself).
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) {
          final shakeX =
              math.sin(_shake.value * math.pi * 4) * 8 * (1 - _shake.value);
          return Transform.translate(offset: Offset(shakeX, 0), child: child);
        },
        child: row,
      ),
    );
  }

  Widget _dot(int i) {
    final isFilled = i < widget.filled;
    final isLastFilled = i == widget.filled - 1;
    final color = widget.error
        ? widget.errorColor
        : (isFilled ? widget.color : widget.inactiveColor);
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    // Only the currently-popping dot rebuilds on each _pop tick.
    if (!isLastFilled) return dot;
    return AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        final scale = 1 + math.sin(_pop.value * math.pi) * 0.4;
        return Transform.scale(scale: scale, child: child);
      },
      child: dot,
    );
  }
}
