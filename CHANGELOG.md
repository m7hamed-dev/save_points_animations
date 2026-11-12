## Unreleased

### Breaking
- **`.duration()` and `.curve()` now carry forward.** An effect without its own
  duration or curve inherits the last one set with `.duration()` / `.curve()`
  earlier in the chain (then `animate(duration:, curve:)`, then `FxTheme`), so
  `.fade().duration(600.ms).scale()` runs both for 600ms. Timing passed to an
  effect's constructor (e.g. `elastic()`'s curve) stays local, and delays are
  never inherited. Chains that relied on later effects falling back to the
  theme need their own `.duration()` / `.curve()`.
- **A call that adds several effects is one group.** `.duration()`,
  `.delay()` and `.curve()` right after `fadeIn()`, `scaleIn()`,
  `slideFrom…()`, `zoom()`, `lightSpeedIn/Out()`, `rotateIn()` or
  `parallel([...])` now apply to every effect it added, not only the last one
  (previously `fadeIn().duration(1.seconds)` slowed the slide but not the
  fade).
- **Paint-only chains build no `Opacity` / `Transform` widgets.** Chains whose
  effects only move, scale, rotate, skew, flip, slide or fade are applied at
  paint time (see *Performance*). Tests that looked for those widgets should
  check the painted result instead (e.g. golden tests).
- The one-call shortcuts on `Widget` (`fadeIn()`, `shake()`, `float()`, …)
  moved from the `FxAnimate` extension to a new `FxAnimateShortcuts`
  extension. Only code that named the extension explicitly is affected.
- `animateList()` staggers items by delaying each item's start instead of
  adding the offset to every effect's own delay, so an `FxTheme` delay is no
  longer overridden.

### Added
- Chain-wide timing: `.animate(duration:, delay:, curve:)`. `delay` waits once
  before the first automatic play and is not repeated by loops.
- State-driven animation: `.animate(target: …)` renders the chain at a point
  of its timeline (`0..1`) and animates to every new value it is rebuilt with.
- `onPlay` / `onComplete` callbacks on `.animate()`, and `looping(count:)` to
  stop after a number of cycles (then `onComplete` fires).
- Right-to-left support: `slideFromStart()` / `slideFromEnd()` (also as
  one-call shortcuts) and `directional:` on `moveX`, `slideX`, `MoveEffect` and
  `SlideEffect` mirror horizontal motion under `TextDirection.rtl`.
  `FxAccumulator.textDirection` / `isRtl` let custom effects do the same.
- `onVisible()` / `animateOnVisible()` take `once` (set `false` to rewind when
  the widget leaves the viewport and replay when it returns), `onShown` and
  `onHidden`.
- `FxDurations`: the Material 3 duration tokens (`short1` … `extraLong4`).
- `animateList()` gains `.duration()`, `.curve()`, `.delay()`, `.moveY()` and
  `slideX(directional:)`; keyed children keep their animation when reordered.
- Opt-in entrypoints: `package:save_points_animations/core.dart` (the engine,
  with only `animate()` added to `Widget`) and
  `package:save_points_animations/widgets.dart` (the widget catalog). The main
  library still exports everything.
- `FxEffect.paintOnly` and `FxAccumulator.fractionalTranslation` for custom
  effects that should take the paint-time path.
- Keyboard support for interactive widgets: `FxAnimatedSlider` /
  `FxRangeSlider` step with the arrow keys (each range thumb is its own focus
  stop), and Enter / Space activate `FxAnimatedToggle`, `FxAnimatedCheckbox`,
  `FxAnimatedRadio`, the animated buttons (`FxGlowButton`, `FxGradientButton`,
  `FxJellyButton`, `FxShimmerButton`, `FxMagneticButton`, `FxHeartButton`,
  `FxProgressButton`, `FxHoldButton` — hold the key to fill),
  `FxExpandable`'s header, `FxThemeToggle` and `FxScrollToTop`. A focus ring
  appears only under keyboard focus; disabled controls are skipped.
- `FxSlideToConfirmController` is now exported. It is the type of
  `FxSlideToConfirm.controller`, but apps could only reach it through
  `package:save_points_animations/src/…`.
- A widget test catalog (`test/catalog/`): a golden image for every exported
  widget (plus a check that none is missing), tap-target / label / contrast
  guideline checks for 41 interactive widgets, and 77 behavior tests. Known
  widget bugs found by it are kept as skipped tests with the reason, and run
  with `--dart-define=CATALOG_RUN_SKIPPED=true`.
