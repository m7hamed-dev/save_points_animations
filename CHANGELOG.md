## 0.24.0

Text & number motion.

### Added
- `FxRotatingWords` — a fade + slide word carousel for hero headlines.
- `FxFlipClock` — split-flap "flip clock" characters that flip in 3D on change.
- `FxColorCycle` — continuously interpolates a palette and hands the current
  color to a builder (cycling text, borders, glows).

## 0.23.0

Gesture-driven actions.

### Added
- `FxSlideToConfirm` — a drag-to-confirm/unlock control with spring-back.
- `FxProgressButton` (+ `FxButtonState`) — a button that morphs to a spinner
  then a success check / error cross.
- `FxSwipeCards` — a Tinder-style swipeable card deck with rotation and the next
  card scaling up.

## 0.22.0

Social & call-to-action widgets.

### Added
- `FxHeartButton` — a "like" heart that pops and emits a burst when toggled on.
- `FxNeonText` — glowing neon-sign text with an irregular flicker.
- `FxShimmerButton` — a gradient CTA button with a continuously sweeping sheen.

## 0.21.0

Progress & control widgets.

### Added
- `FxStepProgress` — an animated horizontal step indicator with filling
  connectors.
- `FxAnimatedToggle` — a custom switch with a sliding thumb and morphing track.
- `FxCircularCountdown` — a depleting ring timer with a center label and
  `onComplete`.

## 0.20.0

Interactive controls & separators.

### Added
- `FxMorphIcon` — a hamburger ↔ close (✕) morphing menu icon.
- `FxRipple` — colorable tap ripples that expand and fade from each touch
  point (no Material ancestor required).
- `FxWaveDivider` — a horizontal band with an animated sine-wave edge.

## 0.19.0

Atmospheric backgrounds & shapes.

### Added
- `FxAurora` — a drifting, blurred multi-blob "aurora" gradient backdrop.
- `FxRadar` — a rotating radar/sonar sweep with rings, crosshairs, and a
  fading trail.
- `FxBlob` — an organic, continuously morphing blob shape (clips an optional
  child).

## 0.18.0

Cinematic & stylized effects.

### Added
- `FxKenBurns` — a slow, ping-ponging zoom-and-pan for image/hero backgrounds
  (reduced-motion aware).
- `FxGlitch` — a looping RGB-split glitch that spikes intermittently.
- `FxShine` — a diagonal glossy light sweep across a child (looping or single).

## 0.17.0

Counters, selectors & backgrounds.

### Added
- `FxOdometer` — a rolling-digit number display; each digit scrolls to its new
  value.
- `FxSegmentedControl` — an animated segmented selector with a sliding pill and
  cross-fading labels.
- `FxParticles` — an ambient field of drifting particles (reduced-motion aware),
  with an optional foreground child.

## 0.16.0

Decorative & chat widgets.

### Added
- `FxGradientBorder` — a continuously rotating gradient outline (the "AI glow"
  border) around any child.
- `FxWaveProgress` — a liquid water-fill progress indicator (circle or box) with
  an animated wave surface and optional centered label.
- `FxTypingIndicator` — the chat "typing…" indicator: sequenced pulsing dots,
  optionally inside a bubble.

## 0.15.0

Interactive card & action widgets.

### Added
- `FxFlipCard` (+ `FxFlipCardController`) — a 3D flip between front/back faces,
  on tap or programmatically, with back-face un-mirroring.
- `FxSpeedDial` — an expanding FAB menu whose actions fan out staggered while
  the main icon rotates.
- `FxAnimatedCheck` — a success indicator that draws a circle then a checkmark
  stroke-by-stroke (reduced-motion aware).

## 0.14.0

Form & content widgets.

### Added
- `FxExpandable` — an animated accordion (collapsible body + rotating chevron).
- `FxRating` — an interactive star rating that pops the tapped star.
- `FxProgressBar` — a rounded progress bar that animates toward its value, or
  sweeps continuously when indeterminate (optional gradient fill).

## 0.13.0

Indicators & attention widgets.

### Added
- `FxPageIndicator` — animated worm-style page dots synced to a `PageController`.
- `FxBadge` (+ `Widget.badge(count)`) — a count badge that pops when its value
  changes.
- `FxPulse` — a looping sonar halo of expanding, fading rings for live/attention
  indicators.

## 0.12.0

More interactive widgets.

### Added
- `FxMarquee` — continuously scrolling ticker for overflowing content
  (reduced-motion aware).
- `FxSwipeToDismiss` — swipe-to-dismiss with fade, velocity-aware fling, and
  spring-back when released below the threshold.
- `FxCountdown` — a countdown that animates each tick (default slide-up digit
  swap, or a custom `builder`), firing `onComplete` at zero.

## 0.11.0

Modern UI building blocks.

### Added
- `FxSwitcher` — animate between children when the (keyed) child changes
  (`fade`, `scaleFade`, `slideUp`, `slideHorizontal`, `rotationFade`).
- `FxSkeleton` (+ `FxSkeleton.circle`) — shimmering loading placeholders.
- `FxAnimatedGradient` — a living gradient background whose direction rotates.

