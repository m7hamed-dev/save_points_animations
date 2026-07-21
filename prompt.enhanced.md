# Flutter FX — Professional Animation Extensions Package (Engineering Brief)

> This is the engineering-grade rewrite of `prompt.md`. Where the original described
> *what the API looks like*, this brief also locks down *how it works*, defines the
> semantics behind each operator, and phases the scope into shippable milestones.

## Role

Act as a **Senior Flutter Framework Engineer** (10+ years: Flutter SDK, Dart, the
rendering pipeline, implicit/explicit animations, package architecture, API/DX design,
performance, and open-source maintenance).

Design and implement a **production-ready Flutter package** — `flutter_fx` — that animates
any widget through **extension methods** and a **fluent, immutable builder API**, suitable
for publishing on **pub.dev** and following Flutter/Dart best practices.

---

# 0. Non-negotiable architectural decisions (decide these FIRST)

Everything else depends on these. They are specified, not left to the implementer.

### 0.1 What `.animate()` returns and how rebuilds are driven
- `Widget.animate()` returns an **`FxBuilder`**, which **is itself a `Widget`**, so the
  terminal of any chain is directly insertable into the tree.
- Chaining (`.fade()`, `.moveY()`, …) **accumulates immutable `FxEffect` objects into a
  list**. Nothing animates during chaining; the animation is constructed in `build`.
- `FxBuilder` is a **`StatefulWidget`** whose `State` uses **`TickerProviderStateMixin`**
  and owns **exactly one `AnimationController`** — **not one controller per effect.**
- Each effect is mapped onto a **sub-interval `[begin, end]` of the controller's `0.0..1.0`
  timeline** (via `Interval`/`CurveTween`), à la `flutter_animate`. The controller's total
  `duration` is the **max end time** across all effects (see §3 for the timing model).

### 0.2 Render-object collapsing (the performance contract)
Naïvely wrapping one widget per effect is the classic jank source. Instead:
- **Fold all transform-type effects** (move, scale, rotate, skew, flip) into a **single
  `Transform` with one composed `Matrix4`.**
- **Fold opacity/fade** into a single `Opacity`/`FadeTransition`.
- Only add extra render objects when the effect genuinely needs one (blur → `ImageFiltered`,
  color → `ColorFiltered`, clip, etc.).
- Wrap the animated subtree in a **`RepaintBoundary`** by default (opt-out via config).
- Rebuild via **one `AnimatedBuilder`/`ListenableBuilder`** over the shared controller.

### 0.3 One-shots are sugar, not a second codepath
`Text("x").fadeIn()` is **defined as** `x.animate().fade(...preset defaults...)`. There is
**one** engine. One-shot extensions only supply preset arguments — they never fork logic.

### 0.4 Accessibility / reduced motion (hard requirement)
- Respect `MediaQuery.maybeOf(context)?.disableAnimations` and `accessibleNavigation`.
- Global override: `FxTheme(respectReducedMotion: true)` (default **true**).
- When reduced motion is active: **jump to the end state** (final frame) instead of
  animating. Provide `FxTheme(reducedMotionBehavior: jumpToEnd | disable | play)`.

### 0.5 The custom-effect contract (what "extensible" actually means)
`FxEffect` is an abstract, immutable class with a defined interface:

```dart
abstract class FxEffect {
  const FxEffect({this.delay, this.duration, this.curve});

  final Duration? delay;
  final Duration? duration;
  final Curve? curve;

  /// Contribute this effect's visual result for animation value t in 0..1.
  /// Transform-type effects return a matrix contribution (composed by the engine
  /// into a single Transform); wrapping effects return a wrapped child.
  FxEffectResult build(BuildContext context, Widget child, double t);

  /// A copy with resolved timing (used by the theming cascade, §4).
  FxEffect resolve(FxResolvedDefaults defaults);
}
```

Custom effects (`class SwingEffect extends FxEffect { ... }`) plug in with **no package
modification** and participate in collapsing, timing, and theming like built-ins.

### 0.6 Interop & lifecycle
- Correct behavior under `didUpdateWidget` (parent rebuilds, changed args, changed key).
- `mounted` guards around async callbacks; **dispose every controller/ticker.**
- Coexist with `Hero`, `Navigator`, `AnimatedSwitcher`; document known interactions.
- Assertions on invalid input (`assert(scaleBegin >= 0)`, non-negative durations, etc.).

