import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// A soft, drifting "aurora" of blurred colour blobs behind [child] — a modern,
/// living gradient backdrop.
///
/// ```dart
/// FxAurora(child: const Center(child: Text('Welcome')));
/// ```
class FxAurora extends StatefulWidget {
  const FxAurora({
    super.key,
    this.colors = const [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
      Color(0xFFFF512F),
    ],
    this.blur = 60,
    this.duration = const Duration(seconds: 10),
    this.child,
  });

  final List<Color> colors;
  final double blur;
  final Duration duration;
  final Widget? child;

  @override
  State<FxAurora> createState() => _FxAuroraState();
}

class _FxAuroraState extends State<FxAurora>
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
      child: ClipRect(
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value * 2 * math.pi;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        for (var i = 0; i < widget.colors.length; i++)
                          Align(
                            alignment: Alignment(
                              math.cos(t + i * 2.1) * 0.8,
                              math.sin(t * 1.3 + i * 1.7) * 0.8,
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 0.7,
                              heightFactor: 0.7,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.colors[i],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }
}
