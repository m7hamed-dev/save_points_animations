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
- **Modern motion by default.** Effects and transitions ease with Material 3
  **emphasized** curves out of the box (`FxCurves.emphasized` /
  `emphasizedDecelerate` / `emphasizedAccelerate`) — override any time.
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

### Triggers — play on an event

Turn any chain into an event-driven animation:

```dart
badge.animate().tada().onTap();          // replay on tap
menu.animate().fadeIn().onHover();       // replay on hover
card.animate().fadeIn().slideX(0.1).onVisible();  // play when scrolled into view
```

Available: `onTap` · `onDoubleTap` · `onLongPress` · `onHover` · `onAppear` ·
`onVisible` / `animateOnVisible`.

### Scroll-driven animations

Animate as content scrolls into view, or add depth with parallax:

```dart
// Effects driven by scroll position (not time):
card.animateOnScroll(const [FadeEffect(), SlideEffect(beginY: 0.2)]);

// Parallax — moves as the user scrolls:
banner.parallax(amount: 40);
```

### Gestures — continuous, state-driven feedback

```dart
button.pressScale();     // dips while pressed, springs back
button.pressBounce();    // dips then elastic overshoot on release
card.hoverScale();       // grows while hovered (desktop/web)
```

### Physics — real spring simulations

`.spring()` drives the previous effect with a `SpringSimulation` and sets the
physically-correct settle duration for you:

```dart
icon.animate().scale(begin: 0.5).spring(stiffness: 300, damping: 15, mass: 1);
box.animate().moveY(-120).gravity();          // constant-acceleration fall
chip.animate().moveX(200).friction();         // flick that decelerates
```

Or use the curves directly anywhere a `Curve` is accepted:

```dart
widget.animate().scale(begin: 0).curve(FxPhysics.spring(stiffness: 260));
```

### Page transitions & Hero

Push routes with a built-in transition, or use `FxPageRoute` directly:

```dart
context.fxPush(DetailPage(), transition: FxPageTransition.sharedAxisHorizontal);

Navigator.of(context).push(
  FxPageRoute(builder: (_) => DetailPage(), transition: FxPageTransition.zoom),
);
```

Transitions: `fade` · `scale` · `zoom` · `slide` (any `AxisDirection`) ·
`rotation` · `sharedAxisHorizontal` · `sharedAxisVertical` — plus the modern
set: `fadeThrough` (Material 3) · `cupertino` (iOS parallax) · `depth` ·
`sheet` (modal) · `circularReveal` · `cube3D` · `blur` · `containerTransform` ·
`glass`.

Reveal from a tap point, expand from a card's bounds, or spring in:

```dart
context.fxPushReveal(DetailPage(), alignment: Alignment.topRight);

final box = key.currentContext!.findRenderObject() as RenderBox;
context.fxPushFrom(DetailPage(), box.localToGlobal(Offset.zero) & box.size);

// Physically spring-driven — the spring's settle time IS the duration:
context.fxPushSpring(DetailPage(), stiffness: 220, damping: 18);
```

Hero flights (with an optional curved-arc path):

```dart
Image.asset('a.png').heroAnimate('photo');   // same tag on both screens
```

### Rotating words, flip clock & color cycle

```dart
FxRotatingWords(words: const ['Build', 'Ship', 'Scale']); // word carousel

FxFlipClock(value: '12:45');                              // split-flap digits

FxColorCycle(colors: palette, builder: (ctx, c) => Text('Hi', style: TextStyle(color: c)));
```

### Slide to confirm, progress button & swipe deck

```dart
FxSlideToConfirm(label: const Text('Slide to pay'), onConfirmed: pay);

FxProgressButton(state: _state, onPressed: submit, child: const Text('Submit'));

FxSwipeCards(cards: cards, onSwiped: (i, right) => …);  // Tinder-style deck
```

### Heart button, neon text & CTA

```dart
FxHeartButton(isLiked: liked, onChanged: (v) => …);    // like pop + burst

FxNeonText('OPEN', color: Colors.pink);                // glowing flicker sign

FxShimmerButton(onPressed: go, child: const Text('Go')); // sweeping-sheen CTA
```

### Step progress, toggle & countdown ring

```dart
FxStepProgress(count: 4, currentStep: step);           // animated step dots

FxAnimatedToggle(value: on, onChanged: (v) => …);      // custom switch

FxCircularCountdown(duration: 10.seconds);             // depleting ring timer
```

### Morph icon, ripple & wave divider

```dart
FxMorphIcon(isOpen: open, onTap: toggle);   // hamburger ↔ close morph

FxRipple(color: Colors.blue, child: card);  // colorable tap ripples

FxWaveDivider(color: Colors.blue);          // animated wavy separator
```

### Aurora, radar & blob

```dart
FxAurora(child: hero);                 // drifting blurred-blob backdrop

FxRadar(size: 160, color: Colors.green); // sweeping scan

FxBlob(color: Colors.purple, child: icon); // organic morphing shape
```

### Ken Burns, glitch & shine

```dart
FxKenBurns(child: Image.asset('hero.jpg', fit: BoxFit.cover)); // cinematic zoom/pan

FxGlitch(child: Text('SYSTEM'));                               // RGB-split glitch

FxShine(child: myButton);                                      // gloss sweep
```

### Odometer, segmented control & particles

```dart
FxOdometer(value: score);                                // rolling-digit counter

FxSegmentedControl(segments: const ['Day', 'Week'],      // sliding-pill selector
    selectedIndex: i, onChanged: (v) => setState(() => i = v));

FxParticles(child: hero);                                // ambient drifting dots
```

### Gradient border, wave fill & typing dots

