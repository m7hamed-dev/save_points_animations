part of 'fx_refresh_styles.dart';

// The text styles draw the indicator's word (such as an app's name) on a
// frosted pill. They share the floating placement, the kick and the frosted
// surface with the other styles. textFill, textWave and textShimmer are drawn
// here; the rest are in fx_refresh_styles_text_more.dart.

/// The laid-out word: its painter, one box per letter and its line metrics.
/// The outline and the scramble symbols are laid out the first time a style
/// asks for them.
class _Word {
  _Word(this.painter, this.maxWidth) {
    final text = painter.plainText;
    var offset = 0;
    while (offset < text.length) {
      final next = painter.getOffsetAfter(offset) ?? text.length;
      // Letters cut off by the ellipsis have no boxes; spaces need none.
      final boxes = painter.getBoxesForSelection(
        TextSelection(baseOffset: offset, extentOffset: next),
      );
      if (boxes.isNotEmpty && text.substring(offset, next).trim().isNotEmpty) {
        letters.add(
          boxes
              .map((box) => box.toRect())
              .reduce((a, b) => a.expandToInclude(b)),
        );
      }
      offset = next <= offset ? offset + 1 : next;
    }
    final metrics = painter.computeLineMetrics();
    baseline = metrics.isEmpty ? painter.height * 0.8 : metrics.first.baseline;
    ascent = metrics.isEmpty ? painter.height * 0.75 : metrics.first.ascent;
    descent = metrics.isEmpty ? painter.height * 0.2 : metrics.first.descent;
  }

  final TextPainter painter;
  final double maxWidth;

  /// Each letter's box, in reading order.
  final List<Rect> letters = [];
  late final double baseline;
  late final double ascent;
  late final double descent;

  TextPainter? _outline;
  List<TextPainter>? _symbols;

  String get text => (painter.text! as TextSpan).text!;
  TextStyle get style => (painter.text! as TextSpan).style!;

  /// The font size after text scaling.
  double get fontSize => painter.textScaler.scale(style.fontSize ?? 22);

  Size get size => painter.size;

  void paint(Canvas canvas) => painter.paint(canvas, Offset.zero);

  /// The word as a stroked outline, laid out like the word.
  TextPainter get outline => _outline ??= TextPainter(
    text: TextSpan(
      text: text,
      style: style.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (fontSize * 0.06).clamp(1.1, 2.6)
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFFFFFFFF),
      ),
    ),
    textDirection: painter.textDirection,
    textScaler: painter.textScaler,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth);

  /// Symbols for textScramble, one painter each, in a set that suits the
  /// word: its own case for cased scripts, Arabic digits for Arabic and
  /// digits otherwise.
  List<TextPainter> get symbols => _symbols ??= [
    for (final symbol in _symbolsFor(text).split(''))
      TextPainter(
        text: TextSpan(text: symbol, style: style),
        textDirection: painter.textDirection,
        textScaler: painter.textScaler,
      )..layout(),
  ];

  static String _symbolsFor(String text) {
    if (RegExp('[؀-ۿ]').hasMatch(text)) return '٠١٢٣٤٥٦٧٨٩#%*+';
    if (text.toLowerCase() == text.toUpperCase()) return '0123456789#%&*+?';
    if (text == text.toLowerCase()) return 'abcdefghjkmnpqrstuvwxyz#%&*?';
    return 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789#%&*';
  }

  void dispose() {
    painter.dispose();
    _outline?.dispose();
    for (final symbol in _symbols ?? const <TextPainter>[]) {
      symbol.dispose();
    }
  }
}

/// The word on a frosted pill, in one of the text styles.
class _WordIndicator extends StatefulWidget {
  const _WordIndicator(this.frame, this.style);

  /// The tallest the pill gets, with the text scaled up for accessibility.
  static const double maxHeight = 60;
  static const double _padX = 22;
  static const double _padY = 11;
  static const TextStyle _defaults = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    height: 1.15,
  );

  final FxRefreshFrame frame;
  final FxRefreshStyle style;

  @override
  State<_WordIndicator> createState() => _WordIndicatorState();
}