## 0.10.0

Scroll-driven animations.

### Added
- `FxScrollLinked` (and `Widget.animateOnScroll(effects)`) — drives effects from
  a widget's **scroll position** in the nearest `Scrollable` (reveal as it
  enters the viewport), rather than from time.
- `FxParallax` (and `Widget.parallax(amount:)`) — scroll parallax translation.
- `fxComposeFrame` — the shared frame-composition helper is now public, reused
  by both the time-driven engine and scroll-driven effects.

## 0.9.0

Spring routes + theme ergonomics.

### Added
- `context.fxPushSpring(page, stiffness:, damping:, …)` — a physically
  spring-driven page transition whose duration is the spring's own settle time
  (natural overshoot + settle, not a fixed number).
- `FxThemeData.copyWith(...)` plus value equality / `hashCode`.

## 0.8.0

Theme transitions and effects separately.

### Added
- `FxTheme.transitionCurve` and `FxTheme.transitionDuration` — page transitions
  now inherit their own easing/timing, independent of effect animations.
- `FxPageRoute.curve` is now optional and resolves from
  `FxTheme.of(context).transitionCurve` when omitted; `context.fxPush` (and
  `fxPushReveal`/`fxPushFrom`) inherit `transitionDuration` too.

## 0.7.0

Modern-motion pass across the whole library.

### Changed (behavior)
- **Default easing is now Material 3 emphasized** (`FxCurves.emphasized`) instead
  of `easeInOut` — a confident, quick-in / smooth-settle feel across every effect
  and transition. Override per effect (`.curve(...)`) or globally via `FxTheme`.
- Default effect/transition duration nudged 300 → 350 ms for a more deliberate,
  premium cadence.
- Page transitions now default to emphasized easing.

### Added
- Material 3 expressive easing tokens on `FxCurves`: `emphasized`,
  `emphasizedDecelerate` (entering), `emphasizedAccelerate` (leaving),
  `standardDecelerate`.

### Polished
- `cupertino` transition now dims the receding page (native iOS parallax feel).
- `sheet` transition gains rounded top corners that flatten on arrival, plus a
  dim + deeper scale on the page behind (iOS 15+ sheet stack).

## 0.6.0

More modern transitions + origin-aware reveals.

### Added
- `containerTransform` transition — the incoming page expands from an
  `originRect` (e.g. a tapped card) into the full screen, with easing corners.
- `glass` transition — the incoming page materializes through a blur that peaks
  mid-transition and clears.
- `circularReveal` now honors a `revealAlignment` origin (reveal from a tap
  point, not just the center).
- `context.fxPushReveal(page, alignment: …)` and
  `context.fxPushFrom(page, originRect)` convenience navigators.

## 0.5.0

Modern page transitions.

### Added
- Seven modern `FxPageTransition` styles: `fadeThrough` (Material 3),
  `cupertino` (iOS parallax), `depth`, `sheet` (modal), `circularReveal`,
  `cube3D`, and `blur` — all usable via `FxPageRoute` / `context.fxPush` and the
  reusable `buildFxTransition` builder.

## 0.4.0

More animation categories.

### Added
- Reveal & clip effects: `circularReveal`, `wipe` (any direction), `curtain`.
- Loading-indicator widgets: `FxDotsLoader`, `FxBarsLoader`, `FxProgressRing`.
- Rich text FX: `gradientText`, `wavyText`, `scrambleText`, `wordsFadeIn`
  (with `FxGradientText`, `FxWavyText`, `FxScrambleText`, `FxWordsText`).
- `FxConfetti` + `FxConfettiController` — a particle celebration burst.
- `FxTilt` (and the `tilt` extension) — pointer-driven 3D perspective tilt.

## 0.3.0

Exit animations + quality hardening.

### Added
- `FxAnimatedVisibility` (and the `animatedVisibility` extension): animate a
  widget **out** — the entrance chain plays in reverse on dismiss, and the child
  is only removed once the exit completes. Fires `onDismissed` after removal.

### Changed
- Stricter analysis: enabled `strict-casts`, `strict-inference`,
  `strict-raw-types`, plus `directives_ordering`, `always_declare_return_types`,
  `unawaited_futures`, `use_super_parameters`, and more. Codebase is clean under
  all of them.

### Verified
- Golden coverage extended to the new effects (grayscale, shimmer, rollIn).
- Example compiles for **web** (CanvasKit) and passes the **Wasm** dry run.

## 0.2.0

Expanded animation catalog.

### Added
- Loading effects: `shimmer` (gradient sweep) and `breathe`.
- Color/filter effects: `saturate` / `grayscale`, `brightness`, `hueShift`
  (animated `ColorFilter` matrices).
- Animate.css-style entrances: `rollIn`, `hinge`, `jackInTheBox`,
  `lightSpeedIn/Out`, `rotateIn`.
- Text animations: `String.typewriter()`, `String.animateChars()` (per-character
  stagger), and `num.countUp()` (animated number ticker) — plus the `FxTypewriter`,
  `FxAnimatedText`, and `FxCountUp` widgets.
- A shared `fxKeyframe` helper for keyframe-based effects.

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
