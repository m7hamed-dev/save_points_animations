import 'package:flutter/widgets.dart';

/// A gradient call-to-action button with a continuously sweeping sheen.
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onPressed,
        child: ClipRRect(
          borderRadius: .circular(widget.borderRadius),
          child: Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(gradient: widget.gradient),
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
                      alignment: Alignment(_controller.value * 3 - 1.5, 0),
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
    );
  }
}
