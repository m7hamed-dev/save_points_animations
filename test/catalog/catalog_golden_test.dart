@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

import 'catalog_harness.dart';

// One golden per exported widget from `lib/src/widgets/`, grouped by category.
//
// Determinism rules:
//  * The view is pinned to a 480x480 logical surface at devicePixelRatio 1, so
//    each image is exactly the stage size in pixels (small PNGs).
//  * Every widget is staged in a keyed `RepaintBoundary` with a plain, opaque
//    background (see [_stage]) inside [catalogHost] — fixed `MediaQuery`,
//    `Directionality.ltr` and the default test font.
//  * Time only advances through the fake test clock, in fixed 50ms frames, so
//    continuously animating widgets always capture the same frame.
//  * Particle systems are given an explicit `seed`.
//
// Regenerate with:
//   flutter test --update-goldens test/catalog/catalog_golden_test.dart

const Size _kStage = Size(240, 160);
const Size _kWideStage = Size(320, 120);
const Duration _kRun = Duration(milliseconds: 1200);
const Duration _kFrame = Duration(milliseconds: 50);
const Key _kBoundary = ValueKey('catalog-golden-boundary');

// Goldens that would only bake in a known rendering bug are skipped; each bug
// has a matching (skipped) behavior test in catalog_interaction_test.dart.
// Un-skip and regenerate once the widget is fixed.
const _kFireworksBug =
    'BUG FxFireworks: bursts never expand. The painter receives `now` at build '
    'time, but `_tick` only bumps the `_frame` repaint notifier (no rebuild), '
    'so every repaint sees now == 0 and each burst is drawn as one static dot '
    'at its origin until it expires.';
const _kRippleBug =
    'BUG FxRipple: the ripple is never visible. The painter receives '
    '`elapsed` at build time and ticks only bump `_frame` (no rebuild), so '
    'progress stays 0 and every ripple is drawn with radius 0.';
const _kRippleGridBug =
    'BUG FxRippleGrid: tapping never starts a ripple. `_tap` sets `_center` / '
    '`_maxRadius` without setState, so the painter keeps `center == null` '
    '(energy 0) and only the idle grid is ever painted.';
const _kScrollProgressBug =
    'BUG FxScrollProgress: the progress fill is invisible. The fill is a '
    'child-less ColoredBox inside Align > FractionallySizedBox; Align loosens '
    'the height constraint, so the fill lays out 0px tall at any scroll offset.';

/// Every widget class that has a golden registered below; checked against the
/// library's exports by the "covers every exported widget" test.
final Set<String> _covered = <String>{};

/// `FxAnimatedSlider` -> `fx_animated_slider`.
String _snake(String name) => name
    .replaceAllMapped(RegExp('(?<=[a-z0-9])([A-Z])'), (m) => '_${m.group(1)}')
    .toLowerCase();

Widget _stage(Widget child, {required Size size, required Color background}) {
  return catalogHost(
    RepaintBoundary(
      key: _kBoundary,
      child: SizedBox.fromSize(
        size: size,
        child: ColoredBox(
          color: background,
          child: Center(child: child),
        ),
      ),
    ),
    background: const Color(0xFF808080),
  );
}

/// Pumps [child] on a fixed stage, advances the fake clock by [run] in fixed
/// frames and compares the stage against `goldens/<file>.png`.
Future<void> _capture(
  WidgetTester tester, {
  required String file,
  required Widget child,
  Size size = _kStage,
  Color background = kCatalogLight,
  Duration run = _kRun,
  Future<void> Function()? prepare,
  Future<void> Function()? cleanup,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(480, 480);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_stage(child, size: size, background: background));
  if (prepare != null) await prepare();
  for (var t = Duration.zero; t < run; t += _kFrame) {
    await tester.pump(_kFrame);
  }
  await expectLater(
    find.byKey(_kBoundary),
    matchesGoldenFile('goldens/$file.png'),
  );
  if (cleanup != null) await cleanup();
  // Unmount so repeating tickers / periodic timers are disposed in-test.
  await tester.pumpWidget(const SizedBox());
  expect(tester.takeException(), isNull);
}

