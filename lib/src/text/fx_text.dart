import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/transform_effects.dart';
import 'package:save_points_animations/src/effects/visual_effects.dart';
import 'package:save_points_animations/src/extensions/fx_widget_extensions.dart';

/// Reveals [text] one character at a time.
class FxTypewriter extends StatefulWidget {
  const FxTypewriter(
    this.text, {
    super.key,
    this.duration,
    this.style,
    this.cursor = '',
    this.curve = Curves.linear,
  });

  final String text;
  final Duration? duration;
  final TextStyle? style;

  /// Optional trailing cursor glyph shown while typing (e.g. `'|'`).
  final String cursor;
  final Curve curve;

  @override
  State<FxTypewriter> createState() => _FxTypewriterState();
}

class _FxTypewriterState extends State<FxTypewriter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration:
        widget.duration ?? Duration(milliseconds: 45 * widget.text.length),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        _controller.value = 1;
      } else {
        _controller.forward();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = widget.curve.transform(_controller.value);
        final count = (progress * widget.text.length).round();
        final shown = widget.text.substring(
          0,
          count.clamp(0, widget.text.length),
        );
        final showCursor =
            widget.cursor.isNotEmpty && count < widget.text.length;
        return Text(
          showCursor ? '$shown${widget.cursor}' : shown,
          style: widget.style,
        );
      },
    );
  }
}

/// Animates each character of [text] in, staggered by [interval].
class FxAnimatedText extends StatelessWidget {
  const FxAnimatedText(
    this.text, {
    super.key,
    this.style,
    this.interval = const Duration(milliseconds: 40),
    this.slide = 0.4,
  });

  final String text;
  final TextStyle? style;
  final Duration interval;

  /// Vertical slide distance per character (fraction of its height).
  final double slide;

  @override
  Widget build(BuildContext context) {
    final chars = text.split('');
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < chars.length; i++)
          Text(chars[i], style: style)
              .animate()
              .addEffect(FadeEffect(delay: interval * i))
              .addEffect(SlideEffect(beginY: slide, delay: interval * i)),
      ],
    );
  }
}

/// Counts up (or down) from [begin] to [end], animating the displayed number.
class FxCountUp extends StatefulWidget {
  const FxCountUp({
    required this.end,
    super.key,
    this.begin = 0,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOut,
    this.style,
    this.formatter,
  });

  final double begin;
  final double end;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;

  /// Formats the animated value; defaults to a rounded integer.
  final String Function(double value)? formatter;

  @override
  State<FxCountUp> createState() => _FxCountUpState();
}

class _FxCountUpState extends State<FxCountUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late double _from = widget.begin;

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant FxCountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end) {
      _from = _currentValue;
      _controller
        ..reset()
        ..forward();
    }
  }

  double get _currentValue {
    final t = widget.curve.transform(_controller.value);
    return _from + (widget.end - _from) * t;
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
        final value = _currentValue;
        final text = widget.formatter?.call(value) ?? value.round().toString();
        return Text(text, style: widget.style);
      },
    );
  }
}

/// Text-animation sugar on [String].
extension FxTextString on String {
  /// Reveal this string one character at a time.
  Widget typewriter({
    Duration? duration,
    TextStyle? style,
    String cursor = '',
    Curve curve = Curves.linear,
  }) => FxTypewriter(
    this,
    duration: duration,
    style: style,
    cursor: cursor,
    curve: curve,
  );

  /// Animate each character in, staggered.
  Widget animateChars({
    TextStyle? style,
    Duration interval = const Duration(milliseconds: 40),
    double slide = 0.4,
  }) => FxAnimatedText(this, style: style, interval: interval, slide: slide);
}

/// Animated number sugar on [num].
extension FxCountNum on num {
  /// Count up to this value from [from].
  Widget countUp({
    num from = 0,
    Duration duration = const Duration(milliseconds: 900),
    Curve curve = Curves.easeOut,
    TextStyle? style,
    String Function(double value)? formatter,
  }) => FxCountUp(
    begin: from.toDouble(),
    end: toDouble(),
    duration: duration,
    curve: curve,
    style: style,
    formatter: formatter,
  );
}
