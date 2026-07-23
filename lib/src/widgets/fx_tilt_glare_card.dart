import 'package:flutter/widgets.dart';

/// A pointer-driven 3D tilt card with a moving glare highlight — the glossy
/// "trading card" effect.
///
/// ```dart
/// FxTiltGlareCard(child: myCard);
/// ```
class FxTiltGlareCard extends StatefulWidget {
  const FxTiltGlareCard({
    super.key,
    required this.child,
    this.maxTilt = 0.18,
    this.glareColor = const Color(0x55FFFFFF),
    this.perspective = 0.001,
  });

  final Widget child;
  final double maxTilt;
  final Color glareColor;
  final double perspective;

  @override
  State<FxTiltGlareCard> createState() => _FxTiltGlareCardState();
}

class _FxTiltGlareCardState extends State<FxTiltGlareCard> {
  Offset _target = Offset.zero;
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return MouseRegion(
          onEnter: (_) => setState(() => _active = true),
          onHover: (event) {
            if (size.isEmpty) return;
            setState(() {
              _target = Offset(
                (event.localPosition.dx / size.width) * 2 - 1,
                (event.localPosition.dy / size.height) * 2 - 1,
              );
            });
          },
          onExit: (_) => setState(() {
            _target = Offset.zero;
            _active = false;
          }),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(end: _target),
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              final matrix = Matrix4.identity()
                ..setEntry(3, 2, widget.perspective)
                ..rotateX(-value.dy * widget.maxTilt)
                ..rotateY(value.dx * widget.maxTilt);
              return Transform(
                transform: matrix,
                alignment: Alignment.center,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    child!,
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _GlarePainter(
                            align: Alignment(value.dx, value.dy),
                            color: widget.glareColor,
                            active: _active,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _GlarePainter extends CustomPainter {
  _GlarePainter({
    required this.align,
    required this.color,
    required this.active,
  });

  final Alignment align;
  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    if (!active) return;
    final center =
        size.center(Offset.zero) +
        Offset(align.x * size.width / 2, align.y * size.height / 2);
    final shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
        .createShader(
          Rect.fromCircle(center: center, radius: size.shortestSide * 0.7),
        );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(_GlarePainter oldDelegate) =>
      oldDelegate.align != align ||
      oldDelegate.color != color ||
      oldDelegate.active != active;
}