---

# Main Objective

Animate any widget with an expressive API:

```dart
Text("Hello")
    .animate()
    .fade()
    .moveY(50)
    .scale()
    .rotate(15)
    .duration(600.ms)
    .delay(200.ms)
    .curve(Curves.easeOutBack);
```

or the one-shot sugar (§0.3):

```dart
Container().fadeIn().slideFromBottom().scaleIn();
```

---

# Design Philosophy

Clean API · minimal boilerplate · readable syntax · high performance · extensibility ·
composition over inheritance · immutable configuration · type & null safety ·
Flutter best practices · production-ready architecture. Every animation is chainable and
feels native to Flutter developers.

---

# 1. Architecture

```
lib/
  flutter_fx.dart                 // public barrel; export only the intended surface
  src/
    core/          // config, defaults, FxResolvedDefaults, constants
    engine/        // controller lifecycle, ticker mgmt, timeline scheduling, collapsing
    builders/      // FxBuilder (StatefulWidget) + fluent chain
    controllers/   // FxController (public play/pause/… facade)
    extensions/    // Widget/List/num extensions
    effects/       // FxEffect + built-ins
    transitions/   // page transitions
    presets/       // named professional animations (sugar over effects)
    widgets/       // FxTheme (InheritedWidget), helpers
    physics/       // spring/friction via Flutter's physics.dart
    debug/         // dev HUD/overlays
    timeline/      // then/parallel/interval semantics
    enums/  mixins/  painters/  utilities/
example/           // runnable app
test/              // unit / widget / golden / perf
```

---

# 2. Effects

Each animation is an independent, immutable `FxEffect` (see §0.5). v0.1 built-ins:

`FadeEffect · OpacityEffect · ScaleEffect · RotateEffect · MoveEffect · SlideEffect ·
BlurEffect · ColorEffect · SkewEffect · FlipEffect · ShakeEffect · BounceEffect`

