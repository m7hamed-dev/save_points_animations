import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A target that leans toward the pointer while hovered (desktop/web) and
/// springs back to center when the pointer leaves — a "magnetic" button feel.
/// On touch it simply forwards taps.
///
/// ```dart
/// FxMagneticButton(onTap: go, child: myButton);
/// ```
class FxMagneticButton extends StatefulWidget {
  const FxMagneticButton({
    super.key,
    required this.child,
    this.onTap,
    this.strength = 18,
    this.scaleOnHover = 1.06,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Maximum pull, in logical pixels, toward the pointer.
  final double strength;
  final double scaleOnHover;

  @override
  State<FxMagneticButton> createState() => _FxMagneticButtonState();
}

class _FxMagneticButtonState extends State<FxMagneticButton>
    with FxMotionAware {
  // Drives the transform without rebuilding widget.child on every move.
  final ValueNotifier<_MagneticState> _state = ValueNotifier(
    const _MagneticState(offset: Offset.zero, hovering: false),
  );
  Size _size = Size.zero;

  void _onHover(PointerHoverEvent event) {
    if (reduceMotion) return;
    if (_size == Size.zero) return;
    final center = Offset(_size.width / 2, _size.height / 2);
    final delta = event.localPosition - center;
    // Normalize by half-size so the pull saturates near the edges.
    final nx = (delta.dx / (_size.width / 2)).clamp(-1.0, 1.0);
    final ny = (delta.dy / (_size.height / 2)).clamp(-1.0, 1.0);
    _state.value = _MagneticState(
      offset: Offset(nx * widget.strength, ny * widget.strength),
      hovering: true,
    );
  }

  void _reset() {
    _state.value = const _MagneticState(offset: Offset.zero, hovering: false);
  }

  @override
  void onReduceMotionChanged(bool reduce) {
    if (reduce) _reset();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: (_) => _reset(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _size = constraints.biggest;
            return ValueListenableBuilder<_MagneticState>(
              valueListenable: _state,
              child: widget.child,
              builder: (context, state, child) {
                return TweenAnimationBuilder<Offset>(
                  tween: Tween<Offset>(end: state.offset),
                  duration: state.hovering
                      ? const Duration(milliseconds: 90)
                      : const Duration(milliseconds: 420),
                  curve: state.hovering ? Curves.easeOut : Curves.elasticOut,
                  builder: (context, offset, child) =>
                      Transform.translate(offset: offset, child: child),
                  child: AnimatedScale(
                    scale: state.hovering ? widget.scaleOnHover : 1,
                    duration: const Duration(milliseconds: 180),
                    child: child,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MagneticState {
  const _MagneticState({required this.offset, required this.hovering});

  final Offset offset;
  final bool hovering;
}
