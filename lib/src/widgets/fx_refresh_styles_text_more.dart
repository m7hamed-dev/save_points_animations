part of 'fx_refresh_styles.dart';

// The rest of the text styles: textNeon, textFlip, textScramble, textOutline
// and textTypewriter, as more looks for _WordPainter.

extension on _WordPainter {
  static const Color _white = _WordPainter._white;

  /// The pill's color, made solid: a base that keeps fills drawn onto the
  /// letters at full strength.
  Color get _solidBackground => frame.background.withValues(alpha: 1);

  /// Letter [i]'s column, wide enough for its box, cut out of the whole word
  /// so joined scripts keep their shapes.
  Rect _column(Size size, int i) {
    final box = word.letters[i];
    return Rect.fromLTRB(
      box.left - 0.5,
      -16,
      box.right + 0.5,
      size.height + 16,
    );
  }

  /// Masks what is painted so far to the first [u] of the word, in the text
  /// direction, with a soft edge.
  void _reveal(Canvas canvas, Rect rect, double u) {
    if (u >= 1) return;
    const feather = 0.16;
    final edge = u * (1 + feather);
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = LinearGradient(
          begin: frame.rtl ? Alignment.centerRight : Alignment.centerLeft,
          end: frame.rtl ? Alignment.centerLeft : Alignment.centerRight,
          colors: const [_white, _white, Color(0x00FFFFFF)],
          stops: [0, (edge - feather).clamp(0.0, 1.0), edge.clamp(0.0, 1.0)],
        ).createShader(rect),
    );
  }

  /// A horizontal shader that gives each letter its own color, blended
  /// between the letters.
  Shader _perLetter(Size size, Color Function(int i) colorOf) {
    final letters = word.letters;
    final order = List.generate(letters.length, (i) => i)
      ..sort((a, b) => letters[a].center.dx.compareTo(letters[b].center.dx));
    final colors = [for (final i in order) colorOf(i)];
    final stops = [
      for (final i in order)
        (letters[i].center.dx / size.width).clamp(0.0, 1.0),
    ];
    if (colors.length == 1) {
      colors.add(colors.first);
      stops.add(1);
    }
    return ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, 0),
      colors,
      stops,
    );
  }

  /// The accent at letter [i]: the gradient partner at the start of the
  /// word, the accent at its end.
  Color _hue(int i) {
    final count = word.letters.length;
    return Color.lerp(
      frame.secondary,
      frame.color,
      count > 1 ? i / (count - 1) : 1,
    )!;
  }

  // ── textNeon ─────────────────────────────────────────────────────────────

  /// The tube's power over the kick at [k]: a few stutters, then steady.
  static double _flicker(double k) {
    const stutters = [
      (0.07, 0.85),
      (0.12, 0.1),
      (0.2, 1.0),
      (0.26, 0.25),
      (0.34, 0.9),
      (0.39, 0.35),
      (0.5, 1.0),
      (0.55, 0.7),
    ];
    for (final (end, level) in stutters) {
      if (k < end) return level;
    }
    return 1;
  }

  void _neon(Canvas canvas, Size size) {
    final letters = word.letters;
    final count = letters.length;
    if (count == 0) return;
    final bounds = (Offset.zero & size).inflate(24);
    final dark = frame.dark;
    final flash = frame.status == FxRefreshStatus.done
        ? math.sin(math.pi * _interval(frame.exit.value, 0, 0.5))
        : 0.0;
    // How lit the tube is: warming up as you pull, flickering on at the
    // trigger point.
    final power = switch (frame.status) {
      FxRefreshStatus.drag || FxRefreshStatus.canceled =>
        0.32 * Curves.easeIn.transform(frame.progress),
      FxRefreshStatus.armed || FxRefreshStatus.snap => _flicker(kick.value),
      FxRefreshStatus.refresh || FxRefreshStatus.done => 1.0,
    };
    final settled = Curves.easeInOut.transform(settle.value);
    // While refreshing, a surge of light runs through the letters: 1 at its
    // head, lower on the letters it has not reached.
    double chase(int i) {
      if (frame.status != FxRefreshStatus.refresh || frame.reduceMotion) {
        return 1;
      }
      final head = math.pow(
        (1 + math.cos(2 * math.pi * (frame.spin.value - i / count))) / 2,
        4,
      );
      return lerpDouble(1, 0.35 + 0.65 * head, settled)!;
    }

    // White-hot on dark, the accent itself on light; the surge's head burns
    // brightest.
    Color core(int i) => dark
        ? Color.lerp(_hue(i), _white, 0.45 + 0.43 * chase(i) + 0.12 * flash)!
        : Color.lerp(_hue(i), _white, 0.3 * (1 - chase(i)))!;
    final off = _ink(dark ? 0.2 : 0.14);
    double lit(int i) => power * chase(i);

    void glow(double sigma, double strength) {
      canvas.saveLayer(
        bounds,
        Paint()..imageFilter = ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      );
      word.paint(canvas);
      canvas
        ..drawRect(
          bounds,
          Paint()
            ..blendMode = BlendMode.srcIn
            ..shader = _perLetter(
              size,
              (i) => _fade(_hue(i), strength * lit(i)),
            ),
        )
        ..restore();
    }

    // A wide halo and a tight one; softer on light, where a glow reads as
    // blur.
    glow(6 + 3 * flash, (dark ? 0.9 : 0.4) * (1 + 0.5 * flash));
    glow(2, dark ? 0.85 : 0.2);
    canvas.saveLayer(bounds, Paint());
    word.paint(canvas);
    canvas
      ..drawRect(
        bounds,
        Paint()
          ..blendMode = BlendMode.srcIn
          ..shader = _perLetter(
            size,
            (i) => Color.lerp(off, core(i), power.clamp(0.0, 1.0))!,
          ),
      )
      ..restore();
  }

  // ── textFlip ─────────────────────────────────────────────────────────────

  /// The angle of a roll at [t] from 0 to 1: the letter tips away to
  /// edge-on, then its face comes back from the other side.
  static double _roll(double t) => t < 0.5 ? t * math.pi : (t - 1) * math.pi;

  void _flip(Canvas canvas, Size size) {
    final letters = word.letters;
    final count = letters.length;
    if (count == 0) return;
    final rect = Offset.zero & size;
    final bounds = rect.inflate(16);
    final step = _WordPainter._step(count, 0.06, 0.45);
    final loopStep = _WordPainter._step(count, 0.06, 0.3);
    double kickRoll(int i) => Curves.easeInOut.transform(
      _interval(kick.value, i * step, i * step + 0.55),
    );
    double angle(int i) => switch (frame.status) {
      // Tipped back edge-on, flipping up into place in reading order.
      FxRefreshStatus.drag || FxRefreshStatus.canceled =>
        -math.pi /
            2 *
            (1 -
                Curves.easeOutBack.transform(
                  _interval(
                    frame.progress,
                    i / count * 0.55,
                    i / count * 0.55 + 0.45,
                  ),
                )),
      FxRefreshStatus.armed || FxRefreshStatus.snap => _roll(kickRoll(i)),
      // The rolls start a third into each cycle, after the kick's roll.
      FxRefreshStatus.refresh =>
        frame.reduceMotion
            ? 0
            : kickRoll(i) < 1
            ? _roll(kickRoll(i))
            : _roll(
                Curves.easeInOut.transform(
                  _interval(
                    frame.spin.value,
                    0.3 + i * loopStep,
                    0.65 + i * loopStep,
                  ),
                ),
              ),
      FxRefreshStatus.done => _roll(
        Curves.easeInOutCubic.transform(
          _interval(frame.exit.value, i * step * 0.8, i * step * 0.8 + 0.4),
        ),
      ),
    };

    // The hinge: halfway up the capitals, where a split-flap card folds.
    final hinge = word.baseline - word.ascent * 0.36;
    canvas.saveLayer(bounds, Paint());
    for (var i = 0; i < count; i++) {
      final a = angle(i);
      // Dimmer as it turns away, gone before it is a sliver.
      final shade = Curves.easeOut.transform(_interval(math.cos(a), 0.25, 1));
      if (shade <= 0) continue;
      final pivot = Offset(letters[i].center.dx, hinge);
      final column = _column(size, i);
      final turn = Matrix4.identity()
        ..setEntry(3, 2, 0.006)
        ..rotateX(a);
      canvas
        ..save()
        ..translate(pivot.dx, pivot.dy)
        ..transform(turn.storage)
        ..translate(-pivot.dx, -pivot.dy)
        ..clipRect(column);
      if (shade < 0.999) {
        canvas.saveLayer(column, Paint()..color = _fade(_white, shade));
      }
      word.paint(canvas);
      if (shade < 0.999) canvas.restore();
      canvas.restore();
    }
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.srcIn
        ..color = frame.foreground,
    );
    final accent = _accentShare;
    if (accent > 0) {
      canvas.drawRect(
        bounds,
        Paint()
          ..blendMode = BlendMode.srcATop
          ..shader = _accent(rect, accent),
      );
    }
    // The split between the flaps.
    canvas
      ..drawRect(
        Rect.fromLTRB(bounds.left, hinge - 0.6, bounds.right, hinge + 0.6),
        Paint()
          ..blendMode = BlendMode.dstOut
          ..color = _fade(_white, 0.75),
      )
      ..restore();
  }

  // ── textScramble ─────────────────────────────────────────────────────────

  /// Which of [n] symbols letter [i] shows at [tick].
  static int _pick(int i, int tick, int n) =>
      (((i + 1) * 73856093) ^ ((tick + 1) * 19349663)).abs() % n;

  void _scramble(Canvas canvas, Size size) {
    final letters = word.letters;
    final count = letters.length;
    if (count == 0) return;
    final rect = Offset.zero & size;
    final bounds = rect.inflate(16);
    final s = frame.spin.value;
    final e = frame.exit.value;
    final loopStep = _WordPainter._step(count, 0.09, 0.62);
    final doneStep = _WordPainter._step(count, 0.05, 0.3);
    // Decoded in reading order as you pull, re-decoded one by one while
    // refreshing, and all at once when done.
    bool scrambled(int i) => switch (frame.status) {
      FxRefreshStatus.drag ||
      FxRefreshStatus.canceled => frame.progress < (i + 1) / (count + 1),
      FxRefreshStatus.armed || FxRefreshStatus.snap => false,
      FxRefreshStatus.refresh =>
        !frame.reduceMotion && s - i * loopStep >= 0 && s - i * loopStep < 0.26,
      FxRefreshStatus.done => e < 0.14 + i * doneStep,
    };
    // Picks new symbols as you pull, and on its own while refreshing.
    final clock = switch (frame.status) {
      FxRefreshStatus.drag || FxRefreshStatus.canceled => frame.pull.value * 36,
      FxRefreshStatus.refresh => s * 30,
      _ => e * 26,
    };
    final tick = clock.floor();
    final mixed = [for (var i = 0; i < count; i++) scrambled(i)];

    canvas.saveLayer(bounds, Paint());
    for (var i = 0; i < count; i++) {
      if (mixed[i]) continue;
      canvas
        ..save()
        ..clipRect(_column(size, i));
      word.paint(canvas);
      canvas.restore();
    }
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.srcIn
        ..color = frame.foreground,
    );
    final accent = _accentShare;
    if (accent > 0) {
      canvas.drawRect(
        bounds,
        Paint()
          ..blendMode = BlendMode.srcATop
          ..shader = _accent(rect, accent),
      );
    }
    canvas.restore();

    if (!mixed.contains(true)) return;
    final symbols = word.symbols;
    canvas.saveLayer(bounds, Paint());
    for (var i = 0; i < count; i++) {
      if (!mixed[i]) continue;
      final symbol = symbols[_pick(i, tick, symbols.length)];
      final box = letters[i];
      final fit = (box.width * 1.2 / symbol.width).clamp(0.6, 1.0);
      final baseline = symbol.computeDistanceToActualBaseline(
        TextBaseline.alphabetic,
      );
      canvas
        ..save()
        ..translate(box.center.dx, word.baseline)
        ..scale(fit)
        ..translate(-symbol.width / 2, -baseline);
      symbol.paint(canvas, Offset.zero);
      canvas.restore();
    }
    canvas
      ..drawRect(
        bounds,
        Paint()
          ..blendMode = BlendMode.srcIn
          ..color = frame.beforeTrigger
              ? _ink(0.42)
              : _fade(
                  Color.lerp(frame.color, _white, frame.dark ? 0.4 : 0)!,
                  0.9,
                ),
      )
      ..restore();
  }

  // ── textOutline ──────────────────────────────────────────────────────────

  void _outline(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bounds = rect.inflate(16);
    final e = frame.exit.value;
    final settled = Curves.easeInOut.transform(settle.value);
    // How far the outline is drawn, how strongly it shows the accent, how
    // full the letters are, how far the accent has poured into them, and
    // where the light on the outline is.
    var drawn = 1.0;
    var tint = _accentShare;
    var flood = 0.0;
    var pour = 0.0;
    double? light;
    switch (frame.status) {
      case FxRefreshStatus.drag || FxRefreshStatus.canceled:
        drawn = Curves.easeInOut.transform(frame.progress);
      case FxRefreshStatus.armed || FxRefreshStatus.snap:
        // The letters flash full, then drain back to the outline.
        final k = kick.value;
        flood =
            0.85 *
            _interval(k, 0, 0.1) *
            (1 - Curves.easeIn.transform(_interval(k, 0.3, 1)));
      case FxRefreshStatus.refresh:
        tint = lerpDouble(1, 0.45, settled)!;
        flood = 0.14 * settled;
        if (!frame.reduceMotion) {
          light = lerpDouble(-0.3, 1.3, frame.spin.value);
        }
      case FxRefreshStatus.done:
        tint = lerpDouble(0.45, 1, _interval(e, 0, 0.3))!;
        flood = 0.14;
        pour = Curves.easeInOutCubic.transform(_interval(e, 0, 0.5));
    }

    if (flood > 0 || pour > 0) {
      canvas.saveLayer(bounds, Paint());
      word.paint(canvas);
      if (pour > 0) {
        canvas.drawRect(
          bounds,
          Paint()
            ..blendMode = BlendMode.srcIn
            ..color = Color.alphaBlend(
              _fade(frame.color, flood),
              _solidBackground,
            ),
        );
        _sweep(canvas, bounds, pour, _accent(rect));
      } else {
        canvas.drawRect(
          bounds,
          Paint()
            ..blendMode = BlendMode.srcIn
            ..shader = _accent(rect, flood),
        );
      }
      canvas.restore();
    }

    final outline = word.outline;
    if (drawn < 1) {
      // A faint guide to draw over.
      canvas.saveLayer(bounds, Paint());
      outline.paint(canvas, Offset.zero);
      canvas
        ..drawRect(
          bounds,
          Paint()
            ..blendMode = BlendMode.srcIn
            ..color = _fade(frame.foreground, frame.dark ? 0.16 : 0.1),
        )
        ..restore();
    }
    canvas.saveLayer(bounds, Paint());
    outline.paint(canvas, Offset.zero);
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.srcIn
        ..color =
            frame.status == FxRefreshStatus.refresh ||
                frame.status == FxRefreshStatus.done
            ? _solidBackground
            : _ink(0.85),
    );
    if (tint > 0) {
      canvas.drawRect(
        bounds,
        Paint()
          ..blendMode = BlendMode.srcATop
          ..shader = _accent(rect, tint),
      );
    }
    if (light != null) {
      final core = frame.dark
          ? Color.lerp(frame.color, _white, 0.6)!
          : frame.color;
      _band(canvas, size, light, _fade(core, settled));
    }
    _reveal(canvas, bounds, drawn);
    canvas.restore();
  }

  // ── textTypewriter ───────────────────────────────────────────────────────

  void _typewriter(Canvas canvas, Size size) {
    final letters = word.letters;
    final count = letters.length;
    final rect = Offset.zero & size;
    final bounds = rect.inflate(16);
    final e = frame.exit.value;
    final l = loop.value;
    final whole = count.toDouble();
    // The refresh loop: hold, delete, a beat with nothing, type, hold.
    double typedAt(double t) => t < 0.3
        ? whole
        : t < 0.55
        ? whole * (1 - _interval(t, 0.3, 0.55))
        : t < 0.63
        ? 0
        : t < 0.93
        ? whole * _interval(t, 0.63, 0.93)
        : whole;
    // How many letters are typed, fractional while one is going in.
    final typed = switch (frame.status) {
      FxRefreshStatus.drag ||
      FxRefreshStatus.canceled => whole * frame.progress,
      FxRefreshStatus.armed || FxRefreshStatus.snap => whole,
      FxRefreshStatus.refresh => typedAt(l),
      FxRefreshStatus.done => lerpDouble(
        typedAt(l),
        whole,
        Curves.easeOut.transform(_interval(e, 0, 0.3)),
      )!,
    };
    // The caret is steady while typing and blinks while the word rests.
    final resting =
        frame.status == FxRefreshStatus.refresh &&
        !frame.reduceMotion &&
        (l < 0.3 || l >= 0.93);
    final blinkTime = ((l - 0.93) % 1.0) * 2.6;
    final caret = switch (frame.status) {
      FxRefreshStatus.drag || FxRefreshStatus.canceled =>
        Curves.easeOut.transform(_interval(frame.progress, 0, 0.15)),
      FxRefreshStatus.armed || FxRefreshStatus.snap => 1.0,
      FxRefreshStatus.refresh =>
        resting
            ? (0.5 + 1.5 * math.cos(2 * math.pi * blinkTime / 1.05)).clamp(
                0.0,
                1.0,
              )
            : 1.0,
      FxRefreshStatus.done => 1 - _interval(e, 0.35, 0.55),
    };

    if (count > 0) {
      canvas.saveLayer(bounds, Paint());
      for (var i = 0; i < count; i++) {
        final shown = _interval(typed - i, 0, 0.3);
        if (shown <= 0) continue;
        final column = _column(size, i);
        if (shown < 1) {
          canvas.saveLayer(column, Paint()..color = _fade(_white, shown));
        } else {
          canvas.save();
        }
        // Struck onto the line: it grows up from the baseline.
        final grow = 0.7 + 0.3 * Curves.easeOutBack.transform(shown);
        final foot = Offset(letters[i].center.dx, word.baseline);
        canvas
          ..clipRect(column)
          ..translate(foot.dx, foot.dy)
          ..scale(grow)
          ..translate(-foot.dx, -foot.dy);
        word.paint(canvas);
        canvas.restore();
      }
      canvas.drawRect(
        bounds,
        Paint()
          ..blendMode = BlendMode.srcIn
          ..color = frame.foreground,
      );
      final accent = _accentShare;
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

    if (caret <= 0) return;
    final rtl = frame.rtl;
    final width = (word.fontSize * 0.085).clamp(1.6, 3.2);
    final gap = width * 0.9;
    final last = (typed.ceil() - 1).clamp(-1, count - 1);
    // After the last typed letter, or at the start of the word.
    final double left;
    if (count == 0) {
      left = rtl ? size.width - width : 0;
    } else if (last < 0) {
      left = rtl ? letters.first.right : letters.first.left - width;
    } else {
      left = rtl ? letters[last].left - gap - width : letters[last].right + gap;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          left,
          word.baseline - word.ascent * 0.9,
          left + width,
          word.baseline + word.descent * 0.6,
        ),
        Radius.circular(width / 2),
      ),
      Paint()..color = _fade(frame.color, caret),
    );
  }
}
