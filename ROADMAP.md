# Roadmap

The original brief (`prompt.md`) describes what is realistically 5+ packages of
scope. Following the engineering plan in `prompt.enhanced.md`, the work is phased
so each milestone ships something correct and complete rather than a broad set of
half-working features.

## ✅ v0.1 — Core (shipped)

The animation engine and the developer-facing surface:

- `Widget.animate()` → immutable, chainable `FxBuilder` (itself a `Widget`).
- Single `AnimationController` per builder; transform effects collapse into one
  `Matrix4`/`Transform`, fades into one `Opacity`, wrapped in `RepaintBoundary`.
- **Full effect catalog**: fade, move, slide, scale, rotate, skew, flip, blur,
  tint, shake, bounce, pulse, and the Animate.css-style attention seekers
  (flash, wobble, swing, heartbeat, jelly, rubberBand, tada, float, glow).
- Entrance one-shots (fadeIn, scaleIn/Out, zoom, elastic, slideFrom*) and 20
  composed **presets** (success, error, loading, dialog, toast, fab, …).
- Timeline: parallel-by-default, `then()`, `parallel()`, per-effect timing.
- `FxController`, `FxTheme` (with defaults cascade), `FxCurves`, duration
  extensions, staggered lists, custom `FxEffect`s.
- Reduced-motion support; unit + widget tests; example app.

## ✅ v0.2 — Interaction (shipped)

- Triggers: `onTap`, `onDoubleTap`, `onLongPress`, `onHover`, `onAppear`,
  `onVisible` / `animateOnVisible`.
- Gesture animations: `pressScale`, `pressBounce`, `hoverScale`.
- Presets (shipped early in v0.1 — see above).

### Still open in this line
- `onFocus`, `onDisappear` triggers.
- `dragScale`, `swipeRotate` (pan-tracking gestures — semantics are
  app-specific; deferred until a clean, general API is settled).

## ⏳ v0.3 — Advanced

- Physics: `spring`, `friction`, `gravity`, `inertia` built on Flutter's
  `physics.dart` simulations (not a hand-rolled solver).
- Page transitions (Fade / SharedAxis / Scale / Zoom / Slide / Material /
  Cupertino) and Hero enhancements.
- Debug HUD: `showTimeline`, `showBounds`, `showFPS`, gated behind `kDebugMode`.
- `benchmarks/` frame-budget harness + an Impeller driver test.

## Testing philosophy

- Engine/timeline/theming resolution: aim for ~100% coverage (the risky core).
- Golden tests: pump the controller to deterministic `t` values and golden the
  widget — never golden a mid-flight frame (flaky).
- Performance is validated by a benchmark harness, not asserted as a claim.
