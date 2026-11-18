part of 'fx_refresh_styles.dart';

// The styles after the first five: morph, spokes, bars, infinity and flip.
// They share the floating placement, the kick, the surface and the drawing
// helpers in fx_refresh_styles.dart.

/// Draws [t] (0–1) of a check mark [width] wide around [center] in the
/// frame's gradient.
void _drawGradientCheck(
  Canvas canvas,
  Offset center,
  double width,
  double t,
  FxRefreshFrame frame, {
  double stroke = 2.8,
}) {
  _drawCheck(
    canvas,
    center,
    width,
    t,
    _stroke(frame.color, stroke)
      ..shader = _diagonal(
        frame,
      ).createShader(Rect.fromCircle(center: center, radius: width / 2)),
  );
}

/// Draws an arrow [box] wide, pointing down, or up when [up].
void _drawArrow(
  Canvas canvas,
  Offset center,
  double box,
  Color color, {
  bool up = false,
}) {
  final u = box / 16;
  final paint = _stroke(color, 2 * u);
  canvas
    ..save()
    ..translate(center.dx, center.dy);
  if (up) canvas.rotate(math.pi);
  canvas
    ..drawLine(Offset(0, -5 * u), Offset(0, 5 * u), paint)
    ..drawPath(
      Path()
        ..moveTo(-4.2 * u, 0.8 * u)
        ..lineTo(0, 5 * u)
        ..lineTo(4.2 * u, 0.8 * u),
      paint,
    )
    ..restore();
}

// ── morph ───────────────────────────────────────────────────────────────────

/// A glossy gradient shape that grows out of a circle with the pull, spins a
/// quarter turn with a pop at the trigger point, morphs through soft
/// many-lobed shapes while refreshing and settles into a disc with a check
/// mark when done.
class _MorphIndicator extends StatelessWidget {
  const _MorphIndicator(this.frame);

  static const double size = 44;

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) {
    return _Floating(
      frame: frame,
      extent: size,
      child: _ExitFade(
        frame: frame,
        from: 0.74,
        shrink: 0.4,
        child: _Kick(
          on: frame.status == FxRefreshStatus.armed,
          reduceMotion: frame.reduceMotion,
          builder: (context, kick) => SizedBox.square(
            dimension: size,
            child: CustomPaint(painter: _MorphPainter(frame, kick)),
          ),
        ),
      ),
    );
  }
}

class _MorphPainter extends CustomPainter {
  _MorphPainter(this.frame, this.kick)
    : super(repaint: Listenable.merge([frame.ticks, kick]));

  final FxRefreshFrame frame;
  final Animation<double> kick;

  static const double _radius = 19;
  static const double _depth = 0.12;

  /// The lobe counts the shape passes through in one refresh cycle; it ends
  /// where it began.
  static const List<int> _lobes = [4, 7, 5, 8];

