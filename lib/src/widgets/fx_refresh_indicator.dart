import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';
import 'package:save_points_animations/src/widgets/fx_refresh_styles.dart';

// Geometry and timing match Material's RefreshIndicator, so swapping one for
// the other keeps the same feel and the same trigger point.

/// How far the user must drag, as a fraction of the viewport, for the
/// indicator to reach its full pull.
const double _kDragContainerExtentPercentage = 0.25;

/// The indicator travels up to this many times its resting displacement; it
/// arms at 1 / this of the full pull.
const double _kDragSizeFactorLimit = 1.5;

/// Time to settle at the resting displacement after release.
const Duration _kSnapDuration = Duration(milliseconds: 150);

/// Time to retract when the user lets go before the trigger point.
const Duration _kCancelDuration = Duration(milliseconds: 200);

/// One cycle of the refreshing animation.
const Duration _kSpinPeriod = Duration(milliseconds: 1200);

/// The look of an [FxRefreshIndicator]. Each style has its own shape and its
/// own motion for the pull, the refresh and the finish.
enum FxRefreshStyle {
  /// A floating glass disc: a gradient refresh arrow winds up as you pull,
  /// closes into a glowing ring with a pop at the trigger point, orbits as a
  /// comet while refreshing and floods with the accent behind a check mark
  /// when done.
  ring,

  /// A floating glass pill that grows out of a round badge as you pull: an
  /// arrow that flips at the trigger point and a label that reads pull,
  /// release, refreshing (with a sheen) and done in turn (see
  /// [FxRefreshLabels]). It floods with the accent when done.
  capsule,

  /// A glossy drop stretched out of the top edge that snaps free with a
  /// jiggle at the trigger point, wobbles around a spinner while refreshing
  /// and bursts into droplets when done.
  liquid,

  /// Three gradient dots on a glass pill that rise in as you pull, ripple at
  /// the trigger point, bounce while refreshing and merge into a check badge
  /// when done.
  dots,

  /// A gradient string along the top edge that bows down as you pull, glows
  /// at the trigger point and twangs back when let go, carries a comet while
  /// refreshing and flashes out from the middle when done.
  line,

  /// A glossy gradient shape that grows out of a circle as you pull, spins
  /// with a pop at the trigger point, morphs through soft many-lobed shapes
  /// while refreshing and settles into a disc with a check mark when done.
  morph,

  /// Petals on a frosted disc that appear one by one around the dial as you
  /// pull and flash at the trigger point, chase each other round while
  /// refreshing and fly off around a check mark when done.
  spokes,

  /// Five gradient bars on a frosted tile that rise like a signal meter as
  /// you pull and hop at the trigger point, dance like an equalizer while
  /// refreshing and fall away around a check mark when done.
  bars,

  /// An infinity loop on a frosted pill that draws itself as you pull and
  /// glows at the trigger point, carries a comet round while refreshing and
  /// unties into a check mark when done.
  infinity,

  /// A gradient tile that tips up into view in 3D as you pull, flips over at
  /// the trigger point, keeps flipping while refreshing and lands on a check
  /// mark when done.
  flip,

  /// Your word (see [FxRefreshIndicator.text]) on a frosted pill, filling
  /// with a gradient liquid as you pull. The liquid splashes to the top at
  /// the trigger point, sloshes up and down while refreshing and fills the
  /// word with a shine when done.
  textFill,

  /// Your word (see [FxRefreshIndicator.text]) on a frosted pill whose
  /// letters rise in one by one as you pull, turn to the accent gradient
  /// with a hop at the trigger point, ride a wave while refreshing and pop
  /// in turn when done.
  textWave,

  /// Your word (see [FxRefreshIndicator.text]) on a frosted pill, written in
  /// the text direction as you pull and lit with the accent at the trigger
  /// point. A band of light sweeps across it while refreshing, and a last
  /// sweep fills it with the accent when done.
  textShimmer,

  /// Your word (see [FxRefreshIndicator.text]) as a neon sign that warms up
  /// as you pull and flickers on at the trigger point. Its letters light in
  /// a chase while refreshing, and it flashes bright when done.
  textNeon,

