import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The classic chat "typing…" indicator — three dots pulsing in sequence,
/// optionally inside a chat bubble.
///
/// ```dart
/// const FxTypingIndicator();
/// ```
class FxTypingIndicator extends StatefulWidget {
  const FxTypingIndicator({
    super.key,
    this.color = const Color(0xFF9E9E9E),
    this.bubbleColor = const Color(0xFFEEEEEE),
    this.dotSize = 8,
    this.dotCount = 3,
    this.showBubble = true,
    this.duration = const Duration(milliseconds: 1000),
  });

  final Color color;
  final Color bubbleColor;
  final double dotSize;
  final int dotCount;
  final bool showBubble;
  final Duration duration;

  @override
  State<FxTypingIndicator> createState() => _FxTypingIndicatorState();
}

class _FxTypingIndicatorState extends State<FxTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.dotCount; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.25),
              child: _dot(i),
            ),
        ],
      ),
    );

    if (!widget.showBubble) return RepaintBoundary(child: dots);

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.dotSize * 1.4,
          vertical: widget.dotSize,
        ),
        decoration: BoxDecoration(
          color: widget.bubbleColor,
          borderRadius: .circular(widget.dotSize * 2),
        ),
        child: dots,
      ),
    );
  }

  Widget _dot(int index) {
    final phase = _controller.value * 2 * math.pi - index * 0.6;
    final wave = (math.sin(phase) + 1) / 2; // 0..1
    final scale = 0.7 + wave * 0.5;
    return Opacity(
      opacity: 0.4 + wave * 0.6,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: widget.dotSize,
          height: widget.dotSize,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
