import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';
import 'package:save_points_animations/src/widgets/fx_focusable.dart';

/// A gradient call-to-action button with a continuously sweeping sheen.
/// It is keyboard-focusable; Enter / Space press it.
///
/// ```dart
/// FxShimmerButton(onPressed: submit, child: const Text('Get started'));
/// ```
class FxShimmerButton extends StatefulWidget {
  const FxShimmerButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
    ),
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.duration = const Duration(milliseconds: 2200),
  });

  final Widget child;
  final VoidCallback onPressed;
  final Gradient gradient;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Duration duration;

  @override
  State<FxShimmerButton> createState() => _FxShimmerButtonState();
}

class _FxShimmerButtonState extends State<FxShimmerButton>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;
  bool _kicked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FxMotionAware only reports reduce-motion *flips*, so start the first
    // sweep here once the flag is known.
    if (!_kicked) {
      _kicked = true;
      if (!reduceMotion) _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant FxShimmerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      if (_controller.isAnimating) _controller.repeat();
    }
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
    HapticFeedback.selectionClick();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient;
    return Semantics(
      button: true,
      enabled: true,
      child: FxFocusableControl(
        enabled: true,
        onActivate: _handleTap,
        builder: (context, showFocus) => RepaintBoundary(
          child: GestureDetector(
            onTap: _handleTap,
            child: FxFocusRing(
              visible: showFocus,
              color: gradient.colors.first,
              borderRadius: .circular(widget.borderRadius),
              child: ClipRRect(
                borderRadius: .circular(widget.borderRadius),
                child: Stack(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(gradient: gradient),
                      child: Padding(
                        padding: widget.padding,
                        child: DefaultTextStyle.merge(
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w600,
                          ),
                          child: widget.child,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) => Align(
                            alignment: Alignment(
                              _controller.value * 3 - 1.5,
                              0,
                            ),
                            child: const FractionallySizedBox(
                              widthFactor: 0.25,
                              heightFactor: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0x00FFFFFF),
                                      Color(0x55FFFFFF),
                                      Color(0x00FFFFFF),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
