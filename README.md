<!--
  MAINTAINER TODO before publishing:
  - Replace `your-org` in every URL with the real GitHub org/user (pulled from pubspec `repository`).
  - Add a real LICENSE (the LICENSE file currently says "TODO: Add your license here.")
    and update the License section + badge below.
  - If the package is not yet on pub.dev, the Pub Version badge will 404 until first publish.
-->

<div align="center">

# Save Points Animations

### A fluent, extensible animation framework for Flutter — animate **any** widget with chainable extension methods, backed by a single-controller engine.

[![Pub Version](https://img.shields.io/pub/v/save_points_animations?style=flat-square&logo=dart&color=0175C2)](https://pub.dev/packages/save_points_animations)
[![Flutter](https://img.shields.io/badge/Flutter-3.12+-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Reduced motion](https://img.shields.io/badge/a11y-reduced--motion-brightgreen?style=flat-square)](#-accessibility)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/your-org/save_points_animations/pulls)

[**📚 Documentation**](https://github.com/your-org/save_points_animations#readme) · [**🚀 Run the demo**](example/lib/main.dart) · [**🐛 Report Bug**](https://github.com/your-org/save_points_animations/issues) · [**✨ Request Feature**](https://github.com/your-org/save_points_animations/issues)

</div>

---

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

One controller. One `Transform`. One `Opacity`. No stack of nested animated widgets.

## Table of Contents

- [Why](#-why)
- [Features](#-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Usage](#-usage)
  - [The fluent engine](#the-fluent-engine)
  - [Timelines, triggers & scroll](#timelines-triggers--scroll)
  - [Physics, page transitions & Hero](#physics-page-transitions--hero)
  - [Text animations](#text-animations)
  - [Global theme](#global-theme)
  - [Custom effects](#custom-effects)
- [Widget Catalog](#-widget-catalog)
- [Built-in Effects](#-built-in-effects)
- [Accessibility](#-accessibility)
- [Tips & Best Practices](#-tips--best-practices)
- [Troubleshooting](#-troubleshooting)
- [Debug Tools](#-debug-tools)
- [Roadmap](#-roadmap)
- [Development](#-development)
- [Contributing](#-contributing)
- [License](#-license)

## 💡 Why

- **One controller, one `Transform`, one `Opacity`.** Every transform effect (move / scale / rotate / skew / flip) folds into a single `Matrix4`, and every fade into a single opacity multiplier — then wrapped in a `RepaintBoundary`. No per-effect widget nesting.
- **Immutable & chainable.** The chain builds a value; nothing animates until the widget builds.
- **Accessible by default.** Honors `MediaQuery.disableAnimations` and settles to a static frame under reduced motion — across the fluent engine *and* every looping widget.
- **Modern motion by default.** Effects and transitions ease with Material 3 **emphasized** curves out of the box (`FxCurves.emphasized` / `emphasizedDecelerate` / `emphasizedAccelerate`) — override any time.
- **Batteries included.** 110+ ready-made animated widgets — nav bars, buttons, charts, loaders, decorative backdrops — on top of the engine.
- **Extensible.** Create your own effect by extending `FxEffect` — no fork needed.

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔗 **Fluent effects** | `widget.animate().fade().moveY(50).scale()` — parallel by default, sequence with `.then()` |
| 🧩 **Widgets as extensions** | Every wrapping widget is also a `.fx…()` method: `card.fxShine()`, `content.fxAurora()` |
| ⏱️ **Timelines & staggers** | `.then()` barriers and `.animateList().interval(80.ms)` for lists |
| 👆 **Triggers & gestures** | `.onTap()` · `.onVisible()` · `.pressScale()` · `.hoverScale()` |
| 🌀 **Real physics** | `.spring()` / `.gravity()` / `.friction()` backed by `SpringSimulation` |
| 🚪 **Page transitions & Hero** | 20+ `FxPageTransition` styles + `context.fxPush(...)` + arc Hero flights |
| 🔤 **Text animations** | `'Typing…'.typewriter()`, `(1240).countUp()`, `'wavy ~'.wavyText()` |
| ♿ **Accessible** | Reduced-motion aware, semantic roles, haptics on controls |
| 🎨 **Themed** | `FxTheme` sets defaults for effects and transitions independently |
| 🛠️ **Debug HUD** | `page.showFPS()` / `.showPerformance()` — zero cost in release |

## 📦 Installation

```bash
flutter pub add save_points_animations
```

Or add it to your `pubspec.yaml`:

```yaml
dependencies:
  save_points_animations: ^0.44.0
```

Then import it:

```dart
import 'package:save_points_animations/save_points_animations.dart';
```

## 🚀 Quick Start

```dart
// 1. Animate any widget by chaining effects — they run in parallel:
Container()
    .animate()
    .fadeIn()
    .slideY(0.2)
    .scale(begin: 0.9);

// 2. One-liner sugar for common entrances:
Text('Welcome').fadeIn();

// 3. Decorate inline with a widget-as-extension:
Text('Sale').fxShine();

// 4. Drive a ready-made widget:
FxRating(value: stars, onChanged: (v) => setState(() => stars = v));
```

## 📖 Usage

### The fluent engine

**Simple — one line:**

```dart
Text('Welcome').fadeIn();
Container().fadeIn().slideFromBottom().scaleIn();
```

**Composed — parallel by default.** Effects without a `.then()` run together:

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

**Widgets as extensions.** Every child-wrapping widget is also a `.fx…()` method on `Widget`, so you can decorate inline instead of nesting constructors:

```dart
Text('Sale').fxShine();                          // glossy sweep
card.fxGradientBorder(borderRadius: 20);         // rotating gradient border
Text('Hold').fxHoldButton(onConfirmed: submit);  // press-and-hold ring
photo.fxKenBurns();                              // slow cinematic pan/zoom
```

Backdrop effects layer your widget *on top* of a full-bleed animation:

```dart
content.fxAurora();                 // drifting aurora clouds behind content
page.fxSnow(count: 60);             // snow falling over the page
banner.fxAnimatedGradient(colors: [Colors.purple, Colors.blue]);
```

**Imperative control:**

```dart
final fx = FxController();

card.animate(controller: fx, autoPlay: false).fadeIn().scaleIn();

// elsewhere:
fx.play();
fx.restart();
fx.repeat(reverse: true);
```

> [!NOTE]
> The underlying `AnimationController` is owned and disposed by the widget — calling `fx.dispose()` is a safe no-op, so you can never leak or double-dispose it.

### Timelines, triggers & scroll

**Timelines — sequence with `.then()`:**

```dart
chip.animate()
    .fade().scale(begin: 0.6)   // run together
    .then(120.ms)               // wait for the above + 120ms
    .rotate(-20)
    .then()
    .shake();
```

> [!IMPORTANT]
> `.duration()`, `.delay()`, and `.curve()` apply to the **most recently added effect** (the widely-used `flutter_animate` convention). Set them per effect, or use an `FxTheme` for global defaults.

**Staggered lists:**

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

**Triggers — play on an event:**

```dart
badge.animate().tada().onTap();                   // replay on tap
menu.animate().fadeIn().onHover();                // replay on hover
card.animate().fadeIn().slideX(0.1).onVisible();  // play when scrolled into view
```

Available: `onTap` · `onDoubleTap` · `onLongPress` · `onHover` · `onAppear` · `onVisible` / `animateOnVisible`.

**Scroll-driven animations & gestures:**

```dart
// Effects driven by scroll position (not time):
card.animateOnScroll(const [FadeEffect(), SlideEffect(beginY: 0.2)]);

banner.parallax(amount: 40);   // moves as the user scrolls

button.pressScale();   // dips while pressed, springs back
button.pressBounce();  // dips then elastic overshoot on release
card.hoverScale();     // grows while hovered (desktop/web)
```

### Physics, page transitions & Hero

`.spring()` drives the previous effect with a `SpringSimulation` and sets the physically-correct settle duration for you:

```dart
icon.animate().scale(begin: 0.5).spring(stiffness: 300, damping: 15, mass: 1);
box.animate().moveY(-120).gravity();          // constant-acceleration fall
chip.animate().moveX(200).friction();         // flick that decelerates

// …or use the curves directly anywhere a Curve is accepted:
widget.animate().scale(begin: 0).curve(FxPhysics.spring(stiffness: 260));
```

Push routes with a built-in transition:

```dart
context.fxPush(DetailPage(), transition: FxPageTransition.sharedAxisHorizontal);

// Reveal from a tap point, expand from a card's bounds, or spring in:
context.fxPushReveal(DetailPage(), alignment: Alignment.topRight);

final box = key.currentContext!.findRenderObject() as RenderBox;
context.fxPushFrom(DetailPage(), box.localToGlobal(Offset.zero) & box.size);

context.fxPushSpring(DetailPage(), stiffness: 220, damping: 18);

// Hero flights (with an optional curved-arc path):
Image.asset('a.png').heroAnimate('photo');   // same tag on both screens
```

<details>
<summary><b>All page transitions</b></summary>

`fade` · `scale` · `zoom` · `slide` (any `AxisDirection`) · `rotation` · `sharedAxisHorizontal` · `sharedAxisVertical` — plus the modern set: `fadeThrough` (Material 3) · `cupertino` (iOS parallax) · `depth` · `sheet` (modal) · `circularReveal` · `cube3D` · `blur` · `containerTransform` · `glass` · `fadeUpwards` · `flip` · `flipVertical` · `shrink`.

</details>

### Text animations

```dart
'Typing…'.typewriter(cursor: '|');       // character-by-character reveal
'Staggered'.animateChars();              // per-character stagger in
(12840).countUp(duration: 1.seconds);    // animated number ticker
'Gradient'.gradientText();               // animated gradient headline
'wavy ~'.wavyText();                     // rippling wave
'DECODING'.scrambleText();               // scramble-in reveal
'word by word'.wordsFadeIn();            // staggered word fade
FxShinyText('PREMIUM');                  // sweeping metallic sheen
```

### Global theme

Effects and page transitions are themed **independently**:

```dart
FxTheme(
  // Effects (.animate()):
  duration: 300.ms,
  curve: FxCurves.snappy,
  // Page transitions (FxPageRoute / context.fxPush):
  transitionCurve: FxCurves.emphasized,
  transitionDuration: 400.ms,
  respectReducedMotion: true,
  child: MaterialApp(...),
);
```

Resolution order for any parameter: **explicit argument → nearest `FxTheme` → package default.** Omit `curve`/`duration` on `context.fxPush` and they inherit `transitionCurve` / `transitionDuration` from the theme.

### Custom effects

Extend `FxEffect` — no fork needed:

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

## 🧩 Widget Catalog

110+ ready-made widgets. Every continuously-animating one is wrapped in a `RepaintBoundary` and honors reduced motion. Grouped below — expand a section for usage.

<details>
<summary><b>🧭 Navigation & bars</b></summary>

```dart
// Sliding circle indicator + icon lift:
FxAnimatedNavBar(items: icons, currentIndex: i, onTap: setIndex);

// Selected item expands into a labelled pill (Salomon style):
FxPillNavBar(items: navItems, currentIndex: i, onTap: setIndex);

// Floating icon over a sliding curved notch:
FxCurvedNavBar(items: navItems, currentIndex: i, onTap: setIndex);

// Icon scale-up + sliding dot:
FxDotNavBar(items: navItems, currentIndex: i, onTap: setIndex);

// Frosted-glass floating bar (blur + sliding highlight):
FxFrostedNavBar(items: navItems, currentIndex: i, onTap: setIndex);

// Gooey blob that stretches as it moves:
FxGooeyNavBar(items: navItems, currentIndex: i, onTap: setIndex);
// navItems are FxNavItem(icon: ..., label: ...)

FxAnimatedTabBar(tabs: labels, selectedIndex: i, onChanged: setTab); // sliding underline
FxCircularMenu(icon: const Icon(Icons.add), children: actions);      // radial fan menu
FxSpeedDial(icon: const Icon(Icons.add), children: [...]);           // expanding FAB menu
FxPageIndicator(controller: pageController, count: 4);               // animated worm dots
FxScrollProgress(controller: _scroll);                              // reading-progress bar
Stack(children: [listView, FxScrollToTop(controller: _scroll)]);    // floating "to top" button
```

</details>

<details>
<summary><b>🔘 Buttons & CTAs</b></summary>

```dart
FxGradientButton(onPressed: submit, child: const Text('Continue')); // rotating aurora gradient
FxGlowButton(onPressed: buy, child: const Text('Get Pro'));         // breathing glow halo
FxJellyButton(onPressed: send, child: const Text('Send'));          // jelly wobble on tap
FxShimmerButton(onPressed: go, child: const Text('Go'));            // sweeping-sheen CTA
FxHeartButton(isLiked: liked, onChanged: (v) => …);                 // like pop + burst
FxHoldButton(onConfirmed: delete, child: const Icon(Icons.delete)); // press-and-hold ring
FxMagneticButton(onTap: go, child: myButton);                       // leans toward the pointer
FxSlideToConfirm(label: const Text('Slide to pay'), onConfirmed: pay);
FxProgressButton(state: _state, onPressed: submit, child: const Text('Submit'));
```

</details>

<details>
<summary><b>🎚️ Inputs & controls</b></summary>

```dart
FxAnimatedSlider(value: v, onChanged: (x) => setState(() => v = x));  // glow + value bubble
FxRangeSlider(values: r, onChanged: (v) => …);                        // dual-thumb, r = FxRange
FxStepper(value: qty, onChanged: (n) => …, max: 10);                  // rolling value
FxRating(value: stars, onChanged: (v) => …);                         // popping stars
FxAnimatedCheckbox(value: on, onChanged: (v) => …);                  // fill + draw-in check
FxAnimatedRadio<int>(value: 1, groupValue: sel, onChanged: (v) => …);
FxAnimatedToggle(value: on, onChanged: (v) => …);                    // custom switch
FxThemeToggle(isDark: dark, onChanged: (v) => …);                    // sun ↔ moon switch
FxSegmentedControl(segments: const ['Day', 'Week'], selectedIndex: i, onChanged: (v) => …);
FxTagChips(tags: labels, selected: _sel, onToggle: toggle);          // animated filters
FxWheelPicker(items: const ['Low', 'High'], selectedIndex: i, onChanged: (v) => …);
FxNumberPad(onDigit: (d) => append(d), onBackspace: removeLast);     // keypad
FxPinDots(length: 4, filled: entered, error: wrong);                 // OTP dots, shake on error
FxFloatingField(label: 'Email', onChanged: (v) => email = v);        // floating-label field
FxColorWheel(color: c, onChanged: (v) => …);                        // HSV color picker
FxDateStrip(days: days, selected: picked, onChanged: (d) => …);      // day strip
FxReactionBar(reactions: const ['👍','❤️'], labels: const ['Like','Love'], selected: r, onChanged: (i) => …);
```

</details>

<details>
<summary><b>🃏 Cards, sheets & layout</b></summary>

```dart
FxFlipCard(front: cardFront, back: cardBack);        // 3D flip on tap
FxTiltGlareCard(child: card);                        // pointer-driven 3D tilt + glare
FxGlassCard(child: content);                         // frosted glass + sheen (place over content)
FxSwipeCards(cards: cards, onSwiped: (i, right) => …); // Tinder-style deck
FxSwipeToDismiss(onDismissed: remove, child: card);  // swipe away, spring back
FxCarousel(children: cards, onPageChanged: (i) => …); // cover-flow carousel
FxCarouselDots(count: cards.length, page: page);
FxExpandable(header: Text('Details'), body: bodyWidget); // animated accordion
FxDraggableSheet(snapSizes: const [0.3, 0.6, 0.9], child: content);
FxTimeline(items: const [Text('Ordered'), Text('Shipped'), Text('Delivered')]);
FxWizardSteps(steps: const ['Cart', 'Address', 'Pay'], currentStep: step);
FxStepProgress(count: 4, currentStep: step);
FxImageCompare(before: Image.asset('a.jpg'), after: Image.asset('b.jpg')); // before/after wipe
FxScratchCard(child: const Text('You won!'));        // drag to reveal
```

</details>

<details>
<summary><b>📊 Charts & data-viz</b></summary>

```dart
FxPieChart(values: const [5, 3, 2], colors: palette);   // donut sweeps in
FxBarChart(values: const [4, 7, 3, 9, 6]);              // bars grow to value
FxSparkline(values: const [3, 5, 4, 8, 6, 9]);          // self-drawing trend line
FxGauge(value: 0.72, child: const Text('72%'));         // speedometer arc
FxRadar(size: 160, color: Colors.green);                // sweeping scan
FxWaveform(playing: isPlaying, color: Colors.pink);     // audio bar visualizer
FxWaveProgress(value: 0.65, child: Text('65%'));        // liquid water-fill
FxProgressBar(value: 0.6);                              // omit value for indeterminate
FxOdometer(value: score);                               // rolling-digit counter
FxHeartbeatLine(color: Colors.redAccent);               // ECG pulse line
```

</details>

<details>
<summary><b>⏳ Loaders & progress</b></summary>

```dart
const FxDotsLoader();          const FxBarsLoader();      const FxProgressRing();
const FxOrbitLoader();         // dots orbiting a center
const FxWaveDots();            // dots in a traveling wave
const FxBouncingBall();        // squash-and-stretch bounce
const FxDnaLoader();           // rotating double helix
const FxTypingIndicator();     // chat "typing…" bubble
FxSkeleton.circle(size: 48);   const FxSkeleton(width: 200);   FxSkeletonText(lines: 3);
FxCircularCountdown(duration: 10.seconds);   // depleting ring timer
FxCountdown(duration: 30.seconds, onComplete: launch);
Stack(children: [page, FxLoadingOverlay(visible: busy, message: 'Saving…')]);
```

</details>

<details>
<summary><b>🌌 Decorative & ambient backdrops</b></summary>

```dart
FxAurora(child: hero);                 // drifting blurred-blob backdrop
FxMeshGradient(child: hero);           // living mesh-gradient wash
FxPlasma(child: hero);                 // turbulent plasma field
FxStarField(child: launchScreen);      // warp-speed stars
FxSnow(child: hero);                   // falling particles
FxRain(child: scene);                  // slanted rain streaks
FxBubbles(child: panel);               // rising bubbles
FxParticles(child: hero);              // ambient drifting dots
FxFireworks(child: congratsScreen);    // celebratory bursts
FxBlob(color: Colors.purple, child: icon); // organic morphing shape
FxDotGrid(child: dashboard);           // rippling dot backdrop
FxSpotlight(child: darkPanel);         // drifting light (or followPointer)
FxKenBurns(child: Image.asset('hero.jpg', fit: BoxFit.cover)); // cinematic zoom/pan

final confetti = FxConfettiController();
FxConfetti(controller: confetti, child: myButton);   // confetti.play() to fire
```

</details>

<details>
<summary><b>✨ Visual FX, text & misc</b></summary>

```dart
FxNeonText('OPEN', color: Colors.pink);        // glowing flicker sign
FxCircularText('• NOW OPEN ');                 // rotating text ring
FxRotatingWords(words: const ['Build', 'Ship', 'Scale']);
FxTypeLoop(phrases: const ['fast.', 'fluid.', 'fun.']);
FxFlipClock(value: '12:45');                   // split-flap digits
FxColorCycle(colors: palette, builder: (ctx, c) => Text('Hi', style: TextStyle(color: c)));
FxGlitch(child: Text('SYSTEM'));               // RGB-split glitch
FxShine(child: myButton);                      // gloss sweep
FxBorderBeam(child: card);                     // comet beam around the border
FxGradientBorder(child: card);                 // rotating gradient outline ("AI glow")
FxMorphIcon(isOpen: open, onTap: toggle);      // hamburger ↔ close morph
FxRipple(color: Colors.blue, child: card);     // colorable tap ripples
FxRippleGrid(color: Colors.indigo);            // tap sends a wavefront across a dot grid
FxWaveDivider(color: Colors.blue);             // animated wavy separator
FxSpinWheel(items: prizes, colors: palette, controller: wheel, onResult: award);
FxAvatarStack(avatars: photos);                // spread on hover
FxParallaxLayers(layers: [FxParallaxLayer(child: bg, depth: 0.3)]); // pointer-tilt depth
FxAnimatedCheck(color: Colors.green);          // draw-on success tick
FxPulse(color: Colors.red, child: liveDot);    // sonar attention halo
icon.badge(unreadCount);                       // pops when count changes
FxMarquee(child: Text('Breaking news • ' * 4));
FxToast(visible: show, child: Text('Saved'));  // declarative slide-and-fade toast
FxAnimatedGradient(colors: const [Color(0xFF6A11CB), Color(0xFF2575FC)], child: hero);
card.tilt();                                   // pointer-driven 3D tilt
```

</details>

**Exit / dismiss animations.** Effects normally play on mount. To animate a widget **out** before it leaves the tree, use `FxAnimatedVisibility` — it plays your entrance chain in reverse on dismiss and only removes the child once the exit finishes:

```dart
FxAnimatedVisibility(
  visible: _show,
  effects: (a) => a.fade().scale(begin: 0.9).slideY(-0.2),
  onDismissed: () => print('gone'),
  child: const Card(child: Text('I animate out before I leave')),
);

// or the extension form:
card.animatedVisibility(visible: _show, effects: (a) => a.fadeIn());
```

**Content swap.** Animate between children when the (keyed) child changes:

```dart
FxSwitcher(
  effect: FxSwitcherEffect.scaleFade,
  child: loading
      ? const CircularProgressIndicator(key: ValueKey('load'))
      : Text(data, key: ValueKey(data)),
);
```

## 🎬 Built-in Effects

**Transform / visual:** `fade` · `fadeOut` · `moveX/Y/move` · `slideX/Y` · `scale` · `rotate` · `skew` · `flipX/Y` · `blur` · `tint`

**Attention seekers:** `shake` · `bounce` · `pulse` · `flash` · `blink` · `wobble` · `swing` · `heartbeat` · `jelly` · `rubberBand` · `tada` · `float` · `glow`

**Reveal & clip:** `circularReveal` · `wipe` (any `AxisDirection`) · `curtain`

**Loading:** `shimmer` (gradient sweep) · `sheen` (diagonal specular streak) · `breathe`

**Color & filter:** `saturate` / `grayscale` · `brightness` · `hueShift`

**Entrances (one-shots):** `fadeIn` · `scaleIn/Out` · `zoom` · `pop` (overshoot) · `elastic` · `rollIn` · `hinge` · `jackInTheBox` · `lightSpeedIn/Out` · `rotateIn` · `slideFrom{Top,Bottom,Left,Right}`

**Presets:** `success` · `error` · `warning` · `loading` · `attention` · `heroEntry/Exit` · `dialog` · `tooltip` · `toast` · `snackbar` · `cardEntry` · `listItem` · `pageTransition` · `modal` · `popup` · `emptyState` · `onboarding` · `fab` · `notification`

```dart
title.tada();                       // celebrate
field.error();                      // shake on invalid input
spinner.loading();                  // continuous spinner
badge.animate().glow().looping();   // pulsing glow
avatar.animate().float().looping(); // gentle bob
liveDot.animate().blink().looping();// on/off blink (e.g. a LIVE indicator)
```

## ♿ Accessibility

Motion is opt-out-able and controls are operable without a pointer.

- **Reduced motion.** The engine and *every* looping widget check `MediaQuery.disableAnimations`. Under the OS "reduce motion" setting, one-shot effects jump to their end frame and continuous animations settle to a static frame — reacting to runtime toggles, not just at mount. Set `FxTheme(respectReducedMotion: true)` (the default) to opt in globally, or `FxReducedMotionBehavior` to choose *jump-to-end* vs *disable*.
- **Semantics.** Interactive widgets expose the right roles and state — buttons, `selected` tabs/nav items, `checked` checkboxes/radios, `slider` values with increase/decrease actions, and live-region announcements for countdowns and progress.
- **Haptics.** Toggles, sliders, ratings, steppers and confirm actions fire `HapticFeedback` on interaction.

> [!TIP]
> Building your own looping widget? Mix in `FxMotionAware` and override `onReduceMotionChanged(bool)` to start/stop your controller — the same helper the built-ins use.

## 💡 Tips & Best Practices

1. **Chain, don't nest.** Prefer `widget.animate().fade().scale()` over stacking `FadeTransition`/`ScaleTransition` — one controller, one repaint boundary.
2. **`.then()` sequences; bare effects run in parallel.** Reach for `.then(delay)` only when you actually need a barrier.
3. **Per-effect timing is last-effect.** `.duration()` / `.delay()` / `.curve()` bind to the most recently added effect — call them right after the effect you mean.
4. **Set global defaults with `FxTheme`** rather than repeating `.duration()` / `.curve()` everywhere.
5. **Loop with `.looping()`** for ambient motion (`glow`, `float`, `shimmer`, `sheen`) — and trust reduced-motion to pause it.
6. **Pass a `seed`** to particle backdrops (`FxRain`, `FxSnow`, `FxParticles`, …) for reproducible layouts in golden tests.
7. **Hold an `FxController`** for imperative replay; disposing it is a safe no-op.

## 🩹 Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `.duration()` seems to affect the wrong effect | Timing binds to the **last** added effect | Call `.duration()` immediately after the intended effect, or set it on the `FxEffect` |
| A widget animates on every rebuild | `.animate()` rebuilds a fresh chain each build | Drive it with an `FxController` + `autoPlay: false`, or gate with a trigger like `.onVisible()` |
| Nothing animates | OS "reduce motion" is on | Expected — effects jump to end. Override via `FxTheme(respectReducedMotion: false)` if truly needed |
| Blur/glass looks heavy while scrolling | `BackdropFilter` re-rasterizes | It's isolated in a `RepaintBoundary`; keep the blurred region small |
| Backdrop widget shows nothing | It fills its parent's box | Give it a bounded parent (`SizedBox`/`ClipRRect` with a height) |

## 🐞 Debug Tools

Development-only overlays — in release builds they return the child untouched (**zero** overhead):

```dart
myPage.showFPS();            // live FPS + frame ms
myWidget.showBounds();       // draw bounds + size
list.showTimeline();         // rolling frame-duration bars
scaffold.showControllers();  // count of active .animate() controllers
scaffold.showPerformance();  // all of the above
```

## 🗺️ Roadmap

Triggers, gesture animations, presets, physics/springs, page transitions, Hero, and the debug HUD have all shipped. Planned next:

- [x] Fluent effect engine, timelines & staggered lists
- [x] Triggers, gestures & presets
- [x] Physics/springs, page transitions & Hero
- [x] 110+ ready-made widgets
- [x] Reduced-motion & semantics across the library
- [ ] RTL-aware directional effects
- [ ] Web keyboard shortcuts for interactive widgets
- [ ] More shader-based effects

See [`ROADMAP.md`](ROADMAP.md) for detail.

## 🛠️ Development

```bash
flutter test                       # everything (incl. golden images)
flutter test --exclude-tags golden # fast, portable suite (what CI runs)
flutter test --update-goldens --tags golden  # regenerate goldens
dart format . && flutter analyze
```

Golden tests pump the controller to **deterministic `t` values** (never a live mid-flight frame) and are tagged `golden`. Because golden rendering varies by platform, CI runs the portable suite and goldens are verified locally. CI (analyze + format + test on every push/PR) is defined in [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

A full demo lives in [`example/`](example/lib/main.dart):

```bash
cd example && flutter run
```

## 🤝 Contributing

Contributions are welcome! Open an [issue](https://github.com/your-org/save_points_animations/issues) to discuss a change, or send a [pull request](https://github.com/your-org/save_points_animations/pulls). Run `dart format . && flutter analyze && flutter test --exclude-tags golden` before submitting.

## 📄 License

<!-- TODO: The LICENSE file currently contains a placeholder. Add a real license and name it here (e.g. "MIT"). -->

See [LICENSE](LICENSE).

<div align="center">

Made with ❤️ for the Flutter community.

**⭐ Star this repo if it helped you.**

</div>
