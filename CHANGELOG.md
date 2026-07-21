## 0.1.0

Initial release — the v0.1 **core** milestone.

### Added
- `Widget.animate()` entry point returning a chainable, immutable `FxBuilder`
  that is itself a `Widget`.
- Single-`AnimationController` engine that collapses transform effects into one
  `Transform` and fades into one `Opacity`, wrapped in a `RepaintBoundary`.
- Effects: `fade`, `fadeOut`, `moveX/Y/move`, `slideX/Y`, `scale`, `rotate`,
  `skew`, `flipX/Y`, `blur`, `tint`, `shake`, `bounce`, `pulse`.
- One-shot sugar: `fadeIn`, `scaleIn/Out`, `slideFrom{Top,Bottom,Left,Right}`.
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
