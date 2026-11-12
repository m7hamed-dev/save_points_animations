import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';
import 'package:save_points_animations/src/widgets/fx_focusable.dart';

/// An animated day/night switch. The thumb slides between sun and moon while
/// the track cross-fades from a bright sky to a starry night. It is
/// keyboard-focusable; Enter / Space flip it.
///
/// ```dart
/// FxThemeToggle(isDark: dark, onChanged: (v) => setState(() => dark = v));
/// ```
class FxThemeToggle extends StatelessWidget {
  const FxThemeToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
    this.width = 76,
    this.height = 36,
    this.dayColor = const Color(0xFF4FC3F7),
    this.nightColor = const Color(0xFF283593),
  });

  final bool isDark;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Color dayColor;
  final Color nightColor;

  void _toggle() {
    HapticFeedback.lightImpact();
    onChanged(!isDark);
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = height - 8;
    final reduceMotion = fxReduceMotion(context);
    return Semantics(
      button: true,
      enabled: true,
      toggled: isDark,
      label: 'Theme',
      // Enter / Space flip it when it has keyboard focus.
      child: FxFocusableControl(
        enabled: true,
        onActivate: _toggle,
        builder: (context, showFocus) => GestureDetector(
          onTap: _toggle,
          child: FxFocusRing(
            visible: showFocus,
            color: isDark ? nightColor : dayColor,
            borderRadius: .circular(height / 2),
            child: _track(thumbSize, reduceMotion),
          ),
        ),
      ),
    );
  }

  Widget _track(double thumbSize, bool reduceMotion) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? nightColor : dayColor,
        borderRadius: .circular(height),
      ),
      child: Stack(
        children: [
          // Stars fade in at night.
          AnimatedOpacity(
            opacity: isDark ? 1 : 0,
            duration: const Duration(milliseconds: 360),
            child: const _Stars(),
          ),
          AnimatedAlign(
            alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeInOutBack,
            child: SizedBox(
              width: thumbSize,
              height: thumbSize,
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => reduceMotion
                    ? FadeTransition(opacity: animation, child: child)
                    : RotationTransition(
                        turns: Tween<double>(
                          begin: 0.6,
                          end: 1,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                child: isDark
                    ? const _Moon(key: ValueKey('moon'))
                    : const _Sun(key: ValueKey('sun')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sun extends StatelessWidget {
  const _Sun({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xFFFFD54F),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x88FFD54F), blurRadius: 8)],
      ),
    );
  }
}

class _Moon extends StatelessWidget {
  const _Moon({super.key});

  @override
  Widget build(BuildContext context) {
    // A crescent: a light disc with an offset dark disc cut over it.
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFECEFF1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -3,
          top: -3,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFF283593),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(left: 8, top: 6, child: _Dot(2)),
        Positioned(left: 18, top: 16, child: _Dot(1.5)),
        Positioned(left: 12, top: 22, child: _Dot(1)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.size);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        shape: BoxShape.circle,
      ),
    );
  }
}
