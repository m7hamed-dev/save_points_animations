import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Split-flap "flip clock" characters — each card flips over (3D) when its
/// character changes. Feed it a time string, a score, anything.
///
/// ```dart
/// FxFlipClock(value: '12:45');
/// ```
class FxFlipClock extends StatelessWidget {
  const FxFlipClock({
    super.key,
    required this.value,
    this.style,
    this.background = const Color(0xFF222222),
    this.duration = const Duration(milliseconds: 450),
  });

  final String value;
  final TextStyle? style;
  final Color background;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < value.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: _FlipCard(
              char: value[i],
              style: style,
              background: background,
              duration: duration,
            ),
          ),
      ],
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({
    required this.char,
    required this.style,
    required this.background,
    required this.duration,
  });

  final String char;
  final TextStyle? style;
  final Color background;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        (style ?? const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
            .copyWith(color: const Color(0xFFFFFFFF));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: .circular(6)),
      child: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, animation) {
          final rotate = Tween<double>(
            begin: math.pi / 2,
            end: 0,
          ).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) => Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(rotate.value),
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
        child: Text(char, key: ValueKey(char), style: textStyle),
      ),
    );
  }
}