  /// Your word (see [FxRefreshIndicator.text]) whose letters flip up into
  /// place in 3D as you pull, like a split-flap board. They roll over in
  /// turn at the trigger point and while refreshing, and land in the accent
  /// when done.
  textFlip,

  /// Your word (see [FxRefreshIndicator.text]) decoded from scrambled
  /// symbols as you pull. Its letters turn to the accent at the trigger
  /// point, scramble and decode one after another while refreshing, and all
  /// decode at once when done.
  textScramble,

  /// Your word (see [FxRefreshIndicator.text]) as an outline that draws
  /// itself as you pull and flashes full at the trigger point. A light runs
  /// along the outline while refreshing, and the accent pours into it when
  /// done.
  textOutline,

  /// Your word (see [FxRefreshIndicator.text]) typed letter by letter as
  /// you pull, with a blinking caret. It turns to the accent at the trigger
  /// point, is deleted and typed again while refreshing, and finishes typing
  /// when done.
  textTypewriter,
}

/// Where an [FxRefreshIndicator] is in a pull-to-refresh gesture. Matches the
/// states of Material's `RefreshIndicatorStatus`.
enum FxRefreshStatus {
  /// The user is dragging, short of the trigger point.
  drag,

  /// Dragged far enough that letting go runs `onRefresh`.
  armed,

  /// Settling at the resting position before `onRefresh` runs.
  snap,

  /// `onRefresh` is running.
  refresh,

  /// `onRefresh` completed; the finish animation is playing.
  done,

  /// Let go before the trigger point; the indicator is retracting.
  canceled,
}

/// Which drags can start a refresh.
enum FxRefreshTriggerMode {
  /// Only a drag that starts while the scrollable is at its leading edge.
  onEdge,

  /// Also a drag that starts mid-list and carries on past the edge.
  anywhere,
}

/// The texts of [FxRefreshStyle.capsule], one per stage. Pass translations to
/// localize them.
@immutable
class FxRefreshLabels {
  /// Creates the capsule texts; each defaults to English.
  const FxRefreshLabels({
    this.pull = 'Pull to refresh',
    this.release = 'Release to refresh',
    this.refreshing = 'Refreshing…',
    this.done = 'Updated',
  });

  /// Shown while dragging, short of the trigger point.
  final String pull;

  /// Shown once letting go would refresh.
  final String release;

  /// Shown while `onRefresh` runs.
  final String refreshing;

  /// Shown briefly after `onRefresh` completes.
  final String done;

  @override
  bool operator ==(Object other) =>
      other is FxRefreshLabels &&
      other.pull == pull &&
      other.release == release &&
      other.refreshing == refreshing &&
      other.done == done;

  @override
  int get hashCode => Object.hash(pull, release, refreshing, done);
}

/// App-wide defaults for every [FxRefreshIndicator] below it: the style, the
/// colors, the capsule texts and the word of the text styles. An argument on
/// the indicator itself wins.
///
/// Put it above your screens, for example in `MaterialApp.builder`, so the
/// indicators use your brand color:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => FxRefreshTheme(
///     style: FxRefreshStyle.ring,
///     color: Theme.of(context).colorScheme.primary,
///     child: child!,
///   ),
/// );
/// ```
class FxRefreshTheme extends InheritedWidget {
  /// Creates refresh-indicator defaults for [child].
  const FxRefreshTheme({
    super.key,
    this.style,
    this.color,
    this.secondaryColor,
    this.backgroundColor,
    this.labels,
    this.text,
    this.textStyle,
    required super.child,
  });

  /// Default [FxRefreshIndicator.style].
  final FxRefreshStyle? style;

  /// Default [FxRefreshIndicator.color].
  final Color? color;

  /// Default [FxRefreshIndicator.secondaryColor].
  final Color? secondaryColor;

  /// Default [FxRefreshIndicator.backgroundColor].
  final Color? backgroundColor;

  /// Default [FxRefreshIndicator.labels].
  final FxRefreshLabels? labels;

  /// Default [FxRefreshIndicator.text], such as your app's name.
  final String? text;

