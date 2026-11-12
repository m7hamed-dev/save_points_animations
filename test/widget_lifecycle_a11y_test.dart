import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

/// A bare host with an explicit reduce-motion flag. Re-pumping it with a
/// different flag keeps the subtree's state, i.e. it simulates the user
/// toggling the OS setting while the widget is on screen.
Widget _host(Widget child, {bool reduceMotion = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduceMotion),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  ),
);

/// An app host, so the default Tab focus-traversal shortcuts are available.
/// The autofocused scope stands in for the route a Navigator would provide,
/// giving Tab a starting point.
Widget _app(Widget child) => WidgetsApp(
  color: const Color(0xFF000000),
  builder: (context, _) =>
      FocusScope(autofocus: true, child: Center(child: child)),
);

/// Whether the primary focus currently sits inside a widget matched by
/// [finder].
bool _focusIsInside(Finder finder) {
  final focused = FocusManager.instance.primaryFocus?.context;
  if (focused == null) return false;
  final targets = finder.evaluate().toSet();
  var inside = false;
  focused.visitAncestorElements((element) {
    inside = targets.contains(element);
    return !inside;
  });
  return inside;
}

Future<void> _tab(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump();
}

/// Mounts [child] with motion allowed, then flips reduce motion on and off at
/// runtime, checking the ticker stops and resumes each time.
Future<void> _expectReactsToRuntimeToggle(
  WidgetTester tester,
  Widget child,
) async {
  await tester.pumpWidget(_host(child));
  await tester.pump(const Duration(milliseconds: 50));
  expect(tester.hasRunningAnimations, isTrue, reason: 'animates by default');

  await tester.pumpWidget(_host(child, reduceMotion: true));
  await tester.pump();
  expect(
    tester.hasRunningAnimations,
    isFalse,
    reason: 'stops when reduce motion is switched on',
  );

  await tester.pumpWidget(_host(child));
  await tester.pump(const Duration(milliseconds: 50));
  expect(
    tester.hasRunningAnimations,
    isTrue,
    reason: 'resumes when reduce motion is switched off',
  );

  await tester.pumpWidget(const SizedBox());
}

