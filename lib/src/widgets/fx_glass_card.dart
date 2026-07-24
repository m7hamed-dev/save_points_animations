import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// A frosted-glass card: it blurs whatever sits behind it, tints it lightly,
/// and sweeps a soft diagonal sheen across the surface. Place it over content
/// (a `Stack`, an image, a gradient) so the blur has something to work with.
///
/// ```dart
/// Stack(children: [background, FxGlassCard(child: content)]);
/// ```
class FxGlassCard extends StatefulWidget {
  const FxGlassCard({
    super.key,
    required this.child,
    this.blur = 14,
    this.tint = const Color(0x33FFFFFF),
    this.borderColor = const Color(0x55FFFFFF),
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.sheen = true,
    this.sheenDuration = const Duration(seconds: 4),
  });

  final Widget child;
  final double blur;
  final Color tint;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool sheen;
  final Duration sheenDuration;

  @override
  State<FxGlassCard> createState() => _FxGlassCardState();
}

class _FxGlassCardState extends State<FxGlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.sheenDuration,
    );
    if (widget.sheen) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant FxGlassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sheen && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.sheen && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.tint,
              borderRadius: radius,
              border: Border.all(color: widget.borderColor),
            ),
            child: Stack(
              children: [
                if (widget.sheen)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          // A soft band that travels corner to corner.
                          final t = _controller.value * 2 - 0.5;
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: const [
                                  Color(0x00FFFFFF),
                                  Color(0x33FFFFFF),
                                  Color(0x00FFFFFF),
                                ],
                                stops: [
                                  (t - 0.15).clamp(0.0, 1.0),
                                  t.clamp(0.0, 1.0),
                                  (t + 0.15).clamp(0.0, 1.0),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                Padding(padding: widget.padding, child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