**Canonical home for each name (resolves the original's collisions):**
- `rotate` → a **`RotateEffect`**; the `.rotate()` extension is sugar for it.
- `bounce` → a **physics** behavior; the `.bounce()` effect is the keyframe variant —
  name them distinctly: `BounceEffect` (keyframe) vs `spring(...)`/`bounce: true` (physics).
- `attention` → **preset only** (composes shake+pulse); not a bare effect.

---

# 3. Timeline semantics (defined, not just shown)

Let each effect *e* have resolved `delay(e)`, `duration(e)`, `curve(e)`.

- **Baseline (no operators):** all effects share `[0, duration]`; total = `max(delay+duration)`.
- **`.then({Duration delay = Duration.zero})`:** the next effect's `begin` = previous
  effect's `end + delay`. Purely sequential composition; total grows accordingly.
- **`.parallel(e1, e2, …)`:** children share the same `begin`; block duration =
  `max(child durations)`.
- **`.interval(step)`:** for staggered lists, item *i* starts at `i * step`.
- The controller `duration` = the **maximum `end`** over the fully-resolved timeline.

Reduced motion (§0.4) collapses the whole timeline to its final frame.

---

# 4. Defaults & theming cascade

Resolution order for any parameter (duration/curve/delay/…):

**explicit call argument → nearest `FxTheme` (InheritedWidget) → package default.**

Package defaults: `duration = 300.ms`, `curve = Curves.easeInOut`, `delay = Duration.zero`,
`respectReducedMotion = true`.

```dart
FxTheme(
  duration: 300.ms,
  curve: Curves.easeOut,
  delay: Duration.zero,
  respectReducedMotion: true,
  child: MaterialApp(...),
);
```

---

# 5. Extension methods (surface)

One-shots (sugar over §0.3): `fadeIn fadeOut scaleIn scaleOut slideFromBottom slideFromTop
slideFromLeft slideFromRight rotate flipX flipY shake bounce pulse elastic zoom blur glow
float wobble swing flash heartbeat jelly rubberBand tada attention`.

`List<Widget>.animateList()` for staggered lists; `num.ms/.seconds/.minutes` for durations.

---

# 6. Controller

`FxController` is the public facade over the internal `AnimationController`:

`play pause resume restart reverse stop repeat seek reset dispose` — each with defined
behavior and `mounted`/disposed guards.

---

# 7. Physics

Lean on Flutter's **`physics.dart`** (`SpringSimulation`, `FrictionSimulation`), do **not**
hand-roll a solver.

```dart
.spring(stiffness: 300, damping: 15, mass: 1)
```

Cover spring · friction · gravity · velocity/inertia via existing simulations.

---

# 8. Triggers / gestures / visibility (v0.2)

`onTap onDoubleTap onLongPress onHover onFocus onVisible onScroll onAppear onDisappear
onStateChanged`; gesture sugar `pressScale hoverScale pressBounce dragScale swipeRotate`;
`animateOnVisible` (viewport detection). Each must clean up its listeners on dispose.

---

# 9. Presets (v0.2) & Page transitions / Hero (v0.3)

Presets are composed sugar: `success error warning loading attention heroEntry heroExit
dialog tooltip toast snackbar cardEntry listItem pageTransition modal popup emptyState
onboarding fab notification`.

Page transitions: `Fade · SharedAxis · Scale · Cupertino · Material · Zoom · Slide`.
Hero: `.heroAnimate()` (document interaction with the native `Hero` widget, §0.6).

---

# 10. Curves & debug

`FxCurves`: `soft snappy spring smooth bounce elastic fastOut flutter material`.

Debug HUD (v0.3): `showTimeline showBounds showFPS showControllers showPerformance` —
overlay widgets gated behind `kDebugMode`.

---

# 11. Performance — reframed as verifiable properties

Not "the package does 120 FPS" but:
- **Adds zero jank** on a 60/120 Hz device **in profile mode** — proven by a benchmark
  harness in `benchmarks/` (frame-time budget assertions).
- **Renders correctly under Impeller** — a driver/integration test, not a claim.
- Minimal render objects (§0.2), `RepaintBoundary` by default, no rebuilds outside the
  animated subtree, **no leaked controllers/tickers** (verified in widget tests).
- Works on Web, Desktop, Mobile; Material 3 and Cupertino friendly.

---

# 12. Testing — realistic targets

- **Unit:** engine, timeline math (`then`/`parallel`/`interval`), theming cascade,
  reduced-motion → **~100% here** (it's the risky core).
- **Widget:** dispose/leak checks, `didUpdateWidget`, controller facade behavior.
- **Golden:** pump the controller to **deterministic `t` values** and golden the widget —
  never golden a mid-flight frame (flaky). Document this convention.
- **Perf/integration:** the `benchmarks/` harness + an Impeller driver test.
- Overall: pragmatic coverage; **do not** block release on a blanket 95% line target —
  prioritize the engine.

---

# 13. Scope & phased roadmap (so v0.1 actually ships)

This brief spans what is normally 5+ packages. Ship in milestones:

- **v0.1 — Core:** `FxBuilder`, ~10 effects, one-shot sugar, timeline
  (`then`/`parallel`/`interval`), `num` duration ext, `FxCurves`, `FxTheme`,
  `FxController`, list stagger, reduced motion, unit+widget+golden tests, example app.
- **v0.2 — Interaction:** triggers, gestures, `animateOnVisible`, presets.
- **v0.3 — Advanced:** physics/springs, page transitions, Hero, debug HUD, benchmarks,
  Impeller driver test.

---

# 14. Code standards

Effective Dart · flutter_lints · SOLID · composition over inheritance · immutable
effect/config models · null safety · `const` **where it genuinely applies** (effect value
objects — **not** the stateful builder or controllers; say so) · type-safe fluent builder.

---

# 15. Pub.dev readiness

`CHANGELOG.md · LICENSE · README.md · CONTRIBUTING.md · CODE_OF_CONDUCT.md · example/ ·
screenshots/ · benchmarks/ · GitHub Actions CI · semantic versioning`. Optimize pub points
(dartdoc on all public API, example, platform declarations, no analyzer issues).

---

# 16. Documentation

API reference · Getting Started · Installation · Architecture (incl. §0 decisions) ·
Examples · **Custom-effect guide (§0.5)** · **Accessibility guide (§0.4)** · Best Practices ·
Migration Guide · FAQ · Cookbook · Performance Guide.

---

# Inspiration (learn from, don't copy)

flutter_animate · simple_animations · animations · flutter_staggered_animations · rive ·
lottie · motion · Framer Motion · GSAP · SwiftUI · Jetpack Compose Animation.

The result should feel like a **next-generation Flutter animation framework** — fluent,
extensible, performant, delightful — intuitive for beginners and precise for experts.