class _WordIndicatorState extends State<_WordIndicator>
    with SingleTickerProviderStateMixin {
  _Word? _word;
  Object? _key;

  /// A slower loop than the frame's spin, for textTypewriter to delete and
  /// type the word again. It holds where it is when the refresh ends.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    _syncLoop();
  }

  @override
  void didUpdateWidget(_WordIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncLoop();
  }

  void _syncLoop() {
    final frame = widget.frame;
    final run =
        widget.style == FxRefreshStyle.textTypewriter &&
        frame.status == FxRefreshStatus.refresh &&
        !frame.reduceMotion;
    if (run && !_loop.isAnimating) {
      _loop.repeat();
    } else if (!run && _loop.isAnimating) {
      _loop.stop();
    }
    if (frame.beforeTrigger && _loop.value != 0) _loop.value = 0;
  }

  @override
  void dispose() {
    _loop.dispose();
    _word?.dispose();
    super.dispose();
  }

  /// Lays out the word, reusing the last layout while nothing it depends on
  /// changes.
  _Word _layout(BuildContext context, double maxWidth) {
    final frame = widget.frame;
    final base = DefaultTextStyle.of(
      context,
    ).style.merge(_WordIndicator._defaults).merge(frame.textStyle);
    // Painted in white and colored later, so only the shape of the type is
    // taken from the style.
    final style = TextStyle(
      color: const Color(0xFFFFFFFF),
      fontFamily: base.fontFamily,
      fontFamilyFallback: base.fontFamilyFallback,
      fontSize: base.fontSize,
      fontWeight: base.fontWeight,
      fontStyle: base.fontStyle,
      letterSpacing: base.letterSpacing,
      wordSpacing: base.wordSpacing,
      height: base.height,
      leadingDistribution: base.leadingDistribution,
      fontFeatures: base.fontFeatures,
      fontVariations: base.fontVariations,
      locale: base.locale,
    );
    final scaler =
        (MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling).clamp(
          maxScaleFactor: 1.3,
        );
    final direction = frame.rtl ? TextDirection.rtl : TextDirection.ltr;
    final key = (frame.text, style, scaler, direction, maxWidth);
    final cached = _word;
    if (cached != null && key == _key) return cached;
    cached?.dispose();
    _key = key;
    TextPainter lay(TextStyle style, TextScaler scaler) => TextPainter(
      text: TextSpan(text: frame.text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.max(0, maxWidth));
    var painter = lay(style, scaler);
    // A large font size is shrunk so the pill stays within maxHeight.
    const room = _WordIndicator.maxHeight - 2 * _WordIndicator._padY;
    if (painter.height > room) {
      final fontSize =
          scaler.scale(style.fontSize ?? 22) * room / painter.height;
      painter.dispose();
      painter = lay(style.copyWith(fontSize: fontSize), TextScaler.noScaling);
    }
    return _word = _Word(painter, math.max(0, maxWidth));
  }

  @override
  Widget build(BuildContext context) {
    final frame = widget.frame;
    return LayoutBuilder(
      builder: (context, constraints) {
        final word = _layout(
          context,
          constraints.maxWidth - 48 - 2 * _WordIndicator._padX,
        );
        final height = word.size.height + 2 * _WordIndicator._padY;
        return _Floating(
          frame: frame,
          extent: height,
          child: _ExitFade(
            frame: frame,
            from: 0.72,
            lift: 10,
            child: _Kick(
              on: frame.status == FxRefreshStatus.armed,
              reduceMotion: frame.reduceMotion,
              // A second kick eases the word into the refresh loop.
              builder: (context, kick) => _Kick(
                on: frame.status == FxRefreshStatus.refresh,
                reduceMotion: frame.reduceMotion,
                builder: (context, settle) => AnimatedBuilder(
                  animation: Listenable.merge([kick, frame.exit]),
                  builder: (context, child) => Transform.scale(
                    scale:
                        1 +
                        (frame.beforeTrigger ? 0 : 0.05 * _bump(kick.value)) +
                        (frame.status == FxRefreshStatus.done
                            ? 0.06 *
                                  _bump(_interval(frame.exit.value, 0.3, 0.9))
                            : 0),
                    child: child,
                  ),
                  child: _Surface(
                    frame: frame,
                    radius: height / 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _WordIndicator._padX,
                        vertical: _WordIndicator._padY,
                      ),
                      child: CustomPaint(
                        size: word.size,
                        painter: _WordPainter(
                          frame,
                          widget.style,
                          word,
                          kick,
                          settle,
                          _loop,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WordPainter extends CustomPainter {
  _WordPainter(
    this.frame,
    this.style,
    this.word,
    this.kick,
    this.settle,
    this.loop,
  ) : super(repaint: Listenable.merge([frame.ticks, kick, settle, loop]));

  final FxRefreshFrame frame;
  final FxRefreshStyle style;
  final _Word word;

  /// Plays from 0 to 1 at the trigger point; rests at 1.
  final Animation<double> kick;

  /// Plays from 0 to 1 as refreshing starts; rests at 1.
  final Animation<double> settle;

  /// The typewriter's slow loop.
  final Animation<double> loop;

  static const Color _white = Color(0xFFFFFFFF);

  /// The accent gradient across [rect] in the text direction, at [opacity].
  Shader _accent(Rect rect, [double opacity = 1]) => LinearGradient(
    begin: frame.rtl ? Alignment.centerRight : Alignment.centerLeft,
    end: frame.rtl ? Alignment.centerLeft : Alignment.centerRight,
    colors: [_fade(frame.secondary, opacity), _fade(frame.color, opacity)],
  ).createShader(rect);

  /// The text color at [opacity], made solid against the pill. Letters stay
  /// opaque inside the layer, so the fills drawn onto them keep their full
  /// strength.
  Color _ink(double opacity) => Color.alphaBlend(
    _fade(frame.foreground, opacity),
    frame.background.withValues(alpha: 1),
  );

  /// [u] (0 at the start of the word, 1 at its end) as an x position.
  double _along(double u, double width) =>
      frame.rtl ? width * (1 - u) : width * u;

  /// Paints [shader] over the word up to [u] of the way along it, with a
  /// soft edge, keeping to the letters.
  void _sweep(Canvas canvas, Rect rect, double u, Shader shader) {
    if (u <= 0) return;
    const feather = 0.16;
    final edge = u * (1 + feather);
    canvas
      ..saveLayer(rect, Paint()..blendMode = BlendMode.srcATop)
      ..drawRect(rect, Paint()..shader = shader)
      ..drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = LinearGradient(
            begin: frame.rtl ? Alignment.centerRight : Alignment.centerLeft,
            end: frame.rtl ? Alignment.centerLeft : Alignment.centerRight,
            colors: const [_white, _white, Color(0x00FFFFFF)],
            stops: [0, (edge - feather).clamp(0.0, 1.0), edge.clamp(0.0, 1.0)],
          ).createShader(rect),
      )
      ..restore();
  }

  /// A slanted band of light centered [u] of the way along the word (it may
  /// sit off either end), keeping to the letters.
  void _band(Canvas canvas, Size size, double u, Color core) {
    final width = size.width;
    final half = math.max(18.0, width * 0.22);
    final x = _along(u, width);
    canvas.drawRect(
      (Offset.zero & size).inflate(8),
      Paint()
        ..blendMode = BlendMode.srcATop
        ..shader = ui.Gradient.linear(
          Offset(x - half, -size.height * 0.35),
          Offset(x + half, size.height * 0.35),
          [_fade(core, 0), core, _fade(core, 0)],
          const [0, 0.5, 1],
        ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    switch (style) {
      case FxRefreshStyle.textWave:
        _wave(canvas, size);
      case FxRefreshStyle.textShimmer:
        _shimmer(canvas, size);
      case FxRefreshStyle.textNeon:
        _neon(canvas, size);
      case FxRefreshStyle.textFlip:
        _flip(canvas, size);
      case FxRefreshStyle.textScramble:
        _scramble(canvas, size);
      case FxRefreshStyle.textOutline:
        _outline(canvas, size);
      case FxRefreshStyle.textTypewriter:
        _typewriter(canvas, size);
      case _:
        _fill(canvas, size);
    }
  }

  /// How much of the accent the word shows: none before the trigger point,
  /// fading in with the kick there and staying after.
  double get _accentShare => frame.beforeTrigger
      ? 0
      : Curves.easeOut.transform(_interval(kick.value, 0, 0.4));

  /// The gap between letter starts in a staggered run over [count] letters
  /// that must fit in [span] of the run.
  static double _step(int count, double most, double span) =>
      count > 1 ? math.min(most, span / (count - 1)) : 0;

  /// Where the liquid's surface sits in the refresh loop at [s]: it sloshes
  /// between a third full and nearly full.
  static double _slosh(double s) => 0.58 + 0.3 * math.cos(2 * math.pi * s);

  void _fill(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final width = size.width;
    final s = frame.reduceMotion ? 0.25 : frame.spin.value;
    double level;
    double wave;
    double phase;
    var shine = 0.0;
    switch (frame.status) {
      case FxRefreshStatus.refresh:
        level = lerpDouble(
          1.25,
          _slosh(s),
          Curves.easeInOut.transform(settle.value),
        )!;
        wave = 2.2;
        phase = 2 * math.pi * 3 * s;
      case FxRefreshStatus.done:
        // It fills to the brim, settles and a shine runs through it.
        final e = frame.exit.value;
        level = lerpDouble(
          _slosh(s),
          1.25,
          Curves.easeOutCubic.transform(_interval(e, 0, 0.3)),
        )!;
        wave = 2.2 * (1 - _interval(e, 0, 0.35));
        phase = 2 * math.pi * 3 * s + 6 * e;
        shine = _interval(e, 0.25, 0.7);
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.canceled:
        final p = frame.progress;
        // Rising with the pull, then a splash to the top at the trigger
        // point.
        level = frame.beforeTrigger
            ? 0.9 * Curves.easeInOut.transform(p)
            : lerpDouble(0.9, 1.25, Curves.easeOutCubic.transform(kick.value))!;
        wave = 1.6 + (frame.beforeTrigger ? 0 : 3.2 * _bump(kick.value));
        phase = 2 * math.pi * 1.4 * frame.pull.value;
    }
    if (frame.reduceMotion && frame.status == FxRefreshStatus.refresh) {
      level = 0.62;
      wave = 1.2;
    }

    // From the bottom of the letters (a little into the descenders) to the
    // top of the capitals.
    final bottom = word.baseline + word.descent * 0.35;
    final top = word.baseline - word.ascent * 0.8;
    final surface = lerpDouble(bottom, top, level)!;
    double y(double x) =>
        surface + wave * math.sin(2 * math.pi * x / 26 + phase);
    final liquid = Path()..moveTo(-12, size.height + 12);
    final crest = Path()..moveTo(-12, y(-12));
    for (var x = -12.0; x <= width + 12; x += 2) {
      liquid.lineTo(x, y(x));
      crest.lineTo(x, y(x));
    }
    liquid
      ..lineTo(width + 12, size.height + 12)
      ..close();

    canvas.saveLayer(rect.inflate(12), Paint());
    word.paint(canvas);
    canvas
      // The empty letters, then the liquid and its glossy surface in them.
      ..drawRect(
        rect.inflate(12),
        Paint()
          ..blendMode = BlendMode.srcIn
          ..color = _ink(frame.dark ? 0.22 : 0.15),
      )
      ..drawPath(
        liquid,
        Paint()
          ..blendMode = BlendMode.srcATop
          ..shader = _accent(rect),
      )
      ..drawPath(
        crest,
        Paint()
          ..blendMode = BlendMode.srcATop
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = _fade(Color.lerp(frame.color, _white, 0.55)!, 0.9),
      );
    if (shine > 0 && shine < 1) {
      _band(canvas, size, lerpDouble(-0.4, 1.4, shine)!, _fade(_white, 0.6));
    }
    canvas.restore();
  }

  void _wave(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final letters = word.letters;
    final count = letters.length;
    final s = frame.spin.value;
    final e = frame.exit.value;
    final p = frame.progress;
    // How far each letter has risen in (0–1), how high it hops and how big
    // it grows, and how much of the accent the word shows.
    double shown(int i) => frame.beforeTrigger
        ? _interval(p, i / count * 0.6, i / count * 0.6 + 0.4)
        : 1;
    double hop(int i) => switch (frame.status) {
      FxRefreshStatus.drag || FxRefreshStatus.canceled =>
        9 * (1 - Curves.easeOutBack.transform(shown(i))),
      FxRefreshStatus.armed || FxRefreshStatus.snap =>
        -7 * _bump(_interval(kick.value, i * 0.05, i * 0.05 + 0.55)),
      FxRefreshStatus.refresh => -6 * _crest(i, s),
      FxRefreshStatus.done =>
        -5 * _bump(_interval(e, i * 0.045, i * 0.045 + 0.45)),
    };
    double grow(int i) => switch (frame.status) {
      FxRefreshStatus.drag || FxRefreshStatus.canceled =>
        0.85 + 0.15 * Curves.easeOut.transform(shown(i)),
      FxRefreshStatus.armed || FxRefreshStatus.snap => 1,
      FxRefreshStatus.refresh => 1 + 0.1 * _crest(i, s),
      FxRefreshStatus.done =>
        1 + 0.12 * _bump(_interval(e, i * 0.045, i * 0.045 + 0.45)),
    };
    final accent = frame.beforeTrigger
        ? 0.0
        : Curves.easeOut.transform(_interval(kick.value, 0, 0.4));

    final bounds = rect.inflate(16);
    canvas.saveLayer(bounds, Paint());
    for (var i = 0; i < count; i++) {
      final opacity = shown(i);
      if (opacity <= 0) continue;
      final box = letters[i];
      // Each letter is cut out of the whole word, so joined scripts keep
      // their shapes.
      final clip = Rect.fromLTRB(
        box.left - 0.5,
        -16,
        box.right + 0.5,
        size.height + 16,
      );
      if (opacity < 1) {
        canvas.saveLayer(clip, Paint()..color = _fade(_white, opacity));
      } else {
        canvas.save();
      }
      final center = box.center;
      final scale = grow(i);
      canvas
        ..clipRect(clip)
        ..translate(center.dx, center.dy + hop(i))
        ..scale(scale)
        ..translate(-center.dx, -center.dy);
      word.paint(canvas);
      canvas.restore();
    }
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.srcIn
        ..color = frame.foreground,
    );
    if (accent > 0) {
      canvas.drawRect(
        bounds,
        Paint()
          ..blendMode = BlendMode.srcATop
          ..shader = _accent(rect, accent),
      );
    }
    canvas.restore();
  }

  /// How high letter [i] rides the wave at spin phase [s], 0 to 1: two
  /// crests run along the word each cycle, with a rest between.
  double _crest(int i, double s) {
    if (frame.reduceMotion) return 0;
    final up = math.max(0.0, math.sin(2 * math.pi * (2 * s - i * 0.1)));
    return up * up * Curves.easeInOut.transform(settle.value);
  }

  void _shimmer(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bounds = rect.inflate(8);
    final dark = frame.dark;
    final core = Color.lerp(frame.color, _white, dark ? 0.5 : 0.08)!;
    canvas.saveLayer(bounds, Paint());
    word.paint(canvas);
    // A ghost of the word to write over.
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.srcIn
        ..color = _ink(dark ? 0.2 : 0.14),
    );
    switch (frame.status) {
      case FxRefreshStatus.drag || FxRefreshStatus.canceled:
        // Written in the text direction with the pull.
        _sweep(
          canvas,
          bounds,
          Curves.easeOut.transform(frame.progress),
          LinearGradient(colors: [_ink(0.88), _ink(0.88)]).createShader(bounds),
        );
      case FxRefreshStatus.armed || FxRefreshStatus.snap:
        // Fully written, then lit with the accent from start to end.
        canvas.drawRect(
          bounds,
          Paint()
            ..blendMode = BlendMode.srcATop
            ..color = _ink(0.88),
        );
        _sweep(
          canvas,
          bounds,
          Curves.easeOutCubic.transform(kick.value),
          _accent(rect),
        );
      case FxRefreshStatus.refresh:
        // A dim accent word with a band of light crossing it every cycle.
        final dim = frame.reduceMotion
            ? 1.0
            : lerpDouble(1, 0.4, Curves.easeInOut.transform(settle.value))!;
        canvas.drawRect(
          bounds,
          Paint()
            ..blendMode = BlendMode.srcATop
            ..shader = _accent(rect, dim),
        );
        if (!frame.reduceMotion) {
          _band(
            canvas,
            size,
            lerpDouble(-0.35, 1.35, frame.spin.value)!,
            _fade(core, Curves.easeInOut.transform(settle.value)),
          );
        }
      case FxRefreshStatus.done:
        // A last band that leaves the word filled with the accent behind
        // it.
        final u = Curves.easeInOutCubic.transform(
          _interval(frame.exit.value, 0, 0.45),
        );
        canvas.drawRect(
          bounds,
          Paint()
            ..blendMode = BlendMode.srcATop
            ..shader = _accent(rect, 0.4),
        );
        _sweep(canvas, bounds, u, _accent(rect));
        if (u < 1) _band(canvas, size, lerpDouble(-0.2, 1.2, u)!, core);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WordPainter old) =>
      !old.frame.sameLook(frame) ||
      old.style != style ||
      old.word != word ||
      old.kick != kick ||
      old.settle != settle ||
      old.loop != loop;
}
