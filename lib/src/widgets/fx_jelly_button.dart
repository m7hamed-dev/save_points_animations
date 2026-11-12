import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';
import 'package:save_points_animations/src/widgets/fx_focusable.dart';

/// A button that **wobbles like jelly** when tapped — a quick decaying
/// squash-and-skew that makes taps feel springy. Pass `null` for [onPressed]
/// to render a dimmed, disabled state.
///
/// Fires a light haptic on tap and honors "reduce motion" (it just dips
/// instead of wobbling). While enabled it is keyboard-focusable and Enter /
/// Space press it.
///
/// ```dart
/// FxJellyButton(onPressed: send, child: const Text('Send'));
/// ```
class FxJellyButton extends StatefulWidget {
  const FxJellyButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color = const Color(0xFF6A5AE0),
    this.textColor = const Color(0xFFFFFFFF),
    this.padding = const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
    this.borderRadius = 18,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final EdgeInsets padding;
  final double borderRadius;

  /// Duration of the jelly wobble after a tap.
  final Duration duration;

  @override
  State<FxJellyButton> createState() => _FxJellyButtonState();
}

class _FxJellyButtonState extends State<FxJellyButton>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant FxJellyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    if (!reduceMotion) _controller.forward(from: 0);
    widget.onPressed!.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      // Focusable (and Enter / Space activate it) only while enabled.
      child: FxFocusableControl(
        enabled: enabled,
        onActivate: _handleTap,
        builder: (context, showFocus) => Opacity(
          opacity: enabled ? 1 : 0.5,
          child: RepaintBoundary(
            child: GestureDetector(
              onTapDown: enabled ? (_) => setState(() => _down = true) : null,
              onTapUp: enabled ? (_) => setState(() => _down = false) : null,
              onTapCancel: () => setState(() => _down = false),
              onTap: enabled ? _handleTap : null,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  // Decaying skew + squash wobble.
                  final wobble = math.sin(t * math.pi * 3) * (1 - t);
                  final press = _down ? 0.06 : 0.0;
                  final sx = 1 + wobble * 0.08 - press;
                  final sy = 1 - wobble * 0.08 + press;
                  final matrix = Matrix4.identity()
                    ..setEntry(0, 0, sx)
                    ..setEntry(1, 1, sy)
                    ..setEntry(0, 1, wobble * 0.12);
                  return Transform(
                    alignment: Alignment.center,
                    transform: matrix,
                    child: child,
                  );
                },
                child: FxFocusRing(
                  visible: showFocus,
                  color: widget.color,
                  borderRadius: .circular(widget.borderRadius),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: .circular(widget.borderRadius),
                    ),
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
          ),
        ),
      ),
    );
  }
}