  /// Default [FxRefreshIndicator.textStyle], such as your brand font.
  final TextStyle? textStyle;

  /// The nearest [FxRefreshTheme] above [context], if any.
  static FxRefreshTheme? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FxRefreshTheme>();

  @override
  bool updateShouldNotify(FxRefreshTheme oldWidget) =>
      style != oldWidget.style ||
      color != oldWidget.color ||
      secondaryColor != oldWidget.secondaryColor ||
      backgroundColor != oldWidget.backgroundColor ||
      labels != oldWidget.labels ||
      text != oldWidget.text ||
      textStyle != oldWidget.textStyle;
}

/// Pull-to-refresh for any vertical scrollable, in one of eighteen
/// [FxRefreshStyle]s.
///
/// It works like Material's `RefreshIndicator`: drag the [child] past its top
/// edge and let go to run [onRefresh]; the indicator stays until the returned
/// future completes, then plays its finish animation. The trigger point,
/// [triggerMode], [notificationPredicate] and [FxRefreshIndicatorState.show]
/// behave the same, so it can replace one without changing your refresh
/// logic. Unlike `RefreshIndicator` it needs no Material ancestor, and
/// letting go anywhere past the trigger point refreshes, on every platform:
/// `RefreshIndicator` does so with bouncing (iOS) scroll physics, but with
/// clamping (Android) physics it waits for a pull half as long again.
///
/// ```dart
/// FxRefreshIndicator(
///   style: FxRefreshStyle.liquid,
///   onRefresh: () => repository.reload(),
///   child: ListView(children: tiles),
/// );
/// ```
///
/// **Colors.** By default the indicator draws in the surrounding text color
/// ([DefaultTextStyle]) on a frosted light or dark surface picked to match
/// it, so it follows Material, Cupertino and custom themes in light and dark
/// mode. Pass [color] (your brand color), [secondaryColor] and
/// [backgroundColor], or set them app-wide with [FxRefreshTheme].
///
/// The [child] must be a scrollable that can overscroll or bounce at its top,
/// such as a [ListView] with `AlwaysScrollableScrollPhysics` when the content
/// may be shorter than the screen. Horizontal scrollables are ignored.
///
/// Under the OS "reduce motion" setting the indicator still follows the
/// finger, but holds a still frame while refreshing and skips the finish
/// animation.
class FxRefreshIndicator extends StatefulWidget {
  /// Creates a pull-to-refresh indicator around [child].
  const FxRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.style,
    this.color,
    this.secondaryColor,
    this.backgroundColor,
    this.labels,
    this.text,
    this.textStyle,
    this.displacement = 40,
    this.edgeOffset = 0,
    this.triggerMode = FxRefreshTriggerMode.onEdge,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.onStatusChange,
    this.semanticsLabel,
    this.semanticsValue,
    this.enableFeedback = true,
  });

  /// Called when the user pulls far enough and lets go. The indicator keeps
  /// refreshing until the returned future completes.
  final Future<void> Function() onRefresh;

  /// The scrollable to refresh.
  final Widget child;

  /// The look. Defaults to [FxRefreshTheme.style], then [FxRefreshStyle.ring].
  final FxRefreshStyle? style;

  /// The accent: the arc, drop, dots, line or capsule badge, and the fill
  /// when done. Defaults to [FxRefreshTheme.color], then the surrounding text
  /// color.
  final Color? color;

  /// The accent's gradient partner: the tail of arcs and comets and the far
  /// end of gradient fills. Defaults to [FxRefreshTheme.secondaryColor], then
  /// [color] turned a step around the color wheel (a lighter or darker shade
  /// for grays). Pass [color] itself for a single flat color.
  final Color? secondaryColor;

  /// The surface behind the ring, capsule and dots. A translucent color
  /// frosts the content behind it. Defaults to
  /// [FxRefreshTheme.backgroundColor], then a frosted white, or a frosted
  /// dark gray when the surrounding text is light.
  final Color? backgroundColor;

  /// The texts of [FxRefreshStyle.capsule]. Defaults to
  /// [FxRefreshTheme.labels], then English.
  final FxRefreshLabels? labels;

  /// The word that the text styles ([FxRefreshStyle.textFill] to
  /// [FxRefreshStyle.textTypewriter]) draw, such as your app's name.
  /// Defaults to [FxRefreshTheme.text], then 'Refresh'. Keep it short: one
  /// line that fits the width, cut off with an ellipsis if it does not.
  final String? text;

  /// The look of [text], merged over a bold 22-point default in the
  /// surrounding font, for example to use your brand font. Its color is not
  /// used: the styles paint the word in the accent. A font size that would
  /// make the word taller than 38 logical pixels is shrunk to that height.
  /// Defaults to [FxRefreshTheme.textStyle].
  final TextStyle? textStyle;

  /// How far below the top edge the indicator rests while refreshing, in
  /// logical pixels.
  final double displacement;

  /// How far below the top of this widget the top edge is, for example the
  /// height of a translucent app bar drawn over the list.
  final double edgeOffset;

  /// Which drags can start a refresh.
  final FxRefreshTriggerMode triggerMode;

  /// Which scroll notifications to react to. The default takes only those of
  /// the nearest scrollable (depth 0).
  final ScrollNotificationPredicate notificationPredicate;

  /// Called whenever the [FxRefreshStatus] changes, and with null once the
  /// indicator is gone.
  final ValueChanged<FxRefreshStatus?>? onStatusChange;

  /// The indicator's semantics label. Defaults to 'Refresh'.
  final String? semanticsLabel;

  /// The indicator's semantics value, if any.
  final String? semanticsValue;

  /// Whether reaching the trigger point plays a light haptic tick.
  final bool enableFeedback;

  @override
  State<FxRefreshIndicator> createState() => FxRefreshIndicatorState();
}

