## 0.1.0

Initial release — the v0.1 **core** milestone with the full animation catalog.

### Added
- `Widget.animate()` entry point returning a chainable, immutable `FxBuilder`
  that is itself a `Widget`.
- Single-`AnimationController` engine that collapses transform effects into one
  `Transform` and fades into one `Opacity`, wrapped in a `RepaintBoundary`.
- Transform/visual effects: `fade`, `fadeOut`, `moveX/Y/move`, `slideX/Y`,
  `scale`, `rotate`, `skew`, `flipX/Y`, `blur`, `tint`.
- Attention seekers: `shake`, `bounce`, `pulse`, `flash`, `wobble`, `swing`,
  `heartbeat`, `jelly`, `rubberBand`, `tada`, `float`, `glow` (keyframe-accurate,
  Animate.css-inspired).
- Entrance one-shots: `fadeIn`, `scaleIn/Out`, `zoom`, `elastic`,
  `slideFrom{Top,Bottom,Left,Right}`.
- 20 composed presets: `success`, `error`, `warning`, `loading`, `attention`,
  `heroEntry/Exit`, `dialog`, `tooltip`, `toast`, `snackbar`, `cardEntry`,
  `listItem`, `pageTransition`, `modal`, `popup`, `emptyState`, `onboarding`,
  `fab`, `notification`.
- Triggers: `onTap`, `onDoubleTap`, `onLongPress`, `onHover`, `onAppear`,
  `onVisible` / `animateOnVisible` — replay any chain on an event.
- Gesture animations: `pressScale`, `pressBounce`, `hoverScale` — continuous,
  pointer-state-driven feedback.
- Physics: `spring` (real `SpringSimulation` with auto settle duration),
  `gravity`, `friction`/inertia — exposed as fluent modifiers and as
  `FxPhysics` / `FxSpringCurve` for use anywhere a `Curve` is accepted.
- Page transitions: `FxPageRoute` + `context.fxPush` with `fade`, `scale`,
  `zoom`, `slide`, `rotation`, `sharedAxisHorizontal/Vertical`.
- Hero: `heroAnimate(tag)` with an optional curved-arc flight path
  (`FxArcRectTween`).
- Debug tools (debug-build only, zero release overhead): `showFPS`,
  `showBounds`, `showTimeline`, `showControllers`, `showPerformance`, backed by
  a live `FxDebugRegistry` controller count.
- Benchmark harness: a CI-runnable smoke benchmark (`test/benchmark/`) plus an
  on-device / Impeller integration test (`example/integration_test/`) — see
  `benchmark/README.md`.
- Timeline operators: parallel-by-default, `then()` sequencing, `parallel()`,
  and per-effect `duration()/delay()/curve()`.
- `FxController` facade (`play/pause/resume/restart/reverse/stop/repeat/seek/
  reset`) with a safe no-op `dispose`.
- `FxTheme` global defaults with an explicit resolution cascade
  (argument → theme → package default).
- **Reduced-motion support** honoring `MediaQuery.disableAnimations`.
- `FxCurves` named curve library and `num` duration extensions (`.ms`,
  `.seconds`, `.minutes`).
- Staggered list animations via `List<Widget>.animateList()`.
- Custom effects by extending `FxEffect`.
- Unit and widget test suite; runnable example app.

See `ROADMAP.md` for planned v0.2 (triggers, gestures, presets) and v0.3
(physics/springs, page transitions, hero, debug HUD) milestones.