void main() {
  group('reduced motion', () {
    const progress = SizedBox(width: 200, child: FxProgressBar());
    const kenBurns = SizedBox(
      width: 200,
      height: 120,
      child: FxKenBurns(child: ColoredBox(color: Color(0xFF336699))),
    );
    const overlay = SizedBox(
      width: 300,
      height: 300,
      child: FxLoadingOverlay(visible: true, message: 'Saving'),
    );

    testWidgets('FxProgressBar: indeterminate sweep settles to a centered '
        'segment at mount', (tester) async {
      await tester.pumpWidget(_host(progress, reduceMotion: true));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      final align = tester.widget<Align>(
        find.descendant(
          of: find.byType(FxProgressBar),
          matching: find.byType(Align),
        ),
      );
      expect((align.alignment as Alignment).x, closeTo(0, 1e-9));
    });

    testWidgets('FxProgressBar: determinate value jumps instead of easing', (
      tester,
    ) async {
      Widget bar(double value) => _host(
        SizedBox(width: 200, child: FxProgressBar(value: value)),
        reduceMotion: true,
      );
      await tester.pumpWidget(bar(0.2));
      await tester.pumpWidget(bar(0.8));
      expect(tester.hasRunningAnimations, isFalse);
      final fill = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fill.widthFactor, closeTo(0.8, 1e-9));
    });

    testWidgets('FxProgressBar: reacts to a runtime toggle', (tester) async {
      await _expectReactsToRuntimeToggle(tester, progress);
    });

    testWidgets('FxKenBurns: static, untransformed child at mount', (
      tester,
    ) async {
      await tester.pumpWidget(_host(kenBurns, reduceMotion: true));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(
        find.descendant(
          of: find.byType(FxKenBurns),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
    });

    testWidgets('FxKenBurns: reacts to a runtime toggle', (tester) async {
      await _expectReactsToRuntimeToggle(tester, kenBurns);
    });

    testWidgets('FxLoadingOverlay: spinner holds still at mount', (
      tester,
    ) async {
      await tester.pumpWidget(_host(overlay, reduceMotion: true));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.text('Saving'), findsOneWidget);
    });

    testWidgets('FxLoadingOverlay: reacts to a runtime toggle', (tester) async {
      await _expectReactsToRuntimeToggle(tester, overlay);
    });
  });

  // These loops used to start only from onReduceMotionChanged, which fires
  // only when the flag *flips* — so with motion allowed they never moved.
  group('looping widgets start at mount and honor reduce motion', () {
    final loops = <String, Widget>{
      'FxPlasma': const SizedBox(width: 60, height: 60, child: FxPlasma()),
      'FxBouncingBall': const FxBouncingBall(),
      'FxWaveDots': const FxWaveDots(),
      'FxShinyText': const FxShinyText('shiny'),
      'FxDnaLoader': const SizedBox(width: 120, child: FxDnaLoader()),
      'FxHeartbeatLine': const SizedBox(
        width: 120,
        height: 40,
        child: FxHeartbeatLine(),
      ),
      'FxMeshGradient': const SizedBox(
        width: 60,
        height: 60,
        child: FxMeshGradient(),
      ),
      'FxCircularText': const FxCircularText('round and round '),
      'FxWaveProgress': const FxWaveProgress(),
      'FxRadar': const FxRadar(),
      'FxOrbitLoader': const FxOrbitLoader(),
      'FxDotsLoader': const FxDotsLoader(),
      'FxBarsLoader': const FxBarsLoader(),
      'FxProgressRing': const FxProgressRing(),
      'FxGlowButton': const FxGlowButton(child: Text('glow')),
      'FxGradientButton': const FxGradientButton(child: Text('grad')),
      'FxShimmerButton': FxShimmerButton(
        onPressed: () {},
        child: const Text('shimmer'),
      ),
      'FxNeonText': const FxNeonText('neon'),
      'FxTypingIndicator': const FxTypingIndicator(),
    };
    for (final entry in loops.entries) {
      testWidgets(entry.key, (tester) async {
        await _expectReactsToRuntimeToggle(tester, entry.value);

        await tester.pumpWidget(_host(entry.value, reduceMotion: true));
        await tester.pumpAndSettle();
        expect(tester.hasRunningAnimations, isFalse);
        await tester.pumpWidget(const SizedBox());
      });
    }
  });

  group('didUpdateWidget', () {
    testWidgets('FxAnimatedGradient: a new duration changes the running '
        'period', (tester) async {
      const colors = [Color(0xFF000000), Color(0xFFFFFFFF)];
      Widget gradient(Duration duration) => _host(
        SizedBox(
          width: 100,
          height: 100,
          child: FxAnimatedGradient(colors: colors, duration: duration),
        ),
      );
      Alignment begin() {
        final box = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(FxAnimatedGradient),
            matching: find.byType(DecoratedBox),
          ),
        );
        final g = (box.decoration as BoxDecoration).gradient! as LinearGradient;
        return g.begin as Alignment;
      }

      await tester.pumpWidget(gradient(const Duration(seconds: 4)));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // value 0.25

      await tester.pumpWidget(gradient(const Duration(seconds: 1)));
      await tester.pump();
      // At the new 1s period, 250ms later the loop is at 0.5 (angle π). The
      // old 4s period would only have reached 0.3125.
      await tester.pump(const Duration(milliseconds: 250));
      expect(begin().x, closeTo(1, 1e-6));
      expect(begin().y, closeTo(0, 1e-6));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('FxExpandable: a new duration applies to the next toggle', (
      tester,
    ) async {
      Widget expandable(Duration duration) => _host(
        SizedBox(
          width: 200,
          child: FxExpandable(
            header: const Text('Header'),
            body: const SizedBox(height: 50),
            duration: duration,
          ),
        ),
      );
      await tester.pumpWidget(expandable(const Duration(seconds: 2)));
      await tester.pumpWidget(expandable(const Duration(milliseconds: 100)));
      await tester.tap(find.text('Header'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final size = tester.widget<SizeTransition>(find.byType(SizeTransition));
      expect(size.sizeFactor.value, 1.0);
    });

    testWidgets('a duration change keeps a reduced-motion loop stopped', (
      tester,
    ) async {
      const dot = SizedBox(width: 10, height: 10);
      await tester.pumpWidget(
        _host(const FxPulse(child: dot), reduceMotion: true),
      );
      await tester.pumpWidget(
        _host(
          const FxPulse(duration: Duration(seconds: 3), child: dot),
          reduceMotion: true,
        ),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('keyboard', () {
    testWidgets('FxAnimatedSlider: arrow keys step the focused slider', (
      tester,
    ) async {
      var value = 0.5;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 200,
              child: FxAnimatedSlider(
                value: value,
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      );
      // Arrows do nothing until the slider has focus.
      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(value, 0.5);

      await _tab(tester);
      expect(_focusIsInside(find.byType(FxAnimatedSlider)), isTrue);
      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(value, closeTo(0.6, 1e-9));
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      expect(value, closeTo(0.4, 1e-9));
      await _press(tester, LogicalKeyboardKey.arrowUp);
      expect(value, closeTo(0.5, 1e-9));
      await _press(tester, LogicalKeyboardKey.arrowDown);
      expect(value, closeTo(0.4, 1e-9));
    }, variant: TargetPlatformVariant.desktop());

    testWidgets(
      'FxRangeSlider: Tab moves start → end thumb; arrows nudge the focused one',
      (tester) async {
        var range = const FxRange(0.2, 0.8);
        await tester.pumpWidget(
          _app(
            StatefulBuilder(
              builder: (context, setState) => SizedBox(
                width: 200,
                child: FxRangeSlider(
                  values: range,
                  onChanged: (v) => setState(() => range = v),
                ),
              ),
            ),
          ),
        );
        await _tab(tester);
        await _press(tester, LogicalKeyboardKey.arrowRight);
        expect(range.start, closeTo(0.25, 1e-9));
        expect(range.end, 0.8);

        await _tab(tester);
        await _press(tester, LogicalKeyboardKey.arrowLeft);
        expect(range.start, closeTo(0.25, 1e-9));
        expect(range.end, closeTo(0.75, 1e-9));
      },
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    );

    testWidgets('FxAnimatedToggle: Space / Enter flip it; focus ring only '
        'while focused', (tester) async {
      var on = false;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => FxAnimatedToggle(
              value: on,
              onChanged: (v) => setState(() => on = v),
            ),
          ),
        ),
      );
      final ring = find.descendant(
        of: find.byType(FxAnimatedToggle),
        matching: find.byWidgetPredicate(
          (w) => w is CustomPaint && w.foregroundPainter != null,
        ),
      );
      expect(ring, findsNothing);

      await _tab(tester);
      expect(ring, findsOneWidget);
      await _press(tester, LogicalKeyboardKey.space);
      expect(on, isTrue);
      await _press(tester, LogicalKeyboardKey.enter);
      expect(on, isFalse);
    });

    // Every tappable control: focus with Tab, then Enter and Space activate.
    final activatable = <String, Widget Function(VoidCallback)>{
      'FxGlowButton': (cb) =>
          FxGlowButton(onPressed: cb, child: const Text('x')),
      'FxGradientButton': (cb) =>
          FxGradientButton(onPressed: cb, child: const Text('x')),
      'FxJellyButton': (cb) =>
          FxJellyButton(onPressed: cb, child: const Text('x')),
      'FxShimmerButton': (cb) =>
          FxShimmerButton(onPressed: cb, child: const Text('x')),
      'FxMagneticButton': (cb) =>
          FxMagneticButton(onTap: cb, child: const Text('x')),
      'FxHeartButton': (cb) =>
          FxHeartButton(isLiked: false, onChanged: (_) => cb()),
      'FxProgressButton': (cb) => SizedBox(
        width: 200,
        child: FxProgressButton(
          state: FxButtonState.idle,
          onPressed: cb,
          child: const Text('x'),
        ),
      ),
      'FxAnimatedCheckbox': (cb) =>
          FxAnimatedCheckbox(value: false, onChanged: (_) => cb()),
      'FxAnimatedRadio': (cb) =>
          FxAnimatedRadio<int>(value: 1, groupValue: 0, onChanged: (_) => cb()),
      'FxThemeToggle': (cb) =>
          FxThemeToggle(isDark: false, onChanged: (_) => cb()),
    };
    for (final entry in activatable.entries) {
      testWidgets('${entry.key}: Enter and Space activate it once focused', (
        tester,
      ) async {
        var count = 0;
        await tester.pumpWidget(_app(entry.value(() => count++)));
        await _press(tester, LogicalKeyboardKey.enter);
        expect(count, 0, reason: 'not focused yet');

        await _tab(tester);
        await _press(tester, LogicalKeyboardKey.enter);
        expect(count, 1);
        await _press(tester, LogicalKeyboardKey.space);
        expect(count, 2);
        await tester.pumpWidget(const SizedBox());
      });
    }

    testWidgets('FxExpandable: Enter toggles the focused header', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 200,
            child: FxExpandable(
              header: Text('Header'),
              body: SizedBox(height: 20),
            ),
          ),
        ),
      );
      final size = find.byType(SizeTransition);
      await _tab(tester);
      await _press(tester, LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(tester.widget<SizeTransition>(size).sizeFactor.value, 1.0);
      await _press(tester, LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(tester.widget<SizeTransition>(size).sizeFactor.value, 0.0);
    });

    testWidgets('FxHoldButton: holding Enter / Space confirms; an early '
        'release rewinds', (tester) async {
      var confirmed = 0;
      await tester.pumpWidget(
        _app(
          FxHoldButton(onConfirmed: () => confirmed++, child: const SizedBox()),
        ),
      );
      await _tab(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(confirmed, 0);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      expect(confirmed, 1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(confirmed, 1);
    });

    testWidgets('disabled controls are skipped by Tab and ignore keys', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FxGlowButton(child: Text('glow')),
              FxGradientButton(child: Text('grad')),
              FxJellyButton(child: Text('jelly')),
              FxAnimatedCheckbox(value: false, onChanged: null),
              FxAnimatedRadio<int>(value: 1, groupValue: 0, onChanged: null),
              FxMagneticButton(child: Text('magnet')),
            ],
          ),
        ),
      );
      await _tab(tester);
      await _press(tester, LogicalKeyboardKey.enter);
      await _press(tester, LogicalKeyboardKey.space);
      for (final type in [
        FxGlowButton,
        FxGradientButton,
        FxJellyButton,
        FxAnimatedCheckbox,
        FxAnimatedRadio<int>,
        FxMagneticButton,
      ]) {
        expect(_focusIsInside(find.byType(type)), isFalse, reason: '$type');
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a focused button that becomes disabled drops focus and '
        'ignores Enter', (tester) async {
      var taps = 0;
      Widget button({required bool enabled}) => _app(
        FxGlowButton(
          onPressed: enabled ? () => taps++ : null,
          child: const Text('Go'),
        ),
      );
      await tester.pumpWidget(button(enabled: true));
      await _tab(tester);
      expect(_focusIsInside(find.byType(FxGlowButton)), isTrue);
      await _press(tester, LogicalKeyboardKey.enter);
      expect(taps, 1);

      await tester.pumpWidget(button(enabled: false));
      await tester.pump();
      expect(_focusIsInside(find.byType(FxGlowButton)), isFalse);
      await _press(tester, LogicalKeyboardKey.enter);
      expect(taps, 1);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('semantics', () {
    testWidgets('controls expose focusability, state and actions', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FxAnimatedToggle(value: true, onChanged: (_) {}),
              SizedBox(
                width: 200,
                child: FxAnimatedSlider(value: 0.5, onChanged: (_) {}),
              ),
              const FxAnimatedCheckbox(value: true, onChanged: null),
              FxMagneticButton(onTap: () {}, child: const Text('magnet')),
            ],
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(FxAnimatedToggle)),
        isSemantics(
          isButton: true,
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      // The slider's node sits below its LayoutBuilder, so find it by value.
      expect(
        find.semantics.byValue('0.50').evaluate().single,
        isSemantics(
          value: '0.50',
          increasedValue: '0.60',
          decreasedValue: '0.40',
          isSlider: true,
          isFocusable: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      // Its node sits below the root RepaintBoundary; look up from the box.
      expect(
        tester.getSemantics(
          find
              .descendant(
                of: find.byType(FxAnimatedCheckbox),
                matching: find.byType(CustomPaint),
              )
              .last,
        ),
        isSemantics(
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: false,
          isFocusable: false,
          hasTapAction: false,
        ),
      );
      expect(
        tester.getSemantics(find.byType(FxMagneticButton)),
        isSemantics(
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('FxHoldButton: a screen-reader tap confirms directly', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var confirmed = 0;
      await tester.pumpWidget(
        _host(
          FxHoldButton(onConfirmed: () => confirmed++, child: const SizedBox()),
        ),
      );
      expect(
        tester.getSemantics(find.byType(FxHoldButton)),
        isSemantics(isButton: true, isFocusable: true, hasTapAction: true),
      );
      tester.semantics.tap(find.semantics.byAction(SemanticsAction.tap));
      expect(confirmed, 1);
      handle.dispose();
    });
  });
}
