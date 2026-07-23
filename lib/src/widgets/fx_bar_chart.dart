import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A simple bar chart whose bars grow to their values (and re-animate whenever
/// the values change).
///
/// ```dart
/// FxBarChart(values: const [4, 7, 3, 9, 6]);
/// ```
class FxBarChart extends StatelessWidget {
  const FxBarChart({
    super.key,
    required this.values,
    this.color = const Color(0xFF448AFF),
    this.height = 120,
    this.spacing = 8,
    this.borderRadius = 4,
    this.duration = const Duration(milliseconds: 700),
  });

  final List<double> values;
  final Color color;
  final double height;
  final double spacing;
  final double borderRadius;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty ? 1.0 : values.reduce(math.max);
    final safeMax = maxV == 0 ? 1.0 : maxV;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: (values[i] / safeMax).clamp(0.0, 1.0)),
                duration: duration,
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: v,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(borderRadius),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
