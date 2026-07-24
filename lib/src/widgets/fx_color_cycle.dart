import 'package:flutter/widgets.dart';

/// Continuously interpolates through a [colors] palette and hands the current
/// color to [builder] — use it for cycling text, borders, glows, or fills.
///
/// ```dart
/// FxColorCycle(
///   colors: const [Colors.red, Colors.orange, Colors.purple],
///   builder: (context, color) => Text('Rainbow', style: TextStyle(color: color)),
/// );
/// ```
class FxColorCycle extends StatefulWidget {
  const FxColorCycle({
    super.key,
    required this.colors,
    required this.builder,
    this.duration = const Duration(seconds: 4),
  });

  final List<Color> colors;
  final Widget Function(BuildContext context, Color color) builder;
  final Duration duration;

  @override
  State<FxColorCycle> createState() => _FxColorCycleState();
}

class _FxColorCycleState extends State<FxColorCycle>
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final n = widget.colors.length;
          if (n == 0) return widget.builder(context, const Color(0xFF000000));
          if (n == 1) return widget.builder(context, widget.colors.first);
          final scaled = _controller.value * n;
          final i = scaled.floor() % n;
          final frac = scaled - scaled.floor();
          final color = Color.lerp(
            widget.colors[i],
            widget.colors[(i + 1) % n],
            frac,
          )!;
          return widget.builder(context, color);
        },
      ),
    );
  }
}
