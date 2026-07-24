import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void didUpdateWidget(covariant FxPinDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filled > oldWidget.filled) _pop.forward(from: 0);
    if (widget.error && !oldWidget.error) _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _pop.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_pop, _shake]),
        builder: (context, _) {
          final shakeX =
              math.sin(_shake.value * math.pi * 4) * 8 * (1 - _shake.value);
          return Transform.translate(
            offset: Offset(shakeX, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.length; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.spacing / 2,
                    ),
                    child: _dot(i),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dot(int i) {
    final isFilled = i < widget.filled;
    final isLastFilled = i == widget.filled - 1;
    final scale = isLastFilled ? 1 + math.sin(_pop.value * math.pi) * 0.4 : 1.0;
    final color = widget.error
        ? widget.errorColor
        : (isFilled ? widget.color : widget.inactiveColor);
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