  /// A soft polygon of [radius] around [center]: [from] lobes blending into
  /// [to] lobes by [t], [depth] deep, turned by [turn].
  static Path _shape(
    Offset center,
    double radius,
    double depth, {
    required int from,
    required int to,
    required double t,
    required double turn,
  }) {
    final path = Path();
    const steps = 120;
    for (var i = 0; i <= steps; i++) {
      final angle = 2 * math.pi * i / steps;
      final wave =
          (1 - t) * math.cos(from * (angle - turn)) +
          t * math.cos(to * (angle - turn));
      final point =
          center +
          Offset(math.cos(angle), math.sin(angle)) *
              (radius * (1 + depth * wave) / (1 + depth));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  /// The refreshing shape at spin phase [s]: each shape holds a moment, then
  /// morphs into the next, while the whole turns once per cycle.
  static ({int from, int to, double t, double turn}) _cycle(double s) {
    final segment = s * _lobes.length;
    final index = segment.floor() % _lobes.length;
    return (
      from: _lobes[index],
      to: _lobes[(index + 1) % _lobes.length],
      t: Curves.easeInOutCubic.transform(
        _interval(segment - segment.floor(), 0.35, 1),
      ),
      turn: 2 * math.pi * s,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    var radius = _radius;
    var depth = _depth;
    var check = 0.0;
    ({int from, int to, double t, double turn}) shape = (
      from: _lobes.first,
      to: _lobes.first,
      t: 0,
      turn: 0,
    );
    switch (frame.status) {
      case FxRefreshStatus.refresh:
        if (!frame.reduceMotion) shape = _cycle(frame.spin.value);
      case FxRefreshStatus.done:
        // The lobes smooth out into a disc that pops as a check draws on it.
        final e = frame.exit.value;
        if (!frame.reduceMotion) shape = _cycle(frame.spin.value);
        depth *= 1 - Curves.easeOutCubic.transform(_interval(e, 0, 0.3));
        radius *= 1 + 0.1 * _bump(_interval(e, 0.15, 0.75));
        check = Curves.easeOutCubic.transform(_interval(e, 0.25, 0.55));
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.canceled:
        final p = frame.progress;
        radius *=
            lerpDouble(0.45, 1, Curves.easeOut.transform(p))! *
            (1 + 0.06 * Curves.easeOut.transform(frame.overpull)) *
            (1 + 0.14 * _bump(kick.value));
        // A circle that grows lobes with the pull.
        depth *= Curves.easeOut.transform(_interval(p, 0.25, 1));
        // A quarter turn with the pull and another at the trigger point: the
        // four-lobed shape looks the same after each, so the refresh picks
        // up where this leaves off.
        final spun = frame.beforeTrigger
            ? 0.0
            : Curves.easeOutBack.transform(kick.value);
        shape = (
          from: _lobes.first,
          to: _lobes.first,
          t: 0,
          turn: math.pi / 2 * (p + spun),
        );
    }

    final path = _shape(
      center,
      radius,
      depth,
      from: shape.from,
      to: shape.to,
      t: shape.t,
      turn: shape.turn,
    );
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas
      ..drawPath(
        path.shift(const Offset(0, 4)),
        Paint()
          ..color = frame.dark
              ? const Color(0x80000000)
              : _fade(frame.color, 0.38)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawPath(path, Paint()..shader = _diagonal(frame).createShader(bounds))
      // A soft gloss from the upper left.
      ..drawPath(
        path,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.45, -0.55),
            radius: 0.85,
            colors: [Color(0x47FFFFFF), Color(0x00FFFFFF)],
          ).createShader(bounds),
      );
    _drawCheck(canvas, center, 16, check, _stroke(frame.onAccent, 2.6));
  }

  @override
  bool shouldRepaint(_MorphPainter old) =>
      !old.frame.sameLook(frame) || old.kick != kick;
}

// ── spokes ──────────────────────────────────────────────────────────────────

/// Gradient petals on a frosted disc that appear one by one around the dial
/// with the pull and flash at the trigger point, chase each other round
/// while refreshing and fly off around a check mark when done.
class _SpokesIndicator extends StatelessWidget {
  const _SpokesIndicator(this.frame);

  static const double size = 46;

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) {
    return _Floating(
      frame: frame,
      extent: size,
      child: _ExitFade(
        frame: frame,
        from: 0.72,
        shrink: 0.3,
        child: _Kick(
          on: frame.status == FxRefreshStatus.armed,
          reduceMotion: frame.reduceMotion,
          builder: (context, kick) => AnimatedBuilder(
            animation: Listenable.merge([kick, frame.pull]),
            builder: (context, child) => Transform.scale(
              scale:
                  1 +
                  0.1 * _bump(kick.value) +
                  0.05 * Curves.easeOut.transform(frame.overpull),
              child: child,
            ),
            child: _Surface(
              frame: frame,
              radius: size / 2,
              child: SizedBox.square(
                dimension: size,
                child: CustomPaint(painter: _SpokesPainter(frame, kick)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpokesPainter extends CustomPainter {
  _SpokesPainter(this.frame, this.kick)
    : super(repaint: Listenable.merge([frame.ticks, kick]));

  final FxRefreshFrame frame;
  final Animation<double> kick;

  static const int _count = 8;
  static const double _inner = 6.5;
  static const double _outer = 13;
  static const double _width = 3.2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    Color tone(int i) =>
        Color.lerp(frame.secondary, frame.color, i / (_count - 1))!;
    // Spoke i, from [from] along its length (0 inner end, 1 outer end) for
    // [length] of it.
    void spoke(int i, double opacity, {double from = 0, double length = 1}) {
      if (opacity <= 0 || length <= 0.02) return;
      final angle = -math.pi / 2 + 2 * math.pi * i / _count;
      final along = Offset(math.cos(angle), math.sin(angle));
      const span = _outer - _inner;
      canvas.drawLine(
        center + along * (_inner + span * from),
        center + along * (_inner + span * (from + length)),
        _stroke(_fade(tone(i), opacity), _width),
      );
    }

    switch (frame.status) {
      case FxRefreshStatus.refresh:
        // A bright head goes round once per cycle; each spoke lights up just
        // before the head reaches it and fades away behind.
        final head = frame.reduceMotion ? 0.0 : frame.spin.value * _count;
        const rise = 0.6;
        for (var i = 0; i < _count; i++) {
          final behind = (head - i) % _count;
          final glow = behind > _count - rise
              ? (behind - (_count - rise)) / rise
              : math.pow(1 - behind / (_count - rise), 1.6).toDouble();
          spoke(i, 0.2 + 0.8 * glow);
        }
      case FxRefreshStatus.done:
        // The petals fly outward one after another and a check pops in.
        final e = frame.exit.value;
        for (var i = 0; i < _count; i++) {
          final gone = Curves.easeInCubic.transform(
            _interval(e, i * 0.022, i * 0.022 + 0.3),
          );
          spoke(i, 1 - gone, from: gone, length: 1 - gone);
        }
        _drawGradientCheck(
          canvas,
          center,
          15 * (1 + 0.15 * _bump(_interval(e, 0.28, 0.85))),
          Curves.easeOutCubic.transform(_interval(e, 0.28, 0.56)),
          frame,
        );
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.canceled:
        final p = frame.progress;
        final ready = !frame.beforeTrigger;
        for (var i = 0; i < _count; i++) {
          // One by one around the dial with the pull, then a flash that runs
          // round at the trigger point.
          final local = _interval(p, i / _count * 0.8, i / _count * 0.8 + 0.2);
          final flash = ready
              ? _bump(_interval(kick.value, i * 0.05, i * 0.05 + 0.5))
              : 0.0;
          spoke(
            i,
            ready ? 1 : 0.35 + 0.65 * local,
            length: Curves.easeOutBack.transform(local) * (1 + 0.3 * flash),
          );
        }
    }
  }

  @override
  bool shouldRepaint(_SpokesPainter old) =>
      !old.frame.sameLook(frame) || old.kick != kick;
}

// ── bars ────────────────────────────────────────────────────────────────────

/// Five gradient bars on a frosted tile that rise like a signal meter with
/// the pull and hop at the trigger point, dance like an equalizer while
/// refreshing and fall away around a check mark when done.
class _BarsIndicator extends StatelessWidget {
  const _BarsIndicator(this.frame);

  static const double size = 46;

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) {
    return _Floating(
      frame: frame,
      extent: size,
      child: _ExitFade(
        frame: frame,
        from: 0.74,
        shrink: 0.3,
        child: _Kick(
          on: frame.status == FxRefreshStatus.armed,
          reduceMotion: frame.reduceMotion,
          // A second kick eases the meter into the dance.
          builder: (context, kick) => _Kick(
            on: frame.status == FxRefreshStatus.refresh,
            reduceMotion: frame.reduceMotion,
            builder: (context, settle) => _Surface(
              frame: frame,
              radius: 15,
              child: SizedBox.square(
                dimension: size,
                child: CustomPaint(painter: _BarsPainter(frame, kick, settle)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.frame, this.kick, this.settle)
    : super(repaint: Listenable.merge([frame.ticks, kick, settle]));

  final FxRefreshFrame frame;
  final Animation<double> kick;
  final Animation<double> settle;

  static const int _count = 5;
  static const double _width = 3.6;
  static const double _gap = 3.4;
  static const double _tall = 22;

  /// Beats per refresh cycle, and where in its beat each bar starts.
  static const List<int> _beats = [2, 3, 2, 3, 2];
  static const List<double> _offsets = [0, 0.35, 0.7, 0.15, 0.5];

  /// Bar [i]'s height in the signal meter.
  static double _meter(int i) => lerpDouble(8, _tall, i / (_count - 1))!;

  /// Bar [i]'s height in the dance at spin phase [s].
  static double _dance(int i, double s) => lerpDouble(
    6,
    _tall,
    0.5 - 0.5 * math.cos(2 * math.pi * (_beats[i] * s + _offsets[i])),
  )!;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const total = _count * _width + (_count - 1) * _gap;
    // The meter rises in the text direction.
    double x(int i) =>
        center.dx -
        total / 2 +
        _width / 2 +
        (frame.rtl ? _count - 1 - i : i) * (_width + _gap);
    Color tone(int i) =>
        Color.lerp(frame.secondary, frame.color, i / (_count - 1))!;
    void bar(int i, double height, {double opacity = 1, double lift = 0}) {
      if (opacity <= 0 || height <= 0.2) return;
      final width = math.min(_width, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x(i), center.dy - lift),
            width: width,
            height: height,
          ),
          Radius.circular(width / 2),
        ),
        Paint()..color = _fade(tone(i), opacity),
      );
    }

    switch (frame.status) {
      case FxRefreshStatus.refresh:
        final s = frame.reduceMotion ? 0.0 : frame.spin.value;
        final blend = Curves.easeInOut.transform(settle.value);
        for (var i = 0; i < _count; i++) {
          bar(i, lerpDouble(_meter(i), _dance(i, s), blend)!);
        }
      case FxRefreshStatus.done:
        // The bars drop to dots one after another and a check draws over
        // them.
        final e = frame.exit.value;
        final s = frame.reduceMotion ? 0.0 : frame.spin.value;
        for (var i = 0; i < _count; i++) {
          final drop = Curves.easeInOutCubic.transform(
            _interval(e, i * 0.03, i * 0.03 + 0.22),
          );
          bar(
            i,
            lerpDouble(_dance(i, s), _width, drop)!,
            opacity: 1 - _interval(e, 0.24, 0.38),
          );
        }
        _drawGradientCheck(
          canvas,
          center,
          16 * (1 + 0.15 * _bump(_interval(e, 0.3, 0.85))),
          Curves.easeOutCubic.transform(_interval(e, 0.3, 0.6)),
          frame,
        );
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.canceled:
        final p = frame.progress;
        final swell = 1 + 0.15 * Curves.easeOut.transform(frame.overpull);
        for (var i = 0; i < _count; i++) {
          final local = _interval(p, i * 0.12, i * 0.12 + 0.5);
          final hop = frame.beforeTrigger
              ? 0.0
              : 5 * _bump(_interval(kick.value, i * 0.08, i * 0.08 + 0.6));
          bar(
            i,
            _meter(i) * Curves.easeOutBack.transform(local) * swell,
            opacity: 0.4 + 0.6 * local,
            lift: hop,
          );
        }
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      !old.frame.sameLook(frame) || old.kick != kick || old.settle != settle;
}

// ── infinity ────────────────────────────────────────────────────────────────

/// An infinity loop on a frosted pill that draws itself with the pull and
/// glows at the trigger point, carries a comet round while refreshing and
/// unties into a check mark when done.
class _InfinityIndicator extends StatelessWidget {
  const _InfinityIndicator(this.frame);

  static const Size size = Size(76, 36);

  final FxRefreshFrame frame;

  @override
  Widget build(BuildContext context) {
    return _Floating(
      frame: frame,
      extent: size.height,
      child: _ExitFade(
        frame: frame,
        from: 0.78,
        shrink: 0.25,
        child: _Kick(
          on: frame.status == FxRefreshStatus.armed,
          reduceMotion: frame.reduceMotion,
          builder: (context, kick) => AnimatedBuilder(
            animation: kick,
            builder: (context, child) => Transform.scale(
              scale: 1 + 0.08 * _bump(kick.value),
              child: child,
            ),
            child: _Surface(
              frame: frame,
              radius: size.height / 2,
              child: SizedBox.fromSize(
                size: size,
                child: CustomPaint(painter: _InfinityPainter(frame, kick)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfinityPainter extends CustomPainter {
  _InfinityPainter(this.frame, this.kick)
    : super(repaint: Listenable.merge([frame.ticks, kick]));

  final FxRefreshFrame frame;
  final Animation<double> kick;

  /// Half the loop's width.
  static const double _half = 25;
  static const double _width = 3;
  static const int _samples = 96;

  /// The point [t] (0–1) of the way round a lemniscate centered on
  /// [center], from its left end.
  static Offset _loop(Offset center, double t) {
    final a = 2 * math.pi * t + math.pi;
    final s = math.sin(a);
    final c = math.cos(a);
    final d = 1 + s * s;
    return center + Offset(_half * c / d, 1.15 * _half * s * c / d);
  }

  /// The point [t] (0–1) of the way along a check mark around [center].
  static Offset _check(Offset center, double t) {
    const u = 18 / 12;
    final a = center + const Offset(-5 * u, 0.3 * u);
    final b = center + const Offset(-1.6 * u, 3.6 * u);
    final c = center + const Offset(5.2 * u, -3.6 * u);
    final first = (b - a).distance;
    final along = t * (first + (c - b).distance);
    return along <= first
        ? Offset.lerp(a, b, along / first)!
        : Offset.lerp(b, c, (along - first) / (c - b).distance)!;
  }

  /// Strokes [from]–[to] along [metric], wrapping round the closed loop.
  static void _span(
    Canvas canvas,
    PathMetric metric,
    double from,
    double to,
    Paint paint,
  ) {
    final length = metric.length;
    if (to - from <= 0.01) return;
    var start = from % length;
    var end = start + (to - from);
    if (end <= length) {
      canvas.drawPath(metric.extractPath(start, end), paint);
      return;
    }
    canvas.drawPath(metric.extractPath(start, length), paint);
    start = 0;
    end -= length;
    canvas.drawPath(metric.extractPath(start, end), paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final loop = Path()
      ..addPolygon([
        for (var i = 0; i <= _samples; i++) _loop(center, i / _samples),
      ], true);
    final metric = loop.computeMetrics().first;
    final length = metric.length;
    final accent = frame.color;
    final track = _fade(accent, frame.dark ? 0.22 : 0.13);
    final bounds = Rect.fromCenter(
      center: center,
      width: 2 * _half,
      height: _half,
    );
    Paint line({double width = _width}) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Shader shade(double opacity) => LinearGradient(
      colors: [_fade(frame.secondary, opacity), _fade(accent, opacity)],
    ).createShader(bounds);

    switch (frame.status) {
      case FxRefreshStatus.refresh:
        canvas.drawPath(loop, line()..color = track);
        if (frame.reduceMotion) {
          canvas.drawPath(loop, line()..shader = shade(1));
          return;
        }
        // A comet: pieces from the tail to the head that shade from the
        // track's color up through the partner color to the accent. They
        // are opaque, so their overlaps do not show.
        final head = frame.spin.value * length;
        final base = Color.alphaBlend(
          track,
          frame.background.withValues(alpha: 1),
        );
        const pieces = 18;
        const tail = 0.42;
        for (var k = 0; k < pieces; k++) {
          final shade = (k + 1) / pieces;
          _span(
            canvas,
            metric,
            head - length * tail * (1 - k / pieces),
            head - length * tail * (1 - (k + 1) / pieces),
            line()
              ..color = shade < 0.5
                  ? Color.lerp(base, frame.secondary, shade * 2)!
                  : Color.lerp(frame.secondary, accent, shade * 2 - 1)!,
          );
        }
        canvas.drawCircle(
          metric.getTangentForOffset(head % length)!.position,
          _width * 1.6,
          Paint()
            ..color = _fade(accent, 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      case FxRefreshStatus.done:
        // The whole loop lights up, then unties into a check mark that
        // pops.
        final e = frame.exit.value;
        final lit = Curves.easeOutCubic.transform(_interval(e, 0, 0.2));
        final untie = Curves.easeInOutCubic.transform(_interval(e, 0.2, 0.58));
        final pop = 1 + 0.14 * _bump(_interval(e, 0.5, 0.95));
        canvas.drawPath(loop, line()..color = _fade(track, 1 - untie));
        final points = [
          for (var i = 0; i <= _samples; i++)
            center +
                (Offset.lerp(
                          _loop(center, i / _samples),
                          _check(center, i / _samples),
                          untie,
                        )! -
                        center) *
                    pop,
        ];
        canvas.drawPath(
          Path()..addPolygon(points, untie == 0),
          line(width: lerpDouble(_width, 2.8, untie)!)
            ..shader = shade(lerpDouble(0.6, 1, lit)!),
        );
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.canceled:
        final p = frame.progress;
        canvas.drawPath(
          loop,
          line()..color = _fade(track, Curves.easeOut.transform(p)),
        );
        if (!frame.beforeTrigger) {
          canvas.drawPath(
            loop,
            line(width: 7)
              ..color = _fade(accent, 0.3 + 0.3 * _bump(kick.value))
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
        }
        // The loop draws itself from its left end with the pull.
        _span(
          canvas,
          metric,
          0,
          length * Curves.easeInOut.transform(p),
          line()..shader = shade(1),
        );
    }
  }

  @override
  bool shouldRepaint(_InfinityPainter old) =>
      !old.frame.sameLook(frame) || old.kick != kick;
}

// ── flip ────────────────────────────────────────────────────────────────────

/// What the flip tile shows.
enum _FlipGlyph { down, up, refresh, check }

/// The flip tile's pose: `tilt` about the horizontal axis, `turn` about the
/// vertical one, the `glyph` on it and how much of the check is drawn.
typedef _FlipPose = ({
  double tilt,
  double turn,
  _FlipGlyph glyph,
  double check,
});

/// A gradient tile that tips up into view in 3D with the pull, flips over
/// at the trigger point, keeps flipping while refreshing and lands on a
/// check mark when done.
class _FlipIndicator extends StatelessWidget {
  const _FlipIndicator(this.frame);

  static const double size = 38;

  final FxRefreshFrame frame;

  /// The refreshing turn for [frame]'s spin: a half turn per half cycle that
  /// eases in and out, starting face down after the flip at the trigger
  /// point.
  static double _spinTurn(FxRefreshFrame frame) {
    if (frame.reduceMotion) return math.pi;
    final u = frame.spin.value * 2;
    final half = u.floor();
    return math.pi * (1 + half + Curves.easeInOutCubic.transform(u - half));
  }

  static _FlipPose _pose(FxRefreshFrame frame, double kick) {
    switch (frame.status) {
      case FxRefreshStatus.drag || FxRefreshStatus.canceled:
        // Tips up from lying flat.
        final rise = Curves.easeOutCubic.transform(
          _interval(frame.progress, 0, 0.8),
        );
        return (
          tilt: -math.pi / 2 * (1 - rise),
          turn: 0,
          glyph: _FlipGlyph.down,
          check: 0,
        );
      case FxRefreshStatus.armed || FxRefreshStatus.snap:
        // Flips over, and the arrow turns to point up.
        final turn = math.pi * Curves.easeOutBack.transform(kick);
        return (
          tilt: 0,
          turn: turn,
          glyph: turn > math.pi / 2 ? _FlipGlyph.up : _FlipGlyph.down,
          check: 0,
        );
      case FxRefreshStatus.refresh:
        return (
          tilt: frame.reduceMotion
              ? 0
              : 0.22 * math.sin(2 * math.pi * frame.spin.value),
          turn: _spinTurn(frame),
          glyph: _FlipGlyph.refresh,
          check: 0,
        );
      case FxRefreshStatus.done:
        // One or two more half turns, landing on the check.
        final e = frame.exit.value;
        final from = _spinTurn(frame);
        final to = ((from / math.pi).floor() + 2) * math.pi;
        final land = Curves.easeOutBack.transform(_interval(e, 0, 0.45));
        final turn = lerpDouble(from, to, land)!;
        final tilt = frame.reduceMotion
            ? 0.0
            : 0.22 * math.sin(2 * math.pi * frame.spin.value);
        return (
          tilt: tilt * (1 - land),
          turn: turn,
          glyph: turn > to - math.pi / 2
              ? _FlipGlyph.check
              : _FlipGlyph.refresh,
          check: Curves.easeOutCubic.transform(_interval(e, 0.06, 0.38)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Floating(
      frame: frame,
      extent: size,
      child: _ExitFade(
        frame: frame,
        from: 0.76,
        shrink: 0.35,
        child: _Kick(
          on: frame.status == FxRefreshStatus.armed,
          reduceMotion: frame.reduceMotion,
          builder: (context, kick) => AnimatedBuilder(
            animation: Listenable.merge([frame.ticks, kick]),
            builder: (context, _) {
              final pose = _pose(frame, kick.value);
              final done = frame.status == FxRefreshStatus.done;
              return Transform.scale(
                scale:
                    1 +
                    0.06 * Curves.easeOut.transform(frame.overpull) +
                    (done
                        ? 0.12 * _bump(_interval(frame.exit.value, 0.3, 0.8))
                        : 0),
                child: SizedBox.square(
                  dimension: size,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _FlipShadowPainter(frame, pose),
                        ),
                      ),
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0022)
                          ..rotateX(pose.tilt)
                          ..rotateY(pose.turn),
                        child: CustomPaint(
                          size: const Size.square(size),
                          painter: _FlipFacePainter(frame, pose),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// How squarely the flip tile faces the viewer: 1 front on, −1 back on, 0
/// edge on.
double _facing(_FlipPose pose) => math.cos(pose.turn) * math.cos(pose.tilt);

class _FlipFacePainter extends CustomPainter {
  const _FlipFacePainter(this.frame, this.pose);

  final FxRefreshFrame frame;
  final _FlipPose pose;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final tile = RRect.fromRectAndRadius(rect, const Radius.circular(11));
    final facing = _facing(pose);
    // The face darkens as it turns edge on, and a sheen slides across it.
    final sweep = math.sin(pose.turn);
    canvas
      ..drawRRect(tile, Paint()..shader = _diagonal(frame).createShader(rect))
      ..drawRRect(
        tile,
        Paint()..color = Color.fromRGBO(0, 0, 0, 0.35 * (1 - facing.abs())),
      )
      ..drawRRect(
        tile,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment(-1 + sweep, -1),
            end: Alignment(1 + sweep, 1),
            colors: const [
              Color(0x00FFFFFF),
              Color(0x38FFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: const [0.3, 0.5, 0.7],
          ).createShader(rect),
      );

    // The back of the tile shows mirrored; mirror the glyph back so it reads.
    final center = size.center(Offset.zero);
    final ink = frame.onAccent;
    canvas.save();
    if (facing < 0) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    switch (pose.glyph) {
      case _FlipGlyph.down || _FlipGlyph.up:
        _drawArrow(canvas, center, 18, ink, up: pose.glyph == _FlipGlyph.up);
      case _FlipGlyph.refresh:
        const start = -math.pi / 2 + 0.6;
        const sweep = 2 * math.pi - 1.4;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: 6.5),
          start,
          sweep,
          false,
          _stroke(ink, 2.2),
        );
        _drawArrowHead(canvas, center, 6.5, start + sweep, 0.8, ink);
      case _FlipGlyph.check:
        _drawCheck(canvas, center, 17, pose.check, _stroke(ink, 2.6));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FlipFacePainter old) =>
      !old.frame.sameLook(frame) || old.pose != pose;
}

/// The soft shadow under the flip tile, narrowing as the tile turns edge on.
class _FlipShadowPainter extends CustomPainter {
  const _FlipShadowPainter(this.frame, this.pose);

  final FxRefreshFrame frame;
  final _FlipPose pose;

  @override
  void paint(Canvas canvas, Size size) {
    final light = _facing(pose).abs();
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height + 5),
        width: size.width * (0.35 + 0.55 * light),
        height: 7,
      ),
      Paint()
        ..color = frame.dark
            ? const Color(0x80000000)
            : _fade(frame.color, 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(_FlipShadowPainter old) =>
      !old.frame.sameLook(frame) || old.pose != pose;
}
