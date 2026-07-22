import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/visual_effects.dart';
import 'package:save_points_animations/src/extensions/fx_widget_extensions.dart';

/// Text with an animated gradient sweeping across it (a shimmering headline).
class FxGradientText extends StatefulWidget {
  const FxGradientText(
    this.text, {
    super.key,
    this.colors = const [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
      Color(0xFF6A11CB),
    ],
    this.style,
    this.duration = const Duration(milliseconds: 1800),
  });

  final String text;
  final List<Color> colors;
  final TextStyle? style;
  final Duration duration;

  @override
  State<FxGradientText> createState() => _FxGradientTextState();
}

class _FxGradientTextState extends State<FxGradientText>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shift = _controller.value * 2;
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: widget.colors,
            begin: Alignment(-1 + shift, 0),
            end: Alignment(1 + shift, 0),
            tileMode: TileMode.mirror,
          ).createShader(bounds),
          child: Text(
            widget.text,
            style: (widget.style ?? const TextStyle()).copyWith(
              color: const Color(0xFFFFFFFF),
            ),
          ),
        );
      },
    );
  }
}

/// Text whose characters bob up and down in a travelling wave.
class FxWavyText extends StatefulWidget {
  const FxWavyText(
    this.text, {
    super.key,
    this.style,
    this.amplitude = 4,
    this.duration = const Duration(milliseconds: 1200),
  });

  final String text;
  final TextStyle? style;
  final double amplitude;
  final Duration duration;

  @override
  State<FxWavyText> createState() => _FxWavyTextState();
}

class _FxWavyTextState extends State<FxWavyText>
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
    final chars = widget.text.split('');
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < chars.length; i++)
              Transform.translate(
                offset: Offset(
                  0,
                  math.sin(_controller.value * 2 * math.pi + i * 0.5) *
                      widget.amplitude,
                ),
                child: Text(chars[i], style: widget.style),
              ),
          ],
        );
      },
    );
  }
}

/// Reveals text by scrambling random glyphs that settle left-to-right.
class FxScrambleText extends StatefulWidget {
  const FxScrambleText(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.glyphs = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&',
  });

  final String text;
  final TextStyle? style;
  final Duration duration;
  final String glyphs;

  @override
  State<FxScrambleText> createState() => _FxScrambleTextState();
}

class _FxScrambleTextState extends State<FxScrambleText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final locked = (_controller.value * widget.text.length).floor();
        final buffer = StringBuffer();
        for (var i = 0; i < widget.text.length; i++) {
          if (i < locked || widget.text[i] == ' ') {
            buffer.write(widget.text[i]);
          } else {
            buffer.write(widget.glyphs[_random.nextInt(widget.glyphs.length)]);
          }
        }
        return Text(buffer.toString(), style: widget.style);
      },
    );
  }
}

/// Fades in text one word at a time.
class FxWordsText extends StatelessWidget {
  const FxWordsText(
    this.text, {
    super.key,
    this.style,
    this.interval = const Duration(milliseconds: 120),
  });

  final String text;
  final TextStyle? style;
  final Duration interval;

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    return Wrap(
      spacing: 6,
      runSpacing: 2,
      children: [
        for (var i = 0; i < words.length; i++)
          Text(
            words[i],
            style: style,
          ).animate().addEffect(FadeEffect(delay: interval * i)),
      ],
    );
  }
}

/// Rich text-effect sugar on [String].
extension FxTextEffects on String {
  /// Text with a sweeping animated gradient.
  Widget gradientText({
    List<Color> colors = const [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
      Color(0xFF6A11CB),
    ],
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 1800),
  }) => FxGradientText(this, colors: colors, style: style, duration: duration);

  /// Text whose characters ripple in a wave.
  Widget wavyText({
    TextStyle? style,
    double amplitude = 4,
    Duration duration = const Duration(milliseconds: 1200),
  }) =>
      FxWavyText(this, style: style, amplitude: amplitude, duration: duration);

  /// Scramble-in reveal.
  Widget scrambleText({
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 1200),
  }) => FxScrambleText(this, style: style, duration: duration);

  /// Fade in word by word.
  Widget wordsFadeIn({
    TextStyle? style,
    Duration interval = const Duration(milliseconds: 120),
  }) => FxWordsText(this, style: style, interval: interval);
}