/// Registers a golden for [name] (the widget class) under [category].
///
/// Goldens are pixel tests, so they run with the semantics tree disabled;
/// semantics are covered by `catalog_a11y_test.dart`.
void _golden(
  String category,
  String name,
  Widget Function() build, {
  Size size = _kStage,
  Color background = kCatalogLight,
  Duration run = _kRun,
  String? skip,
}) {
  _covered.add(name);
  catalogTestWidgets(
    name,
    (tester) => _capture(
      tester,
      file: '$category/${_snake(name)}',
      child: build(),
      size: size,
      background: background,
      run: run,
    ),
    skip: skip,
    semanticsEnabled: false,
  );
}

/// Registers a golden whose body needs the tester (controllers, gestures …).
void _goldenWith(
  String category,
  String name,
  Future<void> Function(WidgetTester tester, String file) body, {
  String? skip,
}) {
  _covered.add(name);
  catalogTestWidgets(
    name,
    (tester) => body(tester, '$category/${_snake(name)}'),
    skip: skip,
    semanticsEnabled: false,
  );
}

const _blue = Color(0xFF448AFF);
const _purple = Color(0xFF6A11CB);
const _pink = Color(0xFFEC008C);
const _teal = Color(0xFF00C9A7);
const _amber = Color(0xFFFFC107);
const _palette = [_purple, _blue, _pink, _teal];

void _noop() {}

