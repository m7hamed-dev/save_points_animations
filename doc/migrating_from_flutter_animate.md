# Migrating from flutter_animate

`save_points_animations` uses the same chain style as
[`flutter_animate`](https://pub.dev/packages/flutter_animate): call
`.animate()` on a widget, add effects, and sequence them with `.then()`. Most
chains port line by line. This guide covers what differs, then lists the
equivalent of each common call. It was written against flutter_animate 4.x.

## The five differences that matter

### 1. Timing is set fluently, not with named arguments

flutter_animate passes `duration:`, `delay:` and `curve:` to each effect. Here
you call `.duration()`, `.delay()` and `.curve()` after the effect, or set
chain-wide defaults on `.animate()`:

```dart
// flutter_animate
logo.animate().fade(duration: 600.ms, curve: Curves.easeOut).scale(delay: 200.ms);

// save_points_animations
logo.animate()
    .fade().duration(600.ms).curve(Curves.easeOut)
    .scale().delay(200.ms);

// …or, when every effect shares the timing:
logo.animate(duration: 600.ms, curve: Curves.easeOut).fade().scale();
```

Effects you build yourself still take timing in their constructor:
`.addEffect(const FadeEffect(duration: Duration(milliseconds: 600)))`.

### 2. Duration and curve are inherited, delay is not

As in flutter_animate, an effect without its own duration or curve inherits
the last one set earlier in the chain: `.fade().duration(600.ms).scale()` runs
both for 600ms.

Unlike flutter_animate, **delays are not inherited**. In flutter_animate,
`.fade(delay: 300.ms).scale()` delays the scale by 300ms too; here
`.fade().delay(300.ms).scale()` starts the scale immediately. Add `.delay()`
to each effect that needs it, or put the effects after a `.then()`.

`.animate(delay:)` behaves like flutter_animate's: it waits once before the
first play and is not repeated by loops.

### 3. Callbacks take no arguments; loop with `.looping()`

flutter_animate's `onPlay` and `onComplete` receive the `AnimationController`,
and looping is usually written `onPlay: (c) => c.repeat()`. Here the callbacks
are plain `VoidCallback`s, and looping is part of the chain:

```dart
// flutter_animate
dot.animate(onPlay: (controller) => controller.repeat(reverse: true)).fade();

// save_points_animations
dot.animate().fade().looping(mirror: true);
dot.animate().fade().looping(count: 3); // stops, then fires onComplete
```

For imperative control (pause, seek, restart), pass an `FxController`:
`.animate(controller: fx, autoPlay: false)`.

### 4. Units: degrees, uniform scale, pixels vs fractions

| | flutter_animate | save_points_animations |
|---|---|---|
| Rotation | turns: `.rotate(begin: -0.25)` | degrees: `.rotate(-90)` |
| Scale | `Offset`: `.scale(begin: Offset(0.8, 0.8))` or `.scaleXY(begin: 0.8)` | `double`: `.scale(begin: 0.8)` |
| Move (pixels) | `.moveY(begin: 50)` | `.moveY(50)` |
| Slide (fraction of size) | `.slideX(begin: 1)` | `.slideX(1)` |
| Blur | `Offset` sigma: `.blur(begin: Offset(8, 8))` | `double` sigma: `.blur(begin: 8)` |

### 5. Lists build explicitly

```dart
// flutter_animate
Column(children: tiles.animate(interval: 80.ms).fade().slideY(begin: 0.2));

// save_points_animations
Column(children: tiles.animateList().fade().slideY(0.2).interval(80.ms).build());
```

`animateList()` also takes `.duration()`, `.curve()` and `.delay()` for every
item, and keyed children keep their animation when the list is reordered.

## Equivalents

| flutter_animate | save_points_animations |
|---|---|
| `.animate()` | `.animate()` |
| `.animate(delay: d)` | `.animate(delay: d)` |
| `.animate(target: v)` | `.animate(target: v)` |
| `.animate(autoPlay: false, controller: c)` | `.animate(autoPlay: false, controller: fxController)` (an `FxController`, not an `AnimationController`) |
| `.animate(onPlay: …, onComplete: …)` | `.animate(onPlay: …, onComplete: …)` (no controller argument) |
| `Animate.defaultDuration` / `defaultCurve` | `FxTheme(duration: …, curve: …)` around your app (or a subtree) |
| `.then(delay: d)` | `.then(d)` |
| `.fade()` / `.fadeIn()` / `.fadeOut()` | `.fade()` / `.fade()` / `.fadeOut()` (`fadeIn()` here is a fade plus a short upward slide) |
| `.scale()` / `.scaleXY()` | `.scale()` |
| `.move()` / `.moveX()` / `.moveY()` | `.move()` / `.moveX()` / `.moveY()` |
| `.slide()` / `.slideX()` / `.slideY()` | `.slideX()` / `.slideY()` (or `.slideFromStart()` / `.slideFromEnd()` for RTL-aware entrances) |
| `.rotate()` | `.rotate()` (degrees) |
| `.flip()` / `.flipH()` / `.flipV()` | `.flipX()` / `.flipY()` |
| `.blur()` / `.blurXY()` | `.blur()` |
| `.tint()` | `.tint(color)` |
| `.saturate()` | `.saturate()` / `.grayscale()` |
| `.shimmer()` | `.shimmer()` (pair with `.looping()`); `.sheen()` for a sharp specular streak |
| `.shake()` | `.shake(amplitude:, count:)` |
| `.custom(builder: …)` | a class extending `FxEffect`, added with `.addEffect()` (see the README) |
| `.animate(adapter: ScrollAdapter(…))` | `.animateOnScroll(effects)` or `.parallax()` |
| `.callback()` at the end of a chain | `onComplete` (there is no callback at an arbitrary point mid-timeline) |
| `.listen()` | no equivalent; drive the chain with `target:` from your own animation or state instead |
| `.swap()` / `.crossfade()` | `FxSwitcher` |
| `.toggle()` / `.visibility()` | `FxAnimatedVisibility` |
| `num` extensions `300.ms`, `1.seconds` | the same: `300.ms`, `1.seconds` |

## Using both packages during a migration

Both packages add `.animate()` to `Widget` and `.ms` / `.seconds` to `num`, so
a file that imports both must hide one side. Hide the overlapping names on one
of the two imports, for example:

```dart
import 'package:save_points_animations/core.dart'
    hide FxAnimate, FxNumDuration;
```

`core.dart` (the engine without the widget catalog and the one-call shortcuts
such as `.fadeIn()` on every widget) keeps the overlap to those two
extensions. Migrate a file at a time and drop the `hide` when flutter_animate
is gone.

## What you gain

- **Layer-only frames.** Chains that only move, scale, rotate, skew, flip,
  slide or fade rebuild and repaint nothing per frame; they only update an
  opacity and a transform layer.
- **RTL-aware entrances.** `slideFromStart()` / `slideFromEnd()` mirror in
  right-to-left locales; `moveX` / `slideX` take `directional: true`.
- **Reduced motion by default.** Chains jump to their end frame (or are skipped
  entirely with `FxReducedMotionBehavior.disable`) when the OS asks for less
  motion.
- **Visibility triggers.** `.onVisible(once: false, onShown:, onHidden:)` plays
  when a widget scrolls into view, in any scroll view.
- **A widget catalog.** 110+ animated widgets in `widgets.dart`.
