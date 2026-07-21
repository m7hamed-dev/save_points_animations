# Save Points Animations

A fluent, extensible animation framework for Flutter. Animate **any** widget with
chainable extension methods backed by a single-controller engine — not a stack of
nested animated widgets.

```dart
Text('Hello')
    .animate()
    .fade()
    .moveY(50)
    .scale(begin: 0.8)
    .rotate(15)
    .duration(600.ms)
    .delay(200.ms)
    .curve(FxCurves.snappy);
```

## Why

- **One controller, one `Transform`, one `Opacity`.** Every transform effect
  (move/scale/rotate/skew/flip) is folded into a single `Matrix4`, and every fade
  into a single opacity multiplier — then wrapped in a `RepaintBoundary`. No
  per-effect widget nesting.
- **Immutable & chainable.** The chain builds a value; nothing animates until the
  widget builds.
- **Accessible by default.** Honors `MediaQuery.disableAnimations` and jumps to
  the end frame under reduced-motion.
- **Extensible.** Create your own effect by extending `FxEffect` — no fork needed.

## Install

```yaml
dependencies:
  save_points_animations: ^0.1.0
```

```dart
import 'package:save_points_animations/save_points_animations.dart';
```

## Usage

### Simple — one line

```dart
Text('Welcome').fadeIn();
Container().fadeIn().slideFromBottom().scaleIn();
```

### Composed — parallel by default

Effects without a `.then()` run together:

```dart
Image.asset('logo.png')
    .animate()
    .fade()
    .moveX(-100)
    .rotate(15)
    .scale(begin: 0.5)
    .duration(800.ms)
    .curve(FxCurves.elastic);
```

### Timelines — sequence with `.then()`

```dart
chip.animate()
    .fade().scale(begin: 0.6)   // run together
    .then(120.ms)               // wait for the above + 120ms
    .rotate(-20)
    .then()
    .shake();
```

> **Timing semantics:** `.duration()`, `.delay()`, and `.curve()` apply to the
> **most recently added effect** (the widely-used `flutter_animate` convention).
> Set them per effect, or use an `FxTheme` for global defaults.

### Imperative control

```dart
final fx = FxController();

card.animate(controller: fx, autoPlay: false).fadeIn().scaleIn();

// elsewhere:
fx.play();
fx.restart();
fx.repeat(reverse: true);
```

The underlying `AnimationController` is owned and disposed by the widget — calling
`fx.dispose()` is a safe no-op, so you can never leak or double-dispose it.

### Staggered lists

```dart
Column(
  children: tiles
      .animateList()
      .fade()
      .slideY(0.2)
      .interval(80.ms)
      .build(),
);
```

### Global theme

```dart
FxTheme(
  duration: 300.ms,
  curve: FxCurves.snappy,
  respectReducedMotion: true,
  child: MaterialApp(...),
);
```

Resolution order for any parameter: **explicit argument → nearest `FxTheme` →
package default.**

### Custom effects

```dart
class SwingEffect extends FxEffect {
  const SwingEffect({super.delay, super.duration, super.curve});

  @override
  void apply(FxAccumulator acc, double t) {
    final angle = math.sin(t * math.pi * 2) * 0.2 * (1 - t);
    acc.transform.multiply(Matrix4.rotationZ(angle));
  }

  @override
  FxEffect copyWithTiming({Duration? delay, Duration? duration, Curve? curve}) =>
      SwingEffect(
        delay: delay ?? this.delay,
        duration: duration ?? this.duration,
        curve: curve ?? this.curve,
      );
}

widget.animate().addEffect(const SwingEffect());
```

## Built-in effects

`fade` · `fadeOut` · `moveX/Y/move` · `slideX/Y` · `scale` · `rotate` · `skew` ·
`flipX/Y` · `blur` · `tint` · `shake` · `bounce` · `pulse`

One-shots: `fadeIn` · `scaleIn/Out` · `slideFrom{Top,Bottom,Left,Right}`

## Roadmap

This is the **v0.1 core**. Planned next:

- **v0.2** — triggers (`onTap/onHover/onVisible`), gesture animations, presets.
- **v0.3** — physics/springs (via `physics.dart`), page transitions, Hero
  enhancements, debug HUD, benchmark harness.

See [`ROADMAP.md`](ROADMAP.md).

## Example

A full demo lives in [`example/`](example/lib/main.dart):

```bash
cd example && flutter run
```

## License

See [LICENSE](LICENSE).