void main() {
  group('controls', () {
    const c = 'controls';
    _golden(
      c,
      'FxAnimatedCheckbox',
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FxAnimatedCheckbox(value: true, onChanged: (_) {}),
          const SizedBox(width: 16),
          FxAnimatedCheckbox(value: false, onChanged: (_) {}),
          const SizedBox(width: 16),
          const FxAnimatedCheckbox(value: true, onChanged: null),
        ],
      ),
    );
    _golden(
      c,
      'FxAnimatedRadio',
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FxAnimatedRadio<int>(value: 1, groupValue: 1, onChanged: (_) {}),
          const SizedBox(width: 16),
          FxAnimatedRadio<int>(value: 2, groupValue: 1, onChanged: (_) {}),
          const SizedBox(width: 16),
          const FxAnimatedRadio<int>(value: 3, groupValue: 3, onChanged: null),
        ],
      ),
    );
    _golden(
      c,
      'FxAnimatedToggle',
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FxAnimatedToggle(value: true, onChanged: (_) {}),
          const SizedBox(width: 16),
          FxAnimatedToggle(value: false, onChanged: (_) {}),
        ],
      ),
    );
    _golden(
      c,
      'FxThemeToggle',
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FxThemeToggle(isDark: false, onChanged: (_) {}),
          const SizedBox(width: 16),
          FxThemeToggle(isDark: true, onChanged: (_) {}),
        ],
      ),
    );
    _golden(
      c,
      'FxAnimatedSlider',
      () => SizedBox(
        width: 200,
        child: FxAnimatedSlider(value: 0.4, onChanged: (_) {}),
      ),
    );
    _golden(
      c,
      'FxRangeSlider',
      () => SizedBox(
        width: 200,
        child: FxRangeSlider(
          values: const FxRange(0.2, 0.7),
          onChanged: (_) {},
        ),
      ),
    );
    _golden(
      c,
      'FxSegmentedControl',
      () => SizedBox(
        width: 220,
        child: FxSegmentedControl(
          segments: const ['Day', 'Week', 'Month'],
          selectedIndex: 1,
          onChanged: (_) {},
        ),
      ),
    );
    _golden(c, 'FxStepper', () => FxStepper(value: 3, onChanged: (_) {}));
    _golden(c, 'FxRating', () => FxRating(value: 3, onChanged: (_) {}));
    _golden(
      c,
      'FxNumberPad',
      () => FxNumberPad(onDigit: (_) {}, onBackspace: _noop),
      size: const Size(260, 330),
    );
    _golden(
      c,
      'FxColorWheel',
      () => FxColorWheel(color: _blue, onChanged: (_) {}, size: 140),
    );
    _golden(
      c,
      'FxWheelPicker',
      () => SizedBox(
        width: 160,
        child: FxWheelPicker(
          items: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
          selectedIndex: 2,
          onChanged: (_) {},
          height: 140,
        ),
      ),
    );
    _golden(
      c,
      'FxDateStrip',
      () => FxDateStrip(
        days: [for (var d = 2; d <= 8; d++) DateTime(2026, 3, d)],
        selected: DateTime(2026, 3, 4),
        onChanged: (_) {},
      ),
      size: _kWideStage,
    );
    _golden(
      c,
      'FxTagChips',
      () => FxTagChips(
        tags: const ['Flutter', 'Dart', 'Motion'],
        selected: const {1},
        onToggle: (_) {},
      ),
    );
    _golden(
      c,
      'FxReactionBar',
      () => FxReactionBar(
        reactions: const ['A', 'B', 'C', 'D'],
        labels: const ['Like', 'Love', 'Haha', 'Wow'],
        selected: 1,
        onChanged: (_) {},
      ),
      size: _kWideStage,
    );
    _golden(
      c,
      'FxHeartButton',
      () => FxHeartButton(isLiked: true, onChanged: (_) {}),
    );
    _goldenWith(c, 'FxHoldButton', (tester, file) async {
      TestGesture? hold;
      await _capture(
        tester,
        file: file,
        child: const FxHoldButton(onConfirmed: _noop, child: CatalogGlyph()),
        // Capture with the ring ~half full (holdDuration is 1200ms).
        run: const Duration(milliseconds: 600),
        prepare: () async {
          hold = await tester.startGesture(
            tester.getCenter(find.byType(FxHoldButton)),
          );
        },
        cleanup: () async => hold?.up(),
      );
    });
    _golden(
      c,
      'FxSlideToConfirm',
      () => const SizedBox(
        width: 220,
        child: FxSlideToConfirm(
          label: Text('Slide to pay'),
          onConfirmed: _noop,
        ),
      ),
    );
    _goldenWith(c, 'FxFloatingField', (tester, file) async {
      final controller = TextEditingController(text: 'ada@example.com');
      addTearDown(controller.dispose);
      await _capture(
        tester,
        file: file,
        child: SizedBox(
          width: 200,
          child: FxFloatingField(label: 'Email', controller: controller),
        ),
      );
    });
    _golden(c, 'FxMorphIcon', () => const FxMorphIcon(isOpen: true, size: 40));
    _golden(
      c,
      'FxExpandable',
      () => const SizedBox(
        width: 200,
        child: FxExpandable(
          header: Text('Details'),
          body: Text('Expanded body text'),
          initiallyExpanded: true,
        ),
      ),
    );
  });

  group('buttons', () {
    const c = 'buttons';
    _golden(
      c,
      'FxGlowButton',
      () => const FxGlowButton(onPressed: _noop, child: Text('Glow')),
    );
    _golden(
      c,
      'FxGradientButton',
      () => const FxGradientButton(onPressed: _noop, child: Text('Gradient')),
    );
    _golden(
      c,
      'FxJellyButton',
      () => const FxJellyButton(onPressed: _noop, child: Text('Jelly')),
    );
    _golden(
      c,
      'FxShimmerButton',
      () => const FxShimmerButton(onPressed: _noop, child: Text('Shimmer')),
    );
    _golden(
      c,
      'FxMagneticButton',
      () => FxMagneticButton(
        onTap: _noop,
        child: catalogSwatch(
          _purple,
          width: 120,
          height: 44,
          child: const Text(
            'Magnet',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
        ),
      ),
    );
    _golden(
      c,
      'FxProgressButton',
      () => const SizedBox(
        width: 200,
        child: FxProgressButton(
          state: FxButtonState.idle,
          onPressed: _noop,
          child: Text('Submit', style: TextStyle(color: Color(0xFFFFFFFF))),
        ),
      ),
    );
  });

  group('navigation', () {
    const c = 'navigation';
    _golden(
      c,
      'FxAnimatedNavBar',
      () => FxAnimatedNavBar(
        items: [for (final i in catalogNavItems()) i.icon],
        currentIndex: 1,
        onTap: (_) {},
      ),
      size: _kWideStage,
    );
    _golden(
      c,
      'FxCurvedNavBar',
      () => FxCurvedNavBar(
        items: catalogNavItems(),
        currentIndex: 1,
        onTap: (_) {},
      ),
      size: _kWideStage,
      background: const Color(0xFFE8EEF8),
    );
    _golden(
      c,
      'FxDotNavBar',
      () =>
          FxDotNavBar(items: catalogNavItems(), currentIndex: 2, onTap: (_) {}),
      size: _kWideStage,
    );
    _golden(
      c,
      'FxFrostedNavBar',
      () => Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              for (final color in _palette)
                Expanded(child: ColoredBox(color: color)),
            ],
          ),
          FxFrostedNavBar(
            items: catalogNavItems(),
            currentIndex: 1,
            onTap: (_) {},
          ),
        ],
      ),
      size: _kWideStage,
    );
    _golden(
      c,
      'FxGooeyNavBar',
      () => FxGooeyNavBar(
        items: catalogNavItems(),
        currentIndex: 1,
        onTap: (_) {},
      ),
      size: _kWideStage,
    );
    _golden(
      c,
      'FxPillNavBar',
      () => FxPillNavBar(
        items: catalogNavItems(),
        currentIndex: 0,
        onTap: (_) {},
      ),
      size: _kWideStage,
    );
    _golden(
      c,
      'FxAnimatedTabBar',
      () => SizedBox(
        width: 240,
        child: FxAnimatedTabBar(
          tabs: const ['One', 'Two', 'Three'],
          selectedIndex: 1,
          onChanged: (_) {},
        ),
      ),
    );
    _golden(
      c,
      'FxStepProgress',
      () => const FxStepProgress(count: 4, currentStep: 1),
    );
    _golden(
      c,
      'FxWizardSteps',
      () => const SizedBox(
        width: 220,
        child: FxWizardSteps(steps: ['Cart', 'Pay', 'Done'], currentStep: 1),
      ),
    );
    _golden(c, 'FxPinDots', () => const FxPinDots(length: 4, filled: 2));
    _golden(c, 'FxCarouselDots', () => const FxCarouselDots(count: 4, page: 1));
    _goldenWith(c, 'FxPageIndicator', (tester, file) async {
      final controller = PageController(initialPage: 1);
      addTearDown(controller.dispose);
      await _capture(
        tester,
        file: file,
        child: FxPageIndicator(controller: controller, count: 4),
      );
    });
    _golden(
      c,
      'FxCarousel',
      () => FxCarousel(
        height: 120,
        children: [
          for (final color in _palette) catalogSwatch(color, height: 100),
        ],
      ),
    );
    _golden(
      c,
      'FxTimeline',
      () => const FxTimeline(
        items: [Text('Ordered'), Text('Shipped'), Text('Delivered')],
      ),
    );
    _goldenWith(c, 'FxCircularMenu', (tester, file) async {
      await _capture(
        tester,
        file: file,
        child: Align(
          alignment: const Alignment(0.6, 0.6),
          child: FxCircularMenu(
            radius: 70,
            icon: const CatalogGlyph(),
            children: [
              for (final color in [_pink, _teal, _amber])
                catalogSwatch(color, width: 32, height: 32, radius: 16),
            ],
          ),
        ),
        prepare: () async {
          await tester.tap(find.byType(CatalogGlyph));
        },
      );
    });
    _goldenWith(c, 'FxSpeedDial', (tester, file) async {
      await _capture(
        tester,
        file: file,
        size: const Size(160, 200),
        // Staged like a FAB (`Positioned` with unbounded width). Under bounded
        // loose width the actions mis-align — see the interaction test
        // "FxSpeedDial actions stack above the main button".
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: 16,
              bottom: 16,
              child: FxSpeedDial(
                size: 44,
                icon: const CatalogGlyph(),
                children: [
                  for (final color in [_pink, _teal])
                    catalogSwatch(color, width: 32, height: 32, radius: 16),
                ],
              ),
            ),
          ],
        ),
        prepare: () async {
          await tester.tap(find.byType(CatalogGlyph).last);
        },
      );
    });
    _goldenWith(c, 'FxScrollToTop', (tester, file) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await _capture(
        tester,
        file: file,
        child: Stack(
          children: [
            ListView(
              controller: controller,
              children: [
                for (var i = 0; i < 30; i++)
                  SizedBox(height: 40, child: Text('Row $i')),
              ],
            ),
            FxScrollToTop(controller: controller, size: 40),
          ],
        ),
        prepare: () async {
          controller.jumpTo(400);
          await tester.pump();
        },
      );
    });
    _goldenWith(c, 'FxScrollProgress', skip: _kScrollProgressBug, (
      tester,
      file,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await _capture(
        tester,
        file: file,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  for (var i = 0; i < 30; i++)
                    SizedBox(height: 40, child: Text('Row $i')),
                ],
              ),
            ),
            // Built after the list so the controller already has a client.
            FxScrollProgress(controller: controller, height: 6),
          ],
        ),
        prepare: () async {
          controller.jumpTo(controller.position.maxScrollExtent / 2);
          await tester.pump();
        },
      );
    });
    _golden(
      c,
      'FxDraggableSheet',
      () => const FxDraggableSheet(
        initialSnap: 1,
        background: Color(0xFFF5F7FB),
        child: Center(child: Text('Sheet')),
      ),
      background: const Color(0xFF9FB3D1),
    );
  });

  group('feedback & loaders', () {
    const c = 'feedback';
    _golden(c, 'FxDotsLoader', () => const FxDotsLoader());
    _golden(c, 'FxBarsLoader', () => const FxBarsLoader());
    _golden(c, 'FxProgressRing', () => const FxProgressRing());
    _golden(c, 'FxOrbitLoader', () => const FxOrbitLoader());
    _golden(c, 'FxDnaLoader', () => const FxDnaLoader());
    _golden(c, 'FxWaveDots', () => const FxWaveDots());
    _golden(c, 'FxTypingIndicator', () => const FxTypingIndicator());
    _golden(c, 'FxBouncingBall', () => const FxBouncingBall());
    _golden(c, 'FxWaveform', () => const FxWaveform());
    _golden(
      c,
      'FxHeartbeatLine',
      () => const SizedBox(width: 200, height: 60, child: FxHeartbeatLine()),
    );
    _golden(
      c,
      'FxPulse',
      () => FxPulse(child: catalogSwatch(_blue, width: 20, height: 20)),
    );
    _golden(c, 'FxRadar', () => const FxRadar(size: 120));
    _golden(
      c,
      'FxLoadingOverlay',
      () => const Stack(
        fit: StackFit.expand,
        children: [
          Center(child: Text('Page content')),
          FxLoadingOverlay(visible: true, message: 'Saving'),
        ],
      ),
    );
    _golden(
      c,
      'FxSkeleton',
      () => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FxSkeleton.circle(size: 40),
          SizedBox(width: 12),
          FxSkeleton(width: 140),
        ],
      ),
    );
    _golden(
      c,
      'FxSkeletonText',
      () => const SizedBox(width: 200, child: FxSkeletonText()),
    );
    _golden(
      c,
      'FxProgressBar',
      () => const SizedBox(width: 200, child: FxProgressBar(value: 0.6)),
    );
    _golden(c, 'FxWaveProgress', () => const FxWaveProgress(value: 0.6));
    _golden(
      c,
      'FxCircularCountdown',
      () => const FxCircularCountdown(duration: Duration(seconds: 10)),
    );
    _golden(
      c,
      'FxCountdown',
      () => const FxCountdown(duration: Duration(seconds: 10)),
    );
    _golden(
      c,
      'FxToast',
      () => const FxToast(
        visible: true,
        icon: CatalogGlyph(),
        child: Text('Saved'),
      ),
    );
    _golden(c, 'FxAnimatedCheck', () => const FxAnimatedCheck());
    _golden(
      c,
      'FxBadge',
      () =>
          FxBadge(count: 7, child: catalogSwatch(_blue, width: 44, height: 44)),
    );
  });

  group('data display', () {
    const c = 'data';
    _golden(
      c,
      'FxBarChart',
      () => const SizedBox(
        width: 200,
        child: FxBarChart(values: [3, 7, 4, 9, 6]),
      ),
    );
    _golden(
      c,
      'FxPieChart',
      () => const FxPieChart(
        values: [3, 2, 1],
        colors: [_purple, _blue, _pink],
        size: 120,
      ),
    );
    _golden(
      c,
      'FxSparkline',
      () => const SizedBox(
        width: 200,
        child: FxSparkline(values: [2, 5, 3, 8, 6, 9, 4]),
      ),
    );
    _golden(c, 'FxGauge', () => const FxGauge(value: 0.7, size: 120));
    _golden(c, 'FxOdometer', () => const FxOdometer(value: 1234));
    _golden(
      c,
      'FxFlipClock',
      () => const FxFlipClock(value: '12:34'),
      size: _kWideStage,
    );
    _golden(
      c,
      'FxAvatarStack',
      () => FxAvatarStack(
        avatars: [
          for (final color in _palette)
            catalogSwatch(color, width: 40, height: 40, radius: 20),
        ],
      ),
    );
    _golden(
      c,
      'FxSpinWheel',
      () => const FxSpinWheel(
        items: ['A', 'B', 'C', 'D'],
        colors: _palette,
        size: 140,
      ),
    );
  });

  group('text', () {
    const c = 'text';
    _golden(
      c,
      'FxNeonText',
      () => const FxNeonText('NEON', style: TextStyle(fontSize: 28)),
      background: kCatalogDark,
    );
    _golden(
      c,
      'FxShinyText',
      () => const FxShinyText(
        'SHINY',
        style: TextStyle(fontSize: 28, color: _purple),
      ),
    );
    _golden(
      c,
      'FxCircularText',
      () => const FxCircularText('SAVE POINTS * ', radius: 56),
    );
    _golden(
      c,
      'FxRotatingWords',
      () => const FxRotatingWords(words: ['fast', 'fluent', 'fun']),
      run: const Duration(milliseconds: 2200),
    );
    _golden(
      c,
      'FxTypeLoop',
      () => const FxTypeLoop(phrases: ['Hello', 'World']),
    );
    _golden(
      c,
      'FxMarquee',
      () => const SizedBox(
        width: 200,
        child: FxMarquee(child: Text('Breaking news - animated catalog')),
      ),
    );
    _golden(
      c,
      'FxGlitch',
      () =>
          const FxGlitch(child: Text('GLITCH', style: TextStyle(fontSize: 28))),
    );
  });

  group('backgrounds', () {
    const c = 'backgrounds';
    Widget fill(Widget child) => SizedBox.expand(child: child);
    _golden(
      c,
      'FxAnimatedGradient',
      () => fill(const FxAnimatedGradient(colors: _palette)),
    );
    _golden(c, 'FxAurora', () => fill(const FxAurora()));
    _golden(c, 'FxMeshGradient', () => fill(const FxMeshGradient()));
    _golden(c, 'FxPlasma', () => fill(const FxPlasma(resolution: 20)));
    _golden(c, 'FxBlob', () => const FxBlob());
    _golden(c, 'FxDotGrid', () => fill(const FxDotGrid()));
    _goldenWith(c, 'FxRippleGrid', skip: _kRippleGridBug, (tester, file) async {
      await _capture(
        tester,
        file: file,
        child: fill(const FxRippleGrid()),
        run: const Duration(milliseconds: 400),
        prepare: () async {
          await tester.tap(find.byType(FxRippleGrid));
        },
      );
    });
    _golden(
      c,
      'FxWaveDivider',
      () => const SizedBox(width: 240, child: FxWaveDivider()),
    );
    _golden(
      c,
      'FxColorCycle',
      () => FxColorCycle(
        colors: _palette,
        builder: (context, color) =>
            catalogSwatch(color, width: 120, height: 80),
      ),
    );
    _golden(
      c,
      'FxBubbles',
      () => fill(const FxBubbles(seed: 7)),
      background: kCatalogDark,
    );
    _golden(
      c,
      'FxParticles',
      () => fill(const FxParticles(seed: 7, color: Color(0x99FFFFFF))),
      background: kCatalogDark,
    );
    _golden(
      c,
      'FxSnow',
      () => fill(const FxSnow(seed: 7)),
      background: kCatalogDark,
    );
    _golden(
      c,
      'FxRain',
      () => fill(const FxRain(seed: 7)),
      background: kCatalogDark,
    );
    _golden(
      c,
      'FxStarField',
      () => fill(const FxStarField(seed: 7)),
      background: kCatalogDark,
    );
    _golden(
      c,
      'FxFireworks',
      () => fill(const FxFireworks(seed: 7)),
      background: kCatalogDark,
      skip: _kFireworksBug,
    );
    _golden(
      c,
      'FxConfetti',
      () => fill(
        const FxConfetti(
          seed: 7,
          playOnStart: true,
          child: Center(child: Text('Congrats')),
        ),
      ),
      run: const Duration(milliseconds: 500),
    );
  });

  group('surfaces & effects', () {
    const c = 'effects';
    Widget card([Color color = _purple]) => catalogSwatch(
      color,
      width: 160,
      height: 90,
      child: const Text('Card', style: TextStyle(color: Color(0xFFFFFFFF))),
    );
    _golden(
      c,
      'FxBorderBeam',
      () => FxBorderBeam(child: card(const Color(0xFF1B2333))),
    );
    _golden(c, 'FxGradientBorder', () => FxGradientBorder(child: card()));
    _golden(
      c,
      'FxGlassCard',
      () => Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              catalogSwatch(_pink, width: 70, height: 70, radius: 35),
              catalogSwatch(_teal, width: 70, height: 70, radius: 35),
            ],
          ),
          const FxGlassCard(child: Text('Glass')),
        ],
      ),
      background: const Color(0xFF2B3A67),
    );
    _golden(c, 'FxShine', () => FxShine(child: card(_blue)));
    _golden(
      c,
      'FxSpotlight',
      () => FxSpotlight(child: card(const Color(0xFF1B2333))),
    );
    _golden(c, 'FxTiltGlareCard', () => FxTiltGlareCard(child: card()));
    _golden(
      c,
      'FxKenBurns',
      () => ClipRect(
        child: FxKenBurns(
          child: SizedBox(
            width: 200,
            height: 120,
            child: Row(
              children: [
                for (final color in _palette)
                  Expanded(child: ColoredBox(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
    _golden(
      c,
      'FxParallaxLayers',
      () => SizedBox(
        width: 200,
        height: 120,
        child: FxParallaxLayers(
          layers: [
            FxParallaxLayer(
              depth: 0.3,
              child: catalogSwatch(const Color(0xFFDDE6F5)),
            ),
            FxParallaxLayer(
              child: Center(child: catalogSwatch(_blue, width: 60, height: 60)),
            ),
          ],
        ),
      ),
    );
    _goldenWith(c, 'FxRipple', skip: _kRippleBug, (tester, file) async {
      await _capture(
        tester,
        file: file,
        child: FxRipple(onTap: _noop, child: card(_teal)),
        run: const Duration(milliseconds: 250),
        prepare: () async {
          await tester.tap(find.byType(FxRipple));
        },
      );
    });
    _golden(
      c,
      'FxSwitcher',
      () => const FxSwitcher(child: Text('Switched', key: ValueKey('a'))),
    );
    _golden(
      c,
      'FxAnimatedVisibility',
      () => FxAnimatedVisibility(
        visible: true,
        effects: (a) => a.fadeIn().scaleIn(begin: 0.9),
        child: card(_blue),
      ),
    );
    _golden(
      c,
      'FxFlipCard',
      () => FxFlipCard(front: card(), back: card(_pink)),
    );
    _golden(
      c,
      'FxSwipeCards',
      () => SizedBox(
        width: 180,
        height: 120,
        child: FxSwipeCards(cards: [for (final color in _palette) card(color)]),
      ),
    );
    _golden(c, 'FxSwipeToDismiss', () => FxSwipeToDismiss(child: card(_teal)));
    _golden(
      c,
      'FxImageCompare',
      () => const SizedBox(
        width: 220,
        child: FxImageCompare(
          height: 130,
          before: ColoredBox(color: _pink),
          after: ColoredBox(color: _blue),
        ),
      ),
    );
    _golden(
      c,
      'FxScratchCard',
      () => SizedBox(
        width: 200,
        height: 110,
        child: FxScratchCard(child: card(_amber)),
      ),
    );
  });

  test('catalog covers every exported widget', () {
    // Exported names that are not widgets (data classes, controllers, enums,
    // typedefs and extensions).
    const notWidgets = {
      'FxBadgeExtension',
      'FxButtonState',
      'FxConfettiController',
      'FxEntranceBuilder',
      'FxFlipCardController',
      'FxNavItem',
      'FxParallaxLayer',
      'FxRange',
      'FxSlideToConfirmController',
      'FxSpinWheelController',
      'FxSwitcherEffect',
      'FxToastSide',
      'FxVisibility',
    };
    // The catalog's exports live in widgets.dart (re-exported by the barrel).
    final source = File('lib/widgets.dart').readAsStringSync();
    final exported = <String>{
      for (final m in RegExp(
        r"export 'src/widgets/[^']+'\s+show\s+([^;]+);",
      ).allMatches(source))
        ...m.group(1)!.split(',').map((s) => s.trim()),
    }..removeAll(notWidgets);
    expect(exported, isNotEmpty);
    expect(
      exported.difference(_covered),
      isEmpty,
      reason: 'Every exported widget needs a catalog golden.',
    );
  });
}
