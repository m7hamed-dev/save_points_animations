import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Internal keyboard / focus support shared by the package's interactive
// widgets (buttons, toggles, sliders). Not exported from the package barrel.

/// Enter, numpad Enter and Space activate a focused control.
///
/// Declared on each control rather than left to `WidgetsApp`'s defaults, so
/// activation also works under a bare `Directionality` host and in apps that
/// remap the global shortcuts.
const Map<ShortcutActivator, Intent> fxActivateShortcuts = {
  SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
};

/// Asks a focused slider-like control to step its value up or down.
class FxAdjustIntent extends Intent {
  const FxAdjustIntent.increase() : increase = true;
  const FxAdjustIntent.decrease() : increase = false;

  /// Whether to step the value up (`true`) or down (`false`).
  final bool increase;
}

/// Arrow keys nudge a focused slider: right/up increase, left/down decrease.
///
/// These override the app's arrow-key focus traversal / scrolling only while
/// the slider itself has focus, matching platform sliders.
const Map<ShortcutActivator, Intent> fxAdjustShortcuts = {
  SingleActivator(LogicalKeyboardKey.arrowRight): FxAdjustIntent.increase(),
  SingleActivator(LogicalKeyboardKey.arrowUp): FxAdjustIntent.increase(),
  SingleActivator(LogicalKeyboardKey.arrowLeft): FxAdjustIntent.decrease(),
  SingleActivator(LogicalKeyboardKey.arrowDown): FxAdjustIntent.decrease(),
};

/// Makes a control operable from the keyboard.
///
/// Wraps the control in a [FocusableActionDetector] that is focusable only
/// while [enabled], maps Enter / Space to [onActivate] (when given), merges any
/// extra [shortcuts] / [actions] (e.g. arrow keys for sliders), and reports
/// whether the keyboard focus highlight should show through [builder] — so a
/// control can draw a focus ring for keyboard users only, and looks exactly as
/// before otherwise.
class FxFocusableControl extends StatefulWidget {
  const FxFocusableControl({
    super.key,
    required this.enabled,
    required this.builder,
    this.onActivate,
    this.shortcuts = const <ShortcutActivator, Intent>{},
    this.actions = const <Type, Action<Intent>>{},
    this.onFocusChange,
    this.onKeyEvent,
  });

  /// Whether the control can take focus and respond to keys. Pass `false` for
  /// a disabled control (e.g. a `null` callback).
  final bool enabled;

  /// Invoked by Enter / Space while focused. `null` means the control has no
  /// activation (Enter / Space then fall through to the app).
  final VoidCallback? onActivate;

  /// Extra key bindings, merged over [fxActivateShortcuts].
  final Map<ShortcutActivator, Intent> shortcuts;

  /// Actions for the intents in [shortcuts].
  final Map<Type, Action<Intent>> actions;

  /// Called when the control gains or loses focus.
  final ValueChanged<bool>? onFocusChange;

  /// Raw key handler for controls that need key-up events (e.g. press-and-
  /// hold). Runs before the app-level shortcuts.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Builds the control; `showFocus` is true while it has keyboard focus and
  /// the focus highlight should be drawn.
  final Widget Function(BuildContext context, bool showFocus) builder;

  @override
  State<FxFocusableControl> createState() => _FxFocusableControlState();
}

class _FxFocusableControlState extends State<FxFocusableControl> {
  bool _highlight = false;

  // Created once so the Actions map stays identical across rebuilds.
  late final Action<ActivateIntent> _activate = CallbackAction<ActivateIntent>(
    onInvoke: (_) {
      if (widget.enabled) widget.onActivate?.call();
      return null;
    },
  );

  void _onHighlight(bool value) {
    if (value != _highlight) setState(() => _highlight = value);
  }

  @override
  Widget build(BuildContext context) {
    final activatable = widget.onActivate != null;
    Widget result = FocusableActionDetector(
      enabled: widget.enabled,
      shortcuts: activatable
          ? {...fxActivateShortcuts, ...widget.shortcuts}
          : widget.shortcuts,
      actions: activatable
          ? {ActivateIntent: _activate, ...widget.actions}
          : widget.actions,
      onFocusChange: widget.onFocusChange,
      onShowFocusHighlight: _onHighlight,
      child: widget.builder(context, widget.enabled && _highlight),
    );
    final onKeyEvent = widget.onKeyEvent;
    if (onKeyEvent != null) {
      // An ancestor of the focus node sees its key events (key-up included)
      // before any app-level shortcut does.
      result = Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onKeyEvent: widget.enabled ? onKeyEvent : null,
        child: result,
      );
    }
    return result;
  }
}

/// Paints a keyboard-focus ring just outside [child] when [visible].
///
/// The ring is drawn outside the child's bounds (offset by a small gap), so
/// showing it never changes layout, and nothing at all is painted while it is
/// hidden.
class FxFocusRing extends StatelessWidget {
  const FxFocusRing({
    super.key,
    required this.visible,
    required this.color,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.circle = false,
  });

  final bool visible;
  final Color color;

  /// Corner radius of the child's shape (ignored when [circle]).
  final BorderRadius borderRadius;

  /// Whether the child is circular.
  final bool circle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: visible
          ? _FocusRingPainter(
              color: color,
              borderRadius: borderRadius,
              circle: circle,
            )
          : null,
      child: child,
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({
    required this.color,
    required this.borderRadius,
    required this.circle,
  });

  static const double _width = 2;
  static const double _gap = 2;

  final Color color;
  final BorderRadius borderRadius;
  final bool circle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _width;
    const outset = _gap + _width / 2;
    final rect = Offset.zero & size;
    if (circle) {
      canvas.drawCircle(rect.center, size.shortestSide / 2 + outset, paint);
    } else {
      canvas.drawRRect(borderRadius.toRRect(rect).inflate(outset), paint);
    }
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.circle != circle;
}