```dart
FxGradientBorder(child: card);                 // rotating gradient outline ("AI glow")

FxWaveProgress(value: 0.65, child: Text('65%')); // liquid water-fill indicator

const FxTypingIndicator();                       // chat "typing…" bubble
```

### Flip card, speed dial & success check

```dart
FxFlipCard(front: cardFront, back: cardBack);            // 3D flip on tap

FxSpeedDial(icon: const Icon(Icons.add), children: [...]); // expanding FAB menu

FxAnimatedCheck(color: Colors.green);                    // draw-on success tick
```

### Rating, expandable & progress

```dart
FxRating(value: stars, onChanged: (v) => setState(() => stars = v));

FxExpandable(header: Text('Details'), body: bodyWidget);   // animated accordion

FxProgressBar(value: 0.6);   // animates on change · omit value for indeterminate
```

### Badges, pulses & page dots

```dart
icon.badge(unreadCount);                                 // pops when count changes

FxPulse(color: Colors.red, child: liveDot);              // sonar attention halo

FxPageIndicator(controller: pageController, count: 4);   // animated worm dots
```

### Marquee, swipe-to-dismiss & countdown

```dart
FxMarquee(child: Text('Breaking news • ' * 4));          // scrolling ticker

FxSwipeToDismiss(onDismissed: remove, child: card);      // swipe away, spring back

FxCountdown(duration: 30.seconds, onComplete: launch);   // animated countdown
```

### Content swap, skeletons & animated backgrounds

```dart
// Animate between children when the (keyed) child changes:
FxSwitcher(
  effect: FxSwitcherEffect.scaleFade,
  child: loading
      ? const CircularProgressIndicator(key: ValueKey('load'))
      : Text(data, key: ValueKey(data)),
);

// Shimmer loading placeholders:
FxSkeleton.circle(size: 48);
const FxSkeleton(width: 200);

// A living animated gradient backdrop:
FxAnimatedGradient(colors: const [Color(0xFF6A11CB), Color(0xFF2575FC)], child: hero);
```

### Exit / dismiss animations

Effects normally play on mount. To animate a widget **out** before it leaves the
tree, use `FxAnimatedVisibility` — it plays your entrance chain in reverse on
dismiss and only removes the child once the exit finishes:

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

Resolution order for any parameter: **explicit argument → nearest `FxTheme` →
package default.** Omit `curve`/`duration` on `context.fxPush` and they inherit
`transitionCurve`/`transitionDuration` from the theme.

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

**Transform / visual:** `fade` · `fadeOut` · `moveX/Y/move` · `slideX/Y` ·
`scale` · `rotate` · `skew` · `flipX/Y` · `blur` · `tint`

**Attention seekers:** `shake` · `bounce` · `pulse` · `flash` · `wobble` ·
`swing` · `heartbeat` · `jelly` · `rubberBand` · `tada` · `float` · `glow`

**Reveal & clip:** `circularReveal` · `wipe` (any `AxisDirection`) · `curtain`

**Loading:** `shimmer` (gradient sweep) · `breathe` · plus widgets
`FxDotsLoader` · `FxBarsLoader` · `FxProgressRing`

**Color & filter:** `saturate` / `grayscale` · `brightness` · `hueShift`

**Entrances (one-shots):** `fadeIn` · `scaleIn/Out` · `zoom` · `elastic` ·
`rollIn` · `hinge` · `jackInTheBox` · `lightSpeedIn/Out` · `rotateIn` ·
`slideFrom{Top,Bottom,Left,Right}`

**Presets:** `success` · `error` · `warning` · `loading` · `attention` ·
`heroEntry/Exit` · `dialog` · `tooltip` · `toast` · `snackbar` · `cardEntry` ·
`listItem` · `pageTransition` · `modal` · `popup` · `emptyState` · `onboarding` ·
`fab` · `notification`

```dart
title.tada();                       // celebrate
field.error();                      // shake on invalid input
spinner.loading();                  // continuous spinner
badge.animate().glow().looping();   // pulsing glow
avatar.animate().float().looping(); // gentle bob
```

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

## Text animations

```dart
'Typing…'.typewriter(cursor: '|');       // character-by-character reveal
'Staggered'.animateChars();              // per-character stagger in
(12840).countUp(duration: 1.seconds);    // animated number ticker
'Gradient'.gradientText();               // animated gradient headline
'wavy ~'.wavyText();                     // rippling wave
'DECODING'.scrambleText();               // scramble-in reveal
'word by word'.wordsFadeIn();            // staggered word fade
```

## Confetti & 3D tilt

```dart
final confetti = FxConfettiController();
FxConfetti(controller: confetti, child: myButton);   // confetti.play() to fire
card.tilt();                                          // pointer-driven 3D tilt
```

## Debug tools

Development-only overlays — in release builds they return the child untouched
(**zero** overhead):

```dart
myPage.showFPS();            // live FPS + frame ms
myWidget.showBounds();       // draw bounds + size
list.showTimeline();         // rolling frame-duration bars
scaffold.showControllers();  // count of active .animate() controllers
scaffold.showPerformance();  // all of the above
```

## Development

```bash
flutter test                       # everything (incl. golden images)
flutter test --exclude-tags golden # fast, portable suite (what CI runs)
flutter test --update-goldens --tags golden  # regenerate goldens
dart format . && flutter analyze
```

Golden tests pump the controller to **deterministic `t` values** (never a live
mid-flight frame) and are tagged `golden`. Because golden rendering varies by
platform, CI runs the portable suite and goldens are verified locally. CI
(analyze + format + test on every push/PR) is defined in
[`.github/workflows/ci.yml`](.github/workflows/ci.yml).

## License

See [LICENSE](LICENSE).