/// The state of an [FxRefreshIndicator]. Reach it through a
/// `GlobalKey<FxRefreshIndicatorState>` to refresh from code with [show].
class FxRefreshIndicatorState extends State<FxRefreshIndicator>
    with TickerProviderStateMixin, FxMotionAware {
  /// The pull, from 0 to 1 (1 = [_kDragSizeFactorLimit] × displacement).
  late final AnimationController _position = AnimationController(vsync: this);

  /// Repeats while refreshing.
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: _kSpinPeriod,
  );

  /// Runs once over the finish animation.
  late final AnimationController _exit = AnimationController(vsync: this);

  late final Animation<double> _pull = _position.drive(
    Tween<double>(begin: 0, end: _kDragSizeFactorLimit),
  );

  FxRefreshStatus? _status;
  Future<void> _pendingRefreshFuture = Future<void>.value();
  bool? _isIndicatorAtTop;
  double? _dragOffset;
  FxRefreshStyle _style = FxRefreshStyle.ring;

  @override
  void dispose() {
    _position.dispose();
    _spin.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  void onReduceMotionChanged(bool reduceMotion) {
    if (reduceMotion) {
      _spin.stop();
    } else if (_status == FxRefreshStatus.refresh) {
      _spin.repeat();
    }
  }

  void _setStatus(FxRefreshStatus? status) {
    _status = status;
    widget.onStatusChange?.call(status);
  }

  bool _shouldStart(ScrollNotification notification) {
    // Only a drag starts the indicator, never a jumpTo or a fling.
    return ((notification is ScrollStartNotification &&
                notification.dragDetails != null) ||
            (notification is ScrollUpdateNotification &&
                notification.dragDetails != null &&
                widget.triggerMode == FxRefreshTriggerMode.anywhere)) &&
        ((notification.metrics.axisDirection == AxisDirection.up &&
                notification.metrics.extentAfter == 0.0) ||
            (notification.metrics.axisDirection == AxisDirection.down &&
                notification.metrics.extentBefore == 0.0)) &&
        _status == null &&
        _start(notification.metrics.axisDirection);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) return false;
    if (_shouldStart(notification)) {
      setState(() => _setStatus(FxRefreshStatus.drag));
      return false;
    }
    final indicatorAtTopNow = switch (notification.metrics.axisDirection) {
      AxisDirection.down || AxisDirection.up => true,
      AxisDirection.left || AxisDirection.right => null,
    };
    final dragging =
        _status == FxRefreshStatus.drag || _status == FxRefreshStatus.armed;
    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (dragging) _dismiss(FxRefreshStatus.canceled);
    } else if (notification is ScrollUpdateNotification) {
      if (dragging) {
        _drag(notification.metrics, notification.scrollDelta!);
      }
      // A bouncing scrollable springs back after release, without drag
      // details: that is the release.
      if (_status == FxRefreshStatus.armed &&
          notification.dragDetails == null) {
        _show();
      }
    } else if (notification is OverscrollNotification) {
      if (dragging) _drag(notification.metrics, notification.overscroll);
    } else if (notification is ScrollEndNotification) {
      switch (_status) {
        case FxRefreshStatus.armed:
          // Armed means ready: the indicator has said so, so a release
          // anywhere past the trigger point refreshes.
          _show();
        case FxRefreshStatus.drag:
          _dismiss(FxRefreshStatus.canceled);
        case FxRefreshStatus.snap ||
            FxRefreshStatus.refresh ||
            FxRefreshStatus.done ||
            FxRefreshStatus.canceled ||
            null:
          break;
      }
    }
    return false;
  }

  void _drag(ScrollMetrics metrics, double delta) {
    if (metrics.axisDirection == AxisDirection.down) {
      _dragOffset = _dragOffset! - delta;
    } else if (metrics.axisDirection == AxisDirection.up) {
      _dragOffset = _dragOffset! + delta;
    }
    _checkDragOffset(metrics.viewportDimension);
  }

  bool _handleIndicatorNotification(
    OverscrollIndicatorNotification notification,
  ) {
    if (notification.depth != 0 || !notification.leading) return false;
    if (_status == FxRefreshStatus.drag) {
      // No overscroll glow under the indicator.
      notification.disallowIndicator();
      return true;
    }
    return false;
  }

  bool _start(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.down || AxisDirection.up:
        _isIndicatorAtTop = true;
      case AxisDirection.left || AxisDirection.right:
        // Horizontal scrollables are not supported.
        _isIndicatorAtTop = null;
        return false;
    }
    _dragOffset = 0;
    _exit.value = 0;
    _position.value = 0;
    return true;
  }

  void _checkDragOffset(double containerExtent) {
    var newValue =
        _dragOffset! / (containerExtent * _kDragContainerExtentPercentage);
    if (_status == FxRefreshStatus.armed) {
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    }
    _position.value = newValue.clamp(0.0, 1.0);
    if (_status == FxRefreshStatus.drag &&
        _position.value >= 1.0 / _kDragSizeFactorLimit) {
      if (widget.enableFeedback) HapticFeedback.lightImpact();
      setState(() => _setStatus(FxRefreshStatus.armed));
    }
  }

  /// Hides the indicator after a refresh ([FxRefreshStatus.done]) or an
  /// unarmed release ([FxRefreshStatus.canceled]).
  Future<void> _dismiss(FxRefreshStatus newStatus) async {
    await Future<void>.value();
    if (!mounted) return;
    setState(() => _setStatus(newStatus));
    _spin.stop();
    final quick = reduceMotion;
    switch (newStatus) {
      case FxRefreshStatus.done:
        await _exit.animateTo(
          1,
          duration: quick ? Duration.zero : fxRefreshExitDuration(_style),
        );
      case FxRefreshStatus.canceled:
        await _position.animateTo(
          0,
          duration: quick ? Duration.zero : _kCancelDuration,
          curve: Curves.easeOutCubic,
        );
      case FxRefreshStatus.drag ||
          FxRefreshStatus.armed ||
          FxRefreshStatus.snap ||
          FxRefreshStatus.refresh:
        assert(false, 'Only done and canceled dismiss the indicator.');
    }
    if (mounted && _status == newStatus) {
      _dragOffset = null;
      _isIndicatorAtTop = null;
      setState(() => _setStatus(null));
    }
  }

  void _show() {
    final completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    setState(() => _setStatus(FxRefreshStatus.snap));
    _position
        .animateTo(
          1.0 / _kDragSizeFactorLimit,
          duration: reduceMotion ? Duration.zero : _kSnapDuration,
          curve: Curves.easeOutCubic,
        )
        .then<void>((_) {
          if (!mounted || _status != FxRefreshStatus.snap) return;
          setState(() => _setStatus(FxRefreshStatus.refresh));
          if (!reduceMotion) _spin.repeat();
          widget.onRefresh().whenComplete(() {
            if (mounted && _status == FxRefreshStatus.refresh) {
              completer.complete();
              _dismiss(FxRefreshStatus.done);
            }
          });
        });
  }

  /// Shows the indicator and runs [FxRefreshIndicator.onRefresh] as if the
  /// user had pulled. Does nothing new while a refresh is already running.
  ///
  /// The returned future completes when `onRefresh`'s future completes. If you
  /// await it in a [State], check [mounted] before calling [setState].
  Future<void> show({bool atTop = true}) {
    if (_status != FxRefreshStatus.refresh && _status != FxRefreshStatus.snap) {
      if (_status == null) {
        _start(atTop ? AxisDirection.down : AxisDirection.up);
      }
      _show();
    }
    return _pendingRefreshFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FxRefreshTheme.maybeOf(context);
    _style = widget.style ?? theme?.style ?? FxRefreshStyle.ring;

    final child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleIndicatorNotification,
        child: widget.child,
      ),
    );
    final status = _status;
    return Stack(
      children: [
        child,
        if (status != null)
          Positioned(
            top: widget.edgeOffset,
            left: 0,
            right: 0,
            height: fxRefreshAreaHeight(_style, widget.displacement),
            child: IgnorePointer(
              child: ClipRect(
                child: RepaintBoundary(
                  child: Semantics(
                    container: true,
                    label: widget.semanticsLabel ?? 'Refresh',
                    value: widget.semanticsValue,
                    child: fxRefreshIndicatorFor(
                      _style,
                      _frame(context, status, theme),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  FxRefreshFrame _frame(
    BuildContext context,
    FxRefreshStatus status,
    FxRefreshTheme? theme,
  ) {
    // The surrounding text color is the theme's on-surface color in Material
    // and Cupertino apps, so it tells light from dark without depending on
    // either library.
    final ambient = DefaultTextStyle.of(context).style.color;
    final dark = ambient != null
        ? ambient.computeLuminance() > 0.5
        : MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
    final foreground =
        ambient ?? (dark ? const Color(0xFFF2F2F5) : const Color(0xFF1C1C1F));
    final accent = widget.color ?? theme?.color ?? foreground;
    return FxRefreshFrame(
      status: status,
      pull: _pull,
      spin: _spin,
      exit: _exit,
      color: accent,
      secondary:
          widget.secondaryColor ?? theme?.secondaryColor ?? _partner(accent),
      onAccent: _onColor(accent),
      background:
          widget.backgroundColor ??
          theme?.backgroundColor ??
          (dark ? const Color(0xE62C2C33) : const Color(0xEBFFFFFF)),
      foreground: foreground,
      dark: dark,
      rtl: Directionality.maybeOf(context) == TextDirection.rtl,
      displacement: widget.displacement,
      labels: widget.labels ?? theme?.labels ?? const FxRefreshLabels(),
      text: widget.text ?? theme?.text ?? 'Refresh',
      textStyle: widget.textStyle ?? theme?.textStyle,
      reduceMotion: reduceMotion,
    );
  }

  /// Whichever of white and near-black contrasts more with [accent].
  static Color _onColor(Color accent) {
    const light = Color(0xFFFFFFFF);
    const dark = Color(0xFF15161A);
    final l = accent.computeLuminance() + 0.05;
    final onLight = 1.05 / l;
    final onDark = l / (dark.computeLuminance() + 0.05);
    return onLight >= onDark ? light : dark;
  }

  /// A gradient partner for [accent]: a step around the color wheel, or a
  /// lighter or darker shade of a gray.
  static Color _partner(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    if (hsl.saturation < 0.15) {
      final l = hsl.lightness;
      return hsl.withLightness(l > 0.5 ? l - 0.2 : l + 0.22).toColor();
    }
    return hsl.withHue((hsl.hue + 32) % 360).toColor();
  }
}
