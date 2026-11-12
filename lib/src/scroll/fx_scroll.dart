import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';

/// Drives a list of [FxEffect]s from the child's **scroll position** in the
/// nearest [Scrollable], instead of from time.
///
/// Progress runs `0 → 1` as the widget scrolls up from the bottom of the
/// viewport until it reaches [revealFraction] of the way up (default 60%),
/// then holds at 1. Effects animate from their begin toward their end state as
/// the item comes into view.
///
/// ```dart
/// FxScrollLinked(
///   effects: const [FadeEffect(), SlideEffect(beginY: 0.15)],
///   child: myCard,
/// );
/// ```
class FxScrollLinked extends StatefulWidget {
  const FxScrollLinked({
    super.key,
    required this.effects,
    required this.child,
    this.revealFraction = 0.6,
    this.curve = Curves.easeOut,
  });

  final List<FxEffect> effects;
  final Widget child;

  /// Fraction of the viewport height over which the effects complete.
  final double revealFraction;
  final Curve curve;

  @override
  State<FxScrollLinked> createState() => _FxScrollLinkedState();
}

class _FxScrollLinkedState extends State<FxScrollLinked> {
  ScrollPosition? _position;
  double _progress = 0;

  /// Keeps the child's `State` alive as no-op wrappers appear and disappear
  /// with scroll progress (see `_FxRunnerState._childKey`).
  final GlobalKey _childKey = GlobalKey(debugLabel: 'FxScrollLinked.child');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newPosition = Scrollable.maybeOf(context)?.position;
    if (newPosition != _position) {
      _position?.removeListener(_onScroll);
      _position = newPosition?..addListener(_onScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    }
  }

  void _onScroll() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    final viewport =
        _position?.context.storageContext.findRenderObject() as RenderBox?;
    if (box == null || viewport == null || !box.hasSize || !viewport.hasSize) {
      return;
    }
    final itemTop = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    final vpHeight = viewport.size.height;
    final travel = vpHeight * widget.revealFraction;
    final raw = travel <= 0 ? 1.0 : (vpHeight - itemTop) / travel;
    final next = raw.clamp(0.0, 1.0);
    if (next != _progress) setState(() => _progress = next);
  }

  @override
  void dispose() {
    _position?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.curve.transform(_progress);
    final acc = FxAccumulator();
    for (final effect in widget.effects) {
      effect.apply(acc, (effect.curve ?? Curves.linear).transform(t));
    }
    return fxComposeFrame(
      KeyedSubtree(key: _childKey, child: widget.child),
      acc,
    );
  }
}

/// Translates a widget as the user scrolls, creating a depth/parallax effect.
///
/// Positive [amount] moves the child opposite to scroll (classic background
/// parallax); the child is offset proportionally to how far it is from the
/// viewport center.
class FxParallax extends StatefulWidget {
  const FxParallax({
    super.key,
    required this.child,
    this.amount = 40,
    this.axis = Axis.vertical,
  });

  final Widget child;

  /// Peak translation in logical pixels at the viewport edges.
  final double amount;
  final Axis axis;

  @override
  State<FxParallax> createState() => _FxParallaxState();
}

class _FxParallaxState extends State<FxParallax> {
  ScrollPosition? _position;
  // -1 (top) .. 0 (center) .. 1 (bottom)
  final ValueNotifier<double> _normalized = ValueNotifier<double>(0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newPosition = Scrollable.maybeOf(context)?.position;
    if (newPosition != _position) {
      _position?.removeListener(_onScroll);
      _position = newPosition?..addListener(_onScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    }
  }

  void _onScroll() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    final viewport =
        _position?.context.storageContext.findRenderObject() as RenderBox?;
    if (box == null || viewport == null || !box.hasSize || !viewport.hasSize) {
      return;
    }
    final vpSize = widget.axis == .vertical
        ? viewport.size.height
        : viewport.size.width;
    final offset = box.localToGlobal(Offset.zero, ancestor: viewport);
    final itemPos = widget.axis == .vertical ? offset.dy : offset.dx;
    final itemExtent = widget.axis == .vertical
        ? box.size.height
        : box.size.width;
    final itemCenter = itemPos + itemExtent / 2;
    final next = ((itemCenter / vpSize) * 2 - 1).clamp(-1.0, 1.0);
    // Updating the notifier rebuilds only the Transform via
    // ValueListenableBuilder, leaving the child subtree untouched per frame.
    _normalized.value = next;
  }

  @override
  void dispose() {
    _position?.removeListener(_onScroll);
    _normalized.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _normalized,
      child: widget.child,
      builder: (context, normalized, child) {
        final shift = normalized * widget.amount;
        final offset = widget.axis == Axis.vertical
            ? Offset(0, shift)
            : Offset(shift, 0);
        return Transform.translate(offset: offset, child: child);
      },
    );
  }
}

/// Scroll-driven sugar.
extension FxScrollExtension on Widget {
  /// Animate [effects] as this widget scrolls into view.
  Widget animateOnScroll(
    List<FxEffect> effects, {
    double revealFraction = 0.6,
    Curve curve = Curves.easeOut,
  }) => FxScrollLinked(
    effects: effects,
    revealFraction: revealFraction,
    curve: curve,
    child: this,
  );

  /// Add a scroll parallax translation.
  Widget parallax({double amount = 40, Axis axis = Axis.vertical}) =>
      FxParallax(amount: amount, axis: axis, child: this);
}