- A migration guide from `flutter_animate`
  ([doc/migrating_from_flutter_animate.md](doc/migrating_from_flutter_animate.md))
  and an interactive playground in the example app.

### Performance
- Chains made only of paint-only effects (fade, move, slide, scale, rotate,
  skew, flip and the motion/attention/entrance effects built on them) no longer
  rebuild any widget per frame: a single render object applies the composed
  transform and opacity at paint time inside its own repaint boundary. Hit
  testing follows the painted position, including outside the child's layout
  bounds.

### Changed
- Tests and the example app import `package:material_ui/material_ui.dart`
  instead of `package:flutter/material.dart`, which is deprecated since
  Flutter 3.47. The package itself never depended on Material or Cupertino —
  only on Flutter's widgets layer and below — so apps can pair it with
  `material_ui`, `cupertino_ui` or their own design system.
  `material_ui` is a dev dependency only.

### Fixed
- About 19 continuously-animating widgets never started moving unless reduced
  motion had been toggled: they started their loop only from
  `FxMotionAware.onReduceMotionChanged`, which fires on changes, not at mount.
  Affected: `FxGlowButton`, `FxGradientButton`, `FxShimmerButton`,
  `FxNeonText`, `FxTypingIndicator`, `FxPlasma`, `FxBouncingBall`,
  `FxWaveDots`, `FxShinyText`, `FxDnaLoader`, `FxHeartbeatLine`,
  `FxMeshGradient`, `FxCircularText`, `FxWaveProgress`, `FxRadar`,
  `FxOrbitLoader`, `FxDotsLoader`, `FxBarsLoader` and `FxProgressRing` (and
  so `FxProgressButton`'s spinner). The `FxMotionAware` docs now say when the
  callback fires.
- `FxProgressBar` (indeterminate sweep), `FxKenBurns` and `FxLoadingOverlay`
  now honor reduced motion, at mount and when the setting changes at runtime.
- 18 looping widgets (e.g. `FxAnimatedGradient`, `FxAurora`, `FxBlob`,
  `FxBorderBeam`, `FxShine`, `FxSpotlight`, `FxExpandable`, `FxHoldButton`)
  now apply a new `duration`, `curve` or mode passed on rebuild instead of
  keeping the values they were created with.
- `.animate()` and `animateOnScroll` no longer reset the animated child's
  `State`. The engine drops no-op `Opacity` / `Transform` / wrapper widgets at
  rest, which changed the widget type above the child and made Flutter
  re-create it — a `TextField` lost focus, a nested count-up or animation
  restarted, etc. (`.fade()` mounted the child twice, `.shake()` three times).
  The child is now held under a stable `GlobalKey`, so it is moved, not rebuilt.
- `onVisible()` / `animateOnVisible()` now fire when the widget is scrolled
  into view. They relied on scroll notifications, which only bubble *up* from a
  `Scrollable` and never reach its content, so they worked only for widgets
  already visible at mount (or mounted lazily by a `ListView`) — in a
  `SingleChildScrollView` an off-screen entrance stayed invisible forever. The
  trigger now listens to every enclosing scroll position (nested scroll views
  included) and measures the visible fraction on both axes, so off-screen items
  in horizontal lists no longer fire at mount.
- `FxReducedMotionBehavior.disable` now shows the child untouched, as
  documented. It parked the animation on its first frame instead, so an
  entrance such as `.fade()` left the widget at opacity 0 for users with
  "reduce motion" enabled.
- `FxAnimatedSlider` and `FxRangeSlider` no longer trip Flutter's semantics
  assertion (*"A SemanticsNode with action "increase" needs to be annotated
  with either both "value" and "increasedValue" or neither"*) when a screen
  reader or semantics is on. They now report `increasedValue` /
  `decreasedValue` — the value an increase/decrease would produce, clamped to
  the track and, on the range slider, to the other thumb.

## 0.44.0

Widgets as extensions, more page transitions & lifecycle fixes.

### Added
- `FxWrap` extension on `Widget` — apply any child-wrapping or backdrop widget
  fluently, the same way effects already chain. Decorators wrap the receiver
  (`Text('Sale').fxShine()`, `card.fxGradientBorder()`, `label.fxHoldButton(...)`),
  and backdrop effects layer it on top (`content.fxAurora()`, `page.fxSnow()`).
  31 methods in total.
- Four new `FxPageTransition` styles: `fadeUpwards` (Material fade-up), `flip`
  and `flipVertical` (3D card flip), and `shrink` (pull-in from slightly
  enlarged).

### Fixed
- `FxSwipeCards`, `FxSwipeToDismiss`, and `FxSlideToConfirm` no longer throw
  *"Looking up a deactivated widget's ancestor is unsafe"* when disposed before
  any interaction — their `AnimationController`s are now created in `initState`
  instead of lazily inside `dispose`.
- `FxOdometer` no longer overflows vertically — the rolling digit strip lays out
  in unbounded height and is clipped to the single-digit window.
- `FxMarquee` no longer overflows horizontally — it now scrolls inside a
  clipping viewport that grants the content unbounded width.

### Performance
- Every continuously-animating widget (56 in total) now wraps its animating
  subtree in a `RepaintBoundary`, so its per-frame repaints no longer invalidate
  the paint of ancestors and siblings.
- 14 `CustomPainter`-based widgets (dot grid, radar, pulse, orbit loader,
  sparkline, pie chart, wave divider/progress, hold button, gradient/beam
  borders, circular text, animated check/checkbox/radio, morph icon) now repaint
  through `super(repaint: animation)` instead of an `AnimatedBuilder` — the
  painter repaints directly on each tick without rebuilding the widget subtree,
  and their `child`/label subtrees are no longer rebuilt every frame.
- `FxMarquee` now drives its scroll offset through a `ValueNotifier` +
  `ValueListenableBuilder` with the row as a cached `child`, so only the
  `Transform.translate` updates per frame instead of rebuilding the row.
  All visuals are unchanged (verified against the golden tests).

### Changed
- Split `fx_page_route.dart` into `fx_page_transition.dart` (the enum),
  `fx_transition_builder.dart` (`buildFxTransition` + per-style builders), and
  `fx_page_route.dart` (`FxPageRoute` + `FxNavigator`). Public API unchanged.

## 0.43.0

Interactive UI: buttons, toggles & overlays.

### Added
- `FxGradientButton` — a pill button with a slowly rotating "aurora" gradient
  fill that dips on press.
- `FxThemeToggle` — an animated day/night switch; the thumb slides between a sun
  and a crescent moon while the track cross-fades from sky to starry night.
- `FxLoadingOverlay` — a full-surface overlay that blurs and dims the background
  and shows a sweeping spinner (with an optional message) while `visible`.

## 0.42.0

Pickers & surfaces.

### Added
- `FxWheelPicker` — an iOS-style scrolling wheel picker; items curve away with
  perspective and snap to a highlighted center band.
- `FxGlassCard` — a frosted-glass surface that blurs what's behind it and sweeps
  a soft diagonal sheen across the face.
- `FxScrollToTop` — a floating button that fades and scales in once a
  `ScrollController` passes a threshold, and smooth-scrolls to the top on tap.

## 0.41.0

Forms & pointer interaction.

### Added
- `FxFloatingField` — a text field with a floating label that shrinks up on
  focus/content and an underline that animates to the accent colour. Built on
  `EditableText` (Material-free).
- `FxMagneticButton` — a target that leans toward the pointer while hovered and
  springs back to center on exit (desktop/web); forwards taps on touch.
- `FxWizardSteps` — a horizontal labelled step indicator; completed steps fill
  and show a check, connectors fill as you progress.

## 0.40.0

Comparison, keypad & reactions.

### Added
- `FxImageCompare` — a before/after slider; drag the divider to wipe the "after"
  layer over the "before".
- `FxNumberPad` — a dial-pad keypad whose keys dip and highlight on tap; emits
  digits and backspace.
- `FxReactionBar` — a Facebook-style emoji reaction row; the selected reaction
  pops up larger with its label.

## 0.39.0

Media & range controls.

### Added
- `FxRangeSlider` (+ `FxRange`) — a dual-thumb range slider; thumbs can't cross,
  the active one grows and glows while dragging.
- `FxCarousel` (+ `FxCarouselDots`) — a cover-flow page carousel where the
  centered page is full-size and neighbours shrink and fade; the dots track the
  page with the active one stretching into a pill.
- `FxWaveform` — an animated audio-style bar visualizer that bounces while
  `playing` and settles to an idle line when paused.

## 0.38.0

Pickers & sheets.

### Added
- `FxDraggableSheet` — a draggable bottom sheet that snaps between configurable
  height fractions and springs to the nearest snap point on release.
- `FxColorWheel` — a circular HSV color picker; drag to set hue (angle) and
  saturation (radius), with an animated selector ring. Material-free.
- `FxDateStrip` — a horizontally-scrolling strip of day chips; the selected day
  animates into a filled pill.

## 0.37.0

Animated input controls & feedback.

### Added
- `FxAnimatedSlider` — a draggable slider whose thumb grows and glows while
  dragging, with an optional floating value bubble.
- `FxStepper` — a compact `−`/`+` numeric stepper; buttons press in on tap and
  the value rolls vertically (up or down) as it changes.
- `FxToast` — a declarative slide-and-fade toast/banner driven by a `visible`
  flag; slides from the top or bottom, manages no overlay of its own.

## 0.36.0

More animated bottom navigation bar styles.

### Added
- `FxDotNavBar` — icons scale up when selected while a dot slides beneath the
  active item.
- `FxFrostedNavBar` — a floating frosted-glass bar (backdrop blur + translucent
  tint) with a sliding highlight; place it over content so the blur shows.
- `FxGooeyNavBar` — a "gooey" blob highlight that stretches as it travels
  between destinations, then settles.

## 0.35.0

Animated bottom navigation bars.

### Added
- `FxPillNavBar` — the selected destination expands into a tinted pill that
  reveals its label (Salomon style).
- `FxCurvedNavBar` — a curved notch that slides to the selected item with its
  icon floating in a circle above the dip.
- `FxNavItem` — the shared `{icon, label}` model for the new nav bars.
  (Joins the existing `FxAnimatedNavBar`.)

## 0.34.0

Space, water & chance.

### Added
- `FxStarField` — a "warp speed" starfield streaming toward the viewer.
- `FxBubbles` — rising, gently wobbling bubbles over a child.
- `FxSpinWheel` (+ `FxSpinWheelController`) — a fortune wheel that spins with
  deceleration and reports the landed segment.

## 0.33.0

More data viz + celebration.

### Added
- `FxPieChart` — an animated donut chart whose segments sweep in.
- `FxFireworks` — periodic celebratory particle bursts over a child.
- `FxTagChips` — a wrap of multi-selectable filter chips with animated selection.

## 0.32.0

Data viz & text.

### Added
- `FxSparkline` — a self-drawing mini line chart with an optional filled area.
- `FxBarChart` — bars that grow to their values (and re-animate on change).
- `FxTypeLoop` — a looping typewriter that types, pauses, deletes, and advances
  through phrases.

## 0.31.0

Loaders & decorative motion.

### Added
- `FxOrbitLoader` — dots that orbit a center, pulsing as they travel.
- `FxSnow` — falling, gently swaying particles (snow / rain / embers) over a
  child (reduced-motion aware).
- `FxCircularText` — text laid out around a circle that can slowly spin.

## 0.30.0

Confirm, load & choose.

### Added
- `FxHoldButton` — press-and-hold to confirm; a ring fills while held and
  rewinds if released early.
- `FxSkeletonText` — a multi-line shimmering placeholder paragraph.
- `FxAnimatedRadio` — a generic radio button whose dot scales in on selection.

## 0.29.0

Social & input widgets.

### Added
- `FxAvatarStack` — overlapping circular avatars that spread apart on hover.
- `FxAnimatedTabBar` — a text tab bar with an underline that glides to the
  selected tab.
- `FxPinDots` — an animated PIN/OTP indicator: dots pop as they fill and the row
  shakes on error.

## 0.28.0

Forms, feeds & backdrops.

### Added
- `FxAnimatedCheckbox` — a checkbox whose box fills and whose check draws in.
- `FxTimeline` — a vertical dot-and-connector timeline with staggered content
  reveal.
- `FxDotGrid` — an animated dot-grid background with a diagonal ripple.

## 0.27.0

Menus, cards & navigation.

### Added
- `FxCircularMenu` — a main button that fans its children out along an arc.
- `FxTiltGlareCard` — a pointer-driven 3D tilt card with a moving glare
  highlight.
- `FxAnimatedNavBar` — a bottom nav bar with an indicator that glides behind the
  selected item (which lifts).

## 0.26.0

Gauges, reveals & depth.

### Added
- `FxGauge` — an animated arc gauge / speedometer that eases to its value.
- `FxScratchCard` — drag-to-scratch reveal (coupons, spoilers) via a
  `BlendMode.clear` mask.
- `FxParallaxLayers` (+ `FxParallaxLayer`) — a pointer-tilt parallax stack where
  layers shift by depth for a 3D effect.

## 0.25.0

Accents & scroll feedback.

### Added
- `FxBorderBeam` — a glowing comet beam that travels around a rounded border.
- `FxSpotlight` — a drifting radial highlight over content (or `followPointer`).
- `FxScrollProgress` — a reading-progress bar tied to a `ScrollController` or the
  nearest `Scrollable`.

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
