import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A solid pill button wrapped in a soft **glow halo that breathes** — the
/// shadow blur and spread pulse continuously to draw the eye, and the button
/// dips on press. Pass `null` for [onPressed] to render a dimmed, disabled
/// state.
///
/// Honors the platform "reduce motion" setting (the glow holds steady) and
/// fires a light haptic on tap.
///
/// ```dart
/// FxGlowButton(onPressed: buy, child: const Text('Get Pro'));
/// ```
class FxGlowButton extends StatefulWidget {
  const FxGlowButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color = const Color(0xFF2575FC),
    this.glowColor,
    this.textColor = const Color(0xFFFFFFFF),
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    this.borderRadius = 30,
    this.duration = const Duration(milliseconds: 1800),
  });

  final Widget child;
  final VoidCallback? onPressed;

  /// Fill color of the pill.
  final Color color;

  /// Halo color; defaults to [color] when null.
  final Color? glowColor;
  final Color textColor;
  final EdgeInsets padding;
  final double borderRadius;

  /// Time for one full breathe (in-and-out) of the glow.
  final Duration duration;

  @override
  State<FxGlowButton> createState() => _FxGlowButtonState();
}

class _FxGlowButtonState extends State<FxGlowButton>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant FxGlowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      if (_controller.isAnimating) _controller.repeat(reverse: true);
    }
  }

  @override
  void onReduceMotionChanged(bool reduce) {
    if (reduce) {
      _controller
        ..stop()
        ..value = 0.5; // Hold at a mid, steady glow.
    } else {
      _controller.repeat(reverse: true);
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
    final enabled = widget.onPressed != null;
    final glow = widget.glowColor ?? widget.color;
    return Semantics(
      button: true,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: RepaintBoundary(
          child: GestureDetector(
            onTapDown: enabled ? (_) => setState(() => _down = true) : null,
            onTapUp: enabled ? (_) => setState(() => _down = false) : null,
            onTapCancel: () => setState(() => _down = false),
            onTap: enabled ? _handleTap : null,
            child: AnimatedScale(
              scale: _down ? 0.95 : 1,
              duration: const Duration(milliseconds: 120),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final p = _controller.value; // 0..1, mirrored by repeat.
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: .circular(widget.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: glow.withValues(alpha: 0.35 + 0.35 * p),
                          blurRadius: 12 + 20 * p,
                          spreadRadius: 1 + 3 * p,
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
      ),
    );
  }
}
