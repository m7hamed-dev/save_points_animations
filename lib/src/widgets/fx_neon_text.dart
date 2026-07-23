import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Glowing neon-sign text with a subtle, irregular flicker.
///
/// ```dart
/// FxNeonText('OPEN', color: const Color(0xFFFF3CAC));
/// ```
class FxNeonText extends StatefulWidget {
  const FxNeonText(
    this.text, {
    super.key,
    this.color = const Color(0xFF00E5FF),
    this.style,
    this.flicker = true,
    this.duration = const Duration(milliseconds: 2400),
  });

  final String text;
  final Color color;
  final TextStyle? style;
  final bool flicker;
  final Duration duration;

  @override
  State<FxNeonText> createState() => _FxNeonTextState();
}

class _FxNeonTextState extends State<FxNeonText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.flicker) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Mostly bright with occasional quick dips.
  double _intensity(double t) {
    final flick = math.sin(t * 2 * math.pi * 7) * math.sin(t * 2 * math.pi * 3);
    final dip = flick > 0.85 ? 0.4 : 0.0;
    return (1 - dip).clamp(0.4, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final i = widget.flicker ? _intensity(_controller.value) : 1.0;
        final base = (widget.style ?? const TextStyle(fontSize: 32)).copyWith(
          color: const Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        );
        return Text(
          widget.text,
          style: base.copyWith(
            shadows: [
              for (final blur in const [6.0, 14.0, 26.0])
                Shadow(
                  color: widget.color.withValues(alpha: i),
                  blurRadius: blur * i,
                ),
            ],
          ),
        );
      },
    );
  }
}
