import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// A rounded progress bar that animates smoothly toward [value], or sweeps
/// continuously when [value] is null (indeterminate).
///
/// Honors the platform "reduce motion" setting: the indeterminate sweep holds
/// still as a centered segment and value changes jump instead of easing.
///
/// ```dart
/// FxProgressBar(value: 0.6);          // animates when value changes
/// const FxProgressBar();              // indeterminate sweep
/// ```
class FxProgressBar extends StatefulWidget {
  const FxProgressBar({
    super.key,
    this.value,
    this.height = 8,
    this.radius = 8,
    this.color = const Color(0xFF448AFF),
    this.backgroundColor = const Color(0x22448AFF),
    this.gradient,
    this.duration = const Duration(milliseconds: 400),
  });

  /// Progress in `0..1`, or null for an indeterminate sweep.
  final double? value;
  final double height;
  final double radius;
  final Color color;
  final Color backgroundColor;

  /// Optional gradient fill (overrides [color]).
  final Gradient? gradient;
  final Duration duration;

  @override
  State<FxProgressBar> createState() => _FxProgressBarState();
}

class _FxProgressBarState extends State<FxProgressBar>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FxMotionAware only reports reduce-motion *flips*; sync once the flag is
    // known so the first indeterminate sweep starts (or settles) here.
    _sync();
  }

  @override
  void onReduceMotionChanged(bool reduceMotion) => _sync();

  @override
  void didUpdateWidget(covariant FxProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.value == null) != (oldWidget.value == null)) _sync();
  }

  // The indeterminate sweep runs only while there is no value and motion is
  // allowed. Under reduced motion it settles to a static, centered segment.
  void _sync() {
    if (widget.value != null) {
      _controller.stop();
    } else if (reduceMotion) {
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _fill() => widget.gradient != null
      ? DecoratedBox(decoration: BoxDecoration(gradient: widget.gradient))
      : ColoredBox(color: widget.color);

  @override
  Widget build(BuildContext context) {
    final bar = RepaintBoundary(
      child: ClipRRect(
        borderRadius: .circular(widget.radius),
        child: SizedBox(
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: widget.backgroundColor),
              if (widget.value != null)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: widget.value!.clamp(0.0, 1.0)),
                  // Reduced motion: jump straight to the new value.
                  duration: reduceMotion ? Duration.zero : widget.duration,
                  curve: Curves.easeOutCubic,
                  builder: (context, v, child) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(widthFactor: v, child: child),
                  ),
                  child: _fill(),
                )
              else
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Align(
                    alignment: Alignment(_controller.value * 2 - 1, 0),
                    child: FractionallySizedBox(widthFactor: 0.3, child: child),
                  ),
                  child: _fill(),
                ),
            ],
          ),
        ),
      ),
    );
    final value = widget.value;
    if (value == null) return bar;
    return Semantics(
      value: '${(value.clamp(0.0, 1.0) * 100).round()}%',
      child: bar,
    );
  }
}
