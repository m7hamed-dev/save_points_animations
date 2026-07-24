import 'package:flutter/widgets.dart';

/// A slow, cinematic zoom-and-pan over [child] (the "Ken Burns" effect) — ideal
/// for image backgrounds and hero headers. Ping-pongs for a seamless loop.
///
/// ```dart
/// FxKenBurns(child: Image.asset('hero.jpg', fit: BoxFit.cover));
/// ```
class FxKenBurns extends StatefulWidget {
  const FxKenBurns({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 12),
    this.maxScale = 1.25,
    this.panX = 0.06,
    this.panY = 0.04,
    this.curve = Curves.easeInOut,
  });

  final Widget child;
  final Duration duration;
  final double maxScale;

  /// Horizontal pan as a fraction of the child's width.
  final double panX;

  /// Vertical pan as a fraction of the child's height.
  final double panY;
  final Curve curve;

  @override
  State<FxKenBurns> createState() => _FxKenBurnsState();
}

class _FxKenBurnsState extends State<FxKenBurns>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        _controller.value = 0;
      } else {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) {
            final t = widget.curve.transform(_controller.value);
            final scale = 1 + (widget.maxScale - 1) * t;
            return Transform.scale(
              scale: scale,
              child: FractionalTranslation(
                translation: Offset(
                  widget.panX * (t * 2 - 1),
                  widget.panY * (t * 2 - 1),
                ),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
