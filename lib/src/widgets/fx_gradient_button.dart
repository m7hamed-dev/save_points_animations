import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A pill button whose gradient slowly rotates, giving a living "aurora" fill.
/// It dips on press. Provide [onPressed] and a [child] (usually a `Text`).
///
/// ```dart
/// FxGradientButton(onPressed: submit, child: const Text('Continue'));
/// ```
class FxGradientButton extends StatefulWidget {
  const FxGradientButton({
    super.key,
    required this.child,
    this.onPressed,
    this.colors = const [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
      Color(0xFFEC008C),
    ],
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    this.borderRadius = 30,
    this.duration = const Duration(seconds: 4),
    this.textColor = const Color(0xFFFFFFFF),
  });

  final Widget child;
  final VoidCallback? onPressed;
  final List<Color> colors;
  final EdgeInsets padding;
  final double borderRadius;
  final Duration duration;
  final Color textColor;

  @override
  State<FxGradientButton> createState() => _FxGradientButtonState();
}

class _FxGradientButtonState extends State<FxGradientButton>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void onReduceMotionChanged(bool reduce) {
    if (reduce) {
      _controller
        ..stop()
        ..value = 0;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed == null) return;
    HapticFeedback.selectionClick();
    widget.onPressed!.call();
  }

  @override
  Widget build(BuildContext context) {
    final loop = [...widget.colors, widget.colors.first];
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      child: RepaintBoundary(
        child: GestureDetector(
          onTapDown: widget.onPressed == null
              ? null
              : (_) => setState(() => _down = true),
          onTapUp: widget.onPressed == null
              ? null
              : (_) => setState(() => _down = false),
          onTapCancel: () => setState(() => _down = false),
          onTap: widget.onPressed == null ? null : _handleTap,
          child: AnimatedScale(
            scale: _down ? 0.95 : 1,
            duration: const Duration(milliseconds: 120),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: .circular(widget.borderRadius),
                    gradient: SweepGradient(
                      colors: loop,
                      transform: GradientRotation(
                        _controller.value * 2 * math.pi,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.colors.first.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: widget.padding,
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
