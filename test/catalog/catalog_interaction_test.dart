import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

import 'catalog_harness.dart';

// Behavior tests for the interactive widgets — beyond "renders and disposes".
//
// Tests that expose a widget bug are kept but skipped with the reason (see
// `catalogTestWidgets`); run them with --dart-define=CATALOG_RUN_SKIPPED=true.

Future<void> _pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(catalogHost(child));

void _noop() {}

/// `FxRange` has no `toString`, so compare as a record for readable failures.
(double, double) _r(FxRange range) => (range.start, range.end);

/// Slider gesture tests run with the semantics tree on, which also guards the
/// increasedValue / decreasedValue annotations Flutter asserts on.
void _sliderTest(String description, WidgetTesterCallback body) =>
    catalogTestWidgets(description, body);

void main() {
  group('FxAnimatedSlider', () {
    Future<List<double>> pumpSlider(
      WidgetTester tester, {
      double initial = 15,
      double min = 10,
      double max = 20,
    }) async {
      final changes = <double>[];
      var value = initial;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 200,
            child: FxAnimatedSlider(
              value: value,
              min: min,
              max: max,
              onChanged: (v) {
                changes.add(v);
                setState(() => value = v);
              },
            ),
          ),
        ),
      );
      return changes;
    }

    _sliderTest('dragging right raises the value and clamps at max', (
      tester,
    ) async {
      final changes = await pumpSlider(tester);
      await tester.drag(find.byType(FxAnimatedSlider), const Offset(60, 0));
      await tester.pumpAndSettle();
      expect(changes, isNotEmpty);
      expect(changes.last, greaterThan(15));

      // Way past the right edge: pinned to max, never beyond.
      await tester.drag(find.byType(FxAnimatedSlider), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(changes.last, 20);
      expect(changes.every((v) => v >= 10 && v <= 20), isTrue);
    });

    _sliderTest('dragging left lowers the value and clamps at min', (
      tester,
    ) async {
      final changes = await pumpSlider(tester);
      await tester.drag(find.byType(FxAnimatedSlider), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(changes.last, 10);
      expect(changes.every((v) => v >= 10 && v <= 20), isTrue);
    });

    _sliderTest('tapping the track jumps to the tapped position', (
      tester,
    ) async {
      final changes = await pumpSlider(tester);
      final rect = tester.getRect(find.byType(FxAnimatedSlider));
      await tester.tapAt(Offset(rect.left + rect.width * 0.25, rect.center.dy));
      await tester.pump();
      expect(changes.single, closeTo(12.5, 0.01));
    });
  });

  group('FxRangeSlider', () {
    const width = 200.0;

    Future<List<FxRange>> pumpRange(
      WidgetTester tester, {
      FxRange initial = const FxRange(0.2, 0.8),
      double min = 0,
      double max = 1,
    }) async {
      final changes = <FxRange>[];
      var values = initial;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: width,
            child: FxRangeSlider(
              values: values,
              min: min,
              max: max,
              onChanged: (v) {
                changes.add(v);
                setState(() => values = v);
              },
            ),
          ),
        ),
      );
      return changes;
    }

    Offset at(WidgetTester tester, double fraction) {
      final rect = tester.getRect(find.byType(FxRangeSlider));
      return Offset(rect.left + rect.width * fraction, rect.center.dy);
    }

    _sliderTest('dragging the start thumb moves only the start', (
      tester,
    ) async {
      final changes = await pumpRange(tester);
      await tester.dragFrom(at(tester, 0.2), const Offset(40, 0));
      await tester.pumpAndSettle();
      expect(changes.last.start, closeTo(0.4, 0.01));
      expect(changes.every((r) => r.end == 0.8), isTrue);
    });

    _sliderTest('the start thumb cannot pass the end thumb', (tester) async {
      final changes = await pumpRange(tester);
      await tester.dragFrom(at(tester, 0.2), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(_r(changes.last), (0.8, 0.8));
      expect(changes.every((r) => r.start <= r.end), isTrue);
    });

    _sliderTest('the end thumb clamps to max and cannot pass the start', (
      tester,
    ) async {
      final changes = await pumpRange(tester);
      await tester.dragFrom(at(tester, 0.8), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(_r(changes.last), (0.2, 1.0));

      await tester.dragFrom(at(tester, 0.99), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(_r(changes.last), (0.2, 0.2));
      expect(changes.every((r) => r.start <= r.end), isTrue);
    });

    _sliderTest('collapsed thumbs open in the drag direction', (tester) async {
      final changes = await pumpRange(tester, initial: const FxRange(0.5, 0.5));
      await tester.dragFrom(at(tester, 0.5), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(changes.last.start, 0.5);
      expect(changes.last.end, greaterThan(0.5));
    });

    _sliderTest('honors a custom min/max', (tester) async {
      final changes = await pumpRange(
        tester,
        initial: const FxRange(20, 80),
        max: 100,
      );
      await tester.dragFrom(at(tester, 0.8), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(_r(changes.last), (20.0, 100.0));
    });
  });

  group('FxSwipeCards', () {
    Future<List<(int, bool)>> pumpDeck(WidgetTester tester) async {
      final swipes = <(int, bool)>[];
      await _pump(
        tester,
        SizedBox(
          width: 300,
          height: 200,
          child: FxSwipeCards(
            onSwiped: (i, toRight) => swipes.add((i, toRight)),
            cards: [
              for (var i = 0; i < 3; i++)
                catalogSwatch(
                  const Color(0xFF448AFF),
                  width: 200,
                  height: 140,
                  child: Text('Card $i'),
                ),
            ],
          ),
        ),
      );
      return swipes;
    }

    testWidgets('swiping right / left past the threshold reports direction', (
      tester,
    ) async {
      final swipes = await pumpDeck(tester);
      await tester.timedDrag(
        find.text('Card 0'),
        const Offset(160, 0),
        const Duration(milliseconds: 600),
      );
      await tester.pumpAndSettle();
      expect(swipes, [(0, true)]);

      await tester.timedDrag(
        find.text('Card 1'),
        const Offset(-160, 0),
        const Duration(milliseconds: 600),
      );
      await tester.pumpAndSettle();
      expect(swipes, [(0, true), (1, false)]);
      expect(find.text('Card 0'), findsNothing);
      expect(find.text('Card 2'), findsOneWidget);
    });

    testWidgets('a short, slow drag springs back without a callback', (
      tester,
    ) async {
      final swipes = await pumpDeck(tester);
      final before = tester.getCenter(find.text('Card 0'));
      await tester.timedDrag(
        find.text('Card 0'),
        const Offset(50, 0),
        const Duration(milliseconds: 600),
      );
      await tester.pumpAndSettle();
      expect(swipes, isEmpty);
      expect(tester.getCenter(find.text('Card 0')), before);
    });

    testWidgets('a fast fling dismisses even when short', (tester) async {
      final swipes = await pumpDeck(tester);
      await tester.fling(find.text('Card 0'), const Offset(-60, 0), 1500);
      await tester.pumpAndSettle();
      expect(swipes, [(0, false)]);
    });

    testWidgets('an exhausted deck renders nothing and ignores drags', (
      tester,
    ) async {
      final swipes = await pumpDeck(tester);
      for (var i = 0; i < 3; i++) {
        await tester.fling(find.text('Card $i'), const Offset(100, 0), 1500);
        await tester.pumpAndSettle();
      }
      expect(swipes.map((s) => s.$1), [0, 1, 2]);
      expect(find.textContaining('Card'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('FxSwipeToDismiss', () {
    Future<int Function()> pumpItem(WidgetTester tester) async {
      var dismissed = 0;
      await _pump(
        tester,
        SizedBox(
          width: 300,
          child: FxSwipeToDismiss(
            onDismissed: () => dismissed++,
            child: catalogSwatch(
              const Color(0xFF00C9A7),
              height: 60,
              child: const Text('Item'),
            ),
          ),
        ),
      );
      return () => dismissed;
    }

    testWidgets('dragging past the threshold dismisses once', (tester) async {
      final dismissed = await pumpItem(tester);
      await tester.timedDrag(
        find.text('Item'),
        const Offset(-200, 0),
        const Duration(milliseconds: 600),
      );
      await tester.pumpAndSettle();
      expect(dismissed(), 1);
    });

    testWidgets('a short slow drag springs back', (tester) async {
      final dismissed = await pumpItem(tester);
      final before = tester.getCenter(find.text('Item'));
      await tester.timedDrag(
        find.text('Item'),
        const Offset(60, 0),
        const Duration(milliseconds: 600),
      );
      await tester.pumpAndSettle();
      expect(dismissed(), 0);
      expect(tester.getCenter(find.text('Item')), before);
    });

    testWidgets('a fast fling dismisses even when short', (tester) async {
      final dismissed = await pumpItem(tester);
      await tester.fling(find.text('Item'), const Offset(50, 0), 1500);
      await tester.pumpAndSettle();
      expect(dismissed(), 1);
    });
  });

  group('FxSlideToConfirm', () {
    const width = 300.0;
    // Thumb = height - 8 = 48; travel = width - thumb - 8 = 244.
    final thumb = find.descendant(
      of: find.byType(FxSlideToConfirm),
      matching: find.byType(GestureDetector),
    );

    Future<int Function()> pumpSlide(
      WidgetTester tester, {
      bool enabled = true,
      FxSlideToConfirmController? controller,
    }) async {
      var confirmed = 0;
      await _pump(
        tester,
        SizedBox(
          width: width,
          child: FxSlideToConfirm(
            label: const Text('Slide to pay'),
            enabled: enabled,
            controller: controller,
            onConfirmed: () => confirmed++,
          ),
        ),
      );
      return () => confirmed;
    }

    double thumbOffset(WidgetTester tester) =>
        tester.getTopLeft(thumb).dx -
        tester.getTopLeft(find.byType(FxSlideToConfirm)).dx;

    testWidgets('releasing before 90% springs back without confirming', (
      tester,
    ) async {
      final confirmed = await pumpSlide(tester);
      await tester.drag(thumb, const Offset(150, 0));
      await tester.pumpAndSettle();
      expect(confirmed(), 0);
      expect(thumbOffset(tester), 4);
    });

    testWidgets('dragging to the end confirms exactly once, then locks', (
      tester,
    ) async {
      final confirmed = await pumpSlide(tester);
      await tester.drag(thumb, const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(confirmed(), 1);
      expect(thumbOffset(tester), 4 + 244);

      // Confirmed: further drags are ignored.
      await tester.drag(thumb, const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(confirmed(), 1);
      expect(thumbOffset(tester), 4 + 244);
    });

    testWidgets('enabled: false ignores drags', (tester) async {
      final confirmed = await pumpSlide(tester, enabled: false);
      await tester.drag(thumb, const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(confirmed(), 0);
      expect(thumbOffset(tester), 4);
    });

    testWidgets('controller.reset() re-arms the control', (tester) async {
      final controller = FxSlideToConfirmController();
      final confirmed = await pumpSlide(tester, controller: controller);
      await tester.drag(thumb, const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(confirmed(), 1);

      controller.reset();
      await tester.pumpAndSettle();
      expect(thumbOffset(tester), 4);

      await tester.drag(thumb, const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(confirmed(), 2);
    });

    testWidgets('controller is detached on dispose', (tester) async {
      final controller = FxSlideToConfirmController();
      await pumpSlide(tester, controller: controller);
      await tester.pumpWidget(const SizedBox());
      expect(controller.reset, returnsNormally);
    });

    test('FxSlideToConfirmController is exported by the public library', () {
      final library = File('lib/widgets.dart').readAsStringSync();
      expect(
        RegExp(
          r"export 'src/widgets/fx_slide_to_confirm\.dart'\s+show[^;]*"
          r'\bFxSlideToConfirmController\b',
        ).hasMatch(library),
        isTrue,
      );
    });
  });

  group('FxHoldButton', () {
    Future<int Function()> pumpHold(WidgetTester tester) async {
      var confirmed = 0;
      await _pump(
        tester,
        FxHoldButton(onConfirmed: () => confirmed++, child: const Text('Hold')),
      );
      return () => confirmed;
    }

    testWidgets('releasing before holdDuration does not confirm', (
      tester,
    ) async {
      final confirmed = await pumpHold(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(FxHoldButton)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(confirmed(), 0);
    });

    testWidgets('holding for holdDuration confirms exactly once', (
      tester,
    ) async {
      final confirmed = await pumpHold(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(FxHoldButton)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));
      expect(confirmed(), 0);
      await tester.pump(const Duration(milliseconds: 150));
      expect(confirmed(), 1);

      // Keep holding: it must not re-fire.
      await tester.pump(const Duration(milliseconds: 1500));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(confirmed(), 1);
    });
  });

  group('toggles', () {
    testWidgets('FxAnimatedToggle flips its value on tap', (tester) async {
      final reported = <bool>[];
      var value = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => FxAnimatedToggle(
            value: value,
            onChanged: (v) {
              reported.add(v);
              setState(() => value = v);
            },
          ),
        ),
      );
      await tester.tap(find.byType(FxAnimatedToggle));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FxAnimatedToggle));
      await tester.pumpAndSettle();
      expect(reported, [true, false]);
    });

    testWidgets('FxThemeToggle reports the next mode', (tester) async {
      final reported = <bool>[];
      await _pump(
        tester,
        FxThemeToggle(isDark: false, onChanged: reported.add),
      );
      await tester.tap(find.byType(FxThemeToggle));
      await tester.pumpAndSettle();
      expect(reported, [true]);
    });

    testWidgets('FxHeartButton reports like / unlike', (tester) async {
      final reported = <bool>[];
      var liked = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => FxHeartButton(
            isLiked: liked,
            onChanged: (v) {
              reported.add(v);
              setState(() => liked = v);
            },
          ),
        ),
      );
      await tester.tap(find.byType(FxHeartButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FxHeartButton));
      await tester.pumpAndSettle();
      expect(reported, [true, false]);
    });

    testWidgets('FxAnimatedCheckbox reports changes; disabled ignores taps', (
      tester,
    ) async {
      final reported = <bool>[];
      await _pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FxAnimatedCheckbox(
              key: const ValueKey('enabled'),
              value: false,
              onChanged: reported.add,
            ),
            const SizedBox(width: 40),
            const FxAnimatedCheckbox(
              key: ValueKey('disabled'),
              value: false,
              onChanged: null,
            ),
          ],
        ),
      );
      await tester.tap(find.byKey(const ValueKey('enabled')));
      await tester.tap(find.byKey(const ValueKey('disabled')));
      await tester.pumpAndSettle();
      expect(reported, [true]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FxAnimatedRadio reports its value; disabled ignores taps', (
      tester,
    ) async {
      final reported = <String>[];
      await _pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FxAnimatedRadio<String>(
              key: const ValueKey('a'),
              value: 'a',
              groupValue: 'b',
              onChanged: reported.add,
            ),
            const SizedBox(width: 40),
            const FxAnimatedRadio<String>(
              key: ValueKey('c'),
              value: 'c',
              groupValue: 'b',
              onChanged: null,
            ),
          ],
        ),
      );
      await tester.tap(find.byKey(const ValueKey('a')));
      await tester.tap(find.byKey(const ValueKey('c')));
      await tester.pumpAndSettle();
      expect(reported, ['a']);
    });
  });

  group('FxRating', () {
    Finder star(int i) => find
        .descendant(
          of: find.byType(FxRating),
          matching: find.byType(GestureDetector),
        )
        .at(i);

    testWidgets('tapping the Nth star reports N', (tester) async {
      final reported = <int>[];
      await _pump(tester, FxRating(onChanged: reported.add));
      await tester.tap(star(3));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(star(0));
      await tester.pump(const Duration(milliseconds: 400));
      expect(reported, [4, 1]);
    });

    testWidgets('read-only (onChanged: null) ignores taps', (tester) async {
      await _pump(tester, const FxRating(value: 2));
      await tester.tap(star(4));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('FxNumberPad', () {
    testWidgets('emits the tapped digits and backspace', (tester) async {
      final digits = <int>[];
      var backspaces = 0;
      await _pump(
        tester,
        FxNumberPad(onDigit: digits.add, onBackspace: () => backspaces++),
      );
      for (final d in [7, 0, 3, 9]) {
        await tester.tap(find.text('$d'));
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.tap(find.text('⌫'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(digits, [7, 0, 3, 9]);
      expect(backspaces, 1);
    });

    testWidgets('backspace without a handler is a no-op', (tester) async {
      final digits = <int>[];
      await _pump(tester, FxNumberPad(onDigit: digits.add));
      await tester.tap(find.text('⌫'));
      await tester.pumpAndSettle();
      expect(digits, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  group('FxStepper', () {
    Future<List<int>> pumpStepper(
      WidgetTester tester, {
      required int value,
      int min = 0,
      int max = 999,
      int step = 1,
    }) async {
      final reported = <int>[];
      var current = value;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => FxStepper(
            value: current,
            min: min,
            max: max,
            step: step,
            onChanged: (v) {
              reported.add(v);
              setState(() => current = v);
            },
          ),
        ),
      );
      return reported;
    }

    testWidgets('+ and − change the value by step', (tester) async {
      final reported = await pumpStepper(tester, value: 3);
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('−'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('−'));
      await tester.pumpAndSettle();
      expect(reported, [4, 3, 2]);
    });

    testWidgets('clamps to max and disables + at the bound', (tester) async {
      final reported = await pumpStepper(tester, value: 8, max: 10, step: 5);
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      expect(reported, [10]);
    });

    testWidgets('− is disabled at min', (tester) async {
      final reported = await pumpStepper(tester, value: 0);
      await tester.tap(find.text('−'));
      await tester.pumpAndSettle();
      expect(reported, isEmpty);
    });
  });

  group('index pickers report the tapped index', () {
    Future<void> expectTaps(
      WidgetTester tester,
      Widget Function(ValueChanged<int> onTap) build,
      Map<Finder, int> taps,
    ) async {
      final reported = <int>[];
      await _pump(tester, SizedBox(width: 360, child: build(reported.add)));
      for (final finder in taps.keys) {
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }
      expect(reported, taps.values.toList());
    }

    Finder nav(int i) => find.byKey(ValueKey('nav-$i'));

    for (final (name, build) in <(String, Widget Function(ValueChanged<int>))>[
      (
        'FxCurvedNavBar',
        (onTap) => FxCurvedNavBar(
          items: catalogNavItems(),
          currentIndex: 0,
          onTap: onTap,
        ),
      ),
      (
        'FxDotNavBar',
        (onTap) => FxDotNavBar(
          items: catalogNavItems(),
          currentIndex: 0,
          onTap: onTap,
        ),
      ),
      (
        'FxFrostedNavBar',
        (onTap) => FxFrostedNavBar(
          items: catalogNavItems(),
          currentIndex: 0,
          onTap: onTap,
        ),
      ),
      (
        'FxGooeyNavBar',
        (onTap) => FxGooeyNavBar(
          items: catalogNavItems(),
          currentIndex: 0,
          onTap: onTap,
        ),
      ),
      (
        'FxPillNavBar',
        (onTap) => FxPillNavBar(
          items: catalogNavItems(),
          currentIndex: 0,
          onTap: onTap,
        ),
      ),
      (
        'FxAnimatedNavBar',
        (onTap) => FxAnimatedNavBar(
          items: [for (final i in catalogNavItems()) i.icon],
          currentIndex: 0,
          onTap: onTap,
        ),
      ),
    ]) {
      testWidgets(name, (tester) async {
        await expectTaps(tester, build, {nav(2): 2, nav(3): 3, nav(1): 1});
      });
    }

    testWidgets('FxAnimatedTabBar', (tester) async {
      await expectTaps(
        tester,
        (onTap) => FxAnimatedTabBar(
          tabs: const ['One', 'Two', 'Three'],
          selectedIndex: 0,
          onChanged: onTap,
        ),
        {find.text('Three'): 2, find.text('Two'): 1},
      );
    });

    testWidgets('FxSegmentedControl', (tester) async {
      await expectTaps(
        tester,
        (onTap) => FxSegmentedControl(
          segments: const ['Day', 'Week', 'Month'],
          selectedIndex: 0,
          onChanged: onTap,
        ),
        {find.text('Month'): 2, find.text('Day'): 0},
      );
    });

    testWidgets('FxTagChips', (tester) async {
      await expectTaps(
        tester,
        (onTap) => FxTagChips(
          tags: const ['Flutter', 'Dart', 'Motion'],
          selected: const {0},
          onToggle: onTap,
        ),
        {find.text('Dart'): 1, find.text('Flutter'): 0},
      );
    });

    testWidgets('FxPageIndicator (onDotTapped)', (tester) async {
      final controller = PageController();
      addTearDown(controller.dispose);
      Finder dot(int i) => find
          .descendant(
            of: find.byType(FxPageIndicator),
            matching: find.byType(GestureDetector),
          )
          .at(i);
      await expectTaps(
        tester,
        (onTap) => Center(
          child: FxPageIndicator(
            controller: controller,
            count: 4,
            size: 16,
            onDotTapped: onTap,
          ),
        ),
        {dot(2): 2, dot(0): 0},
      );
    });
  });

  group('FxReactionBar', () {
    testWidgets('reports the tapped reaction; tapping it again clears', (
      tester,
    ) async {
      final reported = <int?>[];
      int? selected;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => FxReactionBar(
            reactions: const ['A', 'B', 'C'],
            selected: selected,
            onChanged: (i) {
              reported.add(i);
              setState(() => selected = i);
            },
          ),
        ),
      );
      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(reported, [2, null, 0]);
    });
  });

  group('FxDateStrip', () {
    testWidgets('reports the tapped day', (tester) async {
      final reported = <DateTime>[];
      await _pump(
        tester,
        SizedBox(
          width: 400,
          child: FxDateStrip(
            days: [for (var d = 2; d <= 6; d++) DateTime(2026, 3, d)],
            selected: DateTime(2026, 3, 2),
            onChanged: reported.add,
          ),
        ),
      );
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      expect(reported, [DateTime(2026, 3, 5)]);
    });
  });

  group('FxWheelPicker', () {
    testWidgets('scrolling selects a later item', (tester) async {
      final reported = <int>[];
      await _pump(
        tester,
        SizedBox(
          width: 200,
          child: FxWheelPicker(
            items: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            selectedIndex: 1,
            onChanged: reported.add,
          ),
        ),
      );
      await tester.drag(find.byType(FxWheelPicker), const Offset(0, -100));
      await tester.pumpAndSettle();
      expect(reported, isNotEmpty);
      expect(reported.last, greaterThan(1));
      expect(reported.last, lessThan(7));
    });
  });

  group('buttons', () {
    for (final (name, build)
        in <(String, Widget Function(VoidCallback? onPressed))>[
          (
            'FxGlowButton',
            (p) => FxGlowButton(onPressed: p, child: const Text('Go')),
          ),
          (
            'FxGradientButton',
            (p) => FxGradientButton(onPressed: p, child: const Text('Go')),
          ),
          (
            'FxJellyButton',
            (p) => FxJellyButton(onPressed: p, child: const Text('Go')),
          ),
          (
            'FxMagneticButton',
            (p) => FxMagneticButton(onTap: p, child: const Text('Go')),
          ),
        ]) {
      testWidgets('$name fires on tap and ignores taps when disabled', (
        tester,
      ) async {
        var taps = 0;
        // Fixed pumps: several of these buttons loop forever (glow, gradient
        // sweep), so they never settle.
        await _pump(tester, build(() => taps++));
        await tester.tap(find.text('Go'));
        await tester.pump(const Duration(milliseconds: 500));
        expect(taps, 1);

        await _pump(tester, build(null));
        await tester.tap(find.text('Go'));
        await tester.pump(const Duration(milliseconds: 500));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('FxShimmerButton fires on tap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        FxShimmerButton(onPressed: () => taps++, child: const Text('Go')),
      );
      await tester.tap(find.text('Go'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(taps, 1);
    });

    testWidgets('FxProgressButton only fires while idle', (tester) async {
      var taps = 0;
      for (final state in FxButtonState.values) {
        await _pump(
          tester,
          SizedBox(
            width: 220,
            child: FxProgressButton(
              state: state,
              onPressed: () => taps++,
              child: const Text('Go'),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.byType(FxProgressButton), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 400));
        expect(taps, 1, reason: 'after tapping in state $state');
      }
    });
  });

  group('disclosure', () {
    testWidgets('FxExpandable toggles its body on header taps', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 240,
          child: FxExpandable(
            header: SizedBox(height: 40, child: Text('Details')),
            body: SizedBox(height: 100, child: Text('Body')),
          ),
        ),
      );
      double height() => tester.getSize(find.byType(FxExpandable)).height;
      expect(height(), 40);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(height(), 140);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(height(), 40);
    });

    testWidgets('FxFlipCard flips on tap and via its controller', (
      tester,
    ) async {
      final controller = FxFlipCardController();
      Future<void> pumpCard({required bool flipOnTap}) => _pump(
        tester,
        FxFlipCard(
          flipOnTap: flipOnTap,
          controller: controller,
          front: const SizedBox(width: 120, height: 80, child: Text('Front')),
          back: const SizedBox(width: 120, height: 80, child: Text('Back')),
        ),
      );
      await pumpCard(flipOnTap: true);
      expect(find.text('Front'), findsOneWidget);
      await tester.tap(find.byType(FxFlipCard));
      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Front'), findsNothing);

      // flipOnTap: false ignores taps, but the controller still flips.
      await pumpCard(flipOnTap: false);
      await tester.tap(find.byType(FxFlipCard));
      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);
      controller.flip();
      await tester.pumpAndSettle();
      expect(find.text('Front'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      expect(controller.flip, returnsNormally);
    });

    testWidgets('FxMorphIcon forwards taps', (tester) async {
      var taps = 0;
      await _pump(tester, FxMorphIcon(isOpen: false, onTap: () => taps++));
      await tester.tap(find.byType(FxMorphIcon));
      expect(taps, 1);
    });

    testWidgets('FxToast and FxRipple forward taps', (tester) async {
      var toast = 0;
      var ripple = 0;
      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FxRipple(
              onTap: () => ripple++,
              child: const SizedBox(width: 120, height: 60),
            ),
            SizedBox(
              height: 120,
              child: FxToast(
                visible: true,
                onTap: () => toast++,
                child: const Text('Saved'),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FxRipple));
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect((ripple, toast), (1, 1));
    });
  });

  group('FxCircularMenu', () {
    Future<List<int>> pumpMenu(WidgetTester tester) async {
      final tapped = <int>[];
      await _pump(
        tester,
        FxCircularMenu(
          icon: const CatalogGlyph(),
          children: [
            for (var i = 0; i < 3; i++)
              GestureDetector(
                onTap: () => tapped.add(i),
                child: catalogSwatch(
                  const Color(0xFFEC008C),
                  width: 40,
                  height: 40,
                  child: Text('M$i'),
                ),
              ),
          ],
        ),
      );
      return tapped;
    }

    testWidgets('tapping the button fans the children out to `radius`', (
      tester,
    ) async {
      await pumpMenu(tester);
      final origin = tester.getCenter(find.byType(CatalogGlyph));
      expect(tester.getCenter(find.text('M1')), origin);
      await tester.tap(find.byType(CatalogGlyph));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        final d = tester.getCenter(find.text('M$i')) - origin;
        expect(d.distance, closeTo(90, 0.5), reason: 'child $i');
      }
      // Default arc: from pi (left) sweeping a quarter turn.
      final first = tester.getCenter(find.text('M0')) - origin;
      expect(first.direction.abs(), closeTo(math.pi, 1e-3));
    });

    catalogTestWidgets(
      'fanned-out children receive taps',
      (tester) async {
        final tapped = await pumpMenu(tester);
        await tester.tap(find.byType(CatalogGlyph));
        await tester.pumpAndSettle();
        await tester.tap(find.text('M1'), warnIfMissed: false);
        await tester.pump();
        expect(tapped, [1]);
      },
      skip:
          'BUG FxCircularMenu: open items are unreachable. They are moved '
          'with Transform.translate outside the Stack (Clip.none), whose '
          'size is only the main button, and a Stack only hit-tests inside '
          'its own bounds, so taps on the fanned-out children never land.',
    );
  });

  group('FxSpeedDial', () {
    Future<List<int>> pumpDial(WidgetTester tester, {bool fab = true}) async {
      final tapped = <int>[];
      final dial = FxSpeedDial(
        icon: const CatalogGlyph(),
        children: [
          for (var i = 0; i < 2; i++)
            GestureDetector(
              onTap: () => tapped.add(i),
              child: catalogSwatch(
                const Color(0xFF00C9A7),
                width: 40,
                height: 40,
                child: Text('S$i'),
              ),
            ),
        ],
      );
      await _pump(
        tester,
        fab
            ? Stack(
                fit: StackFit.expand,
                children: [Positioned(right: 16, bottom: 16, child: dial)],
              )
            : dial,
      );
      return tapped;
    }

    testWidgets('actions are collapsed until opened, then fire on tap', (
      tester,
    ) async {
      final tapped = await pumpDial(tester);
      double collapsedHeight() => tester
          .getSize(
            find.ancestor(
              of: find.text('S0'),
              matching: find.byType(SizeTransition),
            ),
          )
          .height;
      expect(collapsedHeight(), 0);
      expect(find.text('S0').hitTestable(), findsNothing);

      await tester.tap(find.byType(CatalogGlyph).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('S0'));
      await tester.tap(find.text('S1'));
      expect(tapped, [0, 1]);

      // Closing collapses them again.
      await tester.tap(find.byType(CatalogGlyph).last);
      await tester.pumpAndSettle();
      expect(collapsedHeight(), 0);
    });

    catalogTestWidgets(
      'children[0] sits nearest the main button (as documented)',
      (tester) async {
        await pumpDial(tester);
        await tester.tap(find.byType(CatalogGlyph).last);
        await tester.pumpAndSettle();
        final main = tester.getCenter(find.byType(CatalogGlyph).last);
        final d0 = (tester.getCenter(find.text('S0')) - main).distance;
        final d1 = (tester.getCenter(find.text('S1')) - main).distance;
        expect(d0, lessThan(d1));
      },
      skip:
          'BUG FxSpeedDial: `children` is documented as "ordered '
          'nearest-to-main first", but the Column lays children[0] out at the '
          'top, i.e. furthest from the main button.',
    );

    catalogTestWidgets(
      'actions stack above the main button under bounded width',
      (tester) async {
        await pumpDial(tester, fab: false);
        await tester.tap(find.byType(CatalogGlyph).last);
        await tester.pumpAndSettle();
        final main = tester.getRect(find.byType(CatalogGlyph).last);
        final action = tester.getRect(find.text('S0'));
        expect((action.center.dx - main.center.dx).abs(), lessThan(28));
      },
      skip:
          'BUG FxSpeedDial: with bounded loose width (Center, Align, a FAB '
          'slot) each action is wrapped in a SizeTransition whose Align has '
          'widthFactor null, so it expands to the full available width and '
          'start-aligns the action — actions render at the far left instead '
          'of above the main button. Only works when width is unbounded '
          '(e.g. Positioned without left).',
    );
  });

  group('scrolling', () {
    Widget list(ScrollController controller) => ListView(
      controller: controller,
      children: [
        for (var i = 0; i < 40; i++)
          SizedBox(height: 50, child: Text('Row $i')),
      ],
    );

    testWidgets('FxScrollToTop appears past the threshold and scrolls to 0', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        Stack(
          children: [
            list(controller),
            FxScrollToTop(controller: controller),
          ],
        ),
      );
      final button = find.text('↑');
      expect(button.hitTestable(), findsNothing);

      controller.jumpTo(200); // below the 300px threshold
      await tester.pumpAndSettle();
      expect(button.hitTestable(), findsNothing);

      controller.jumpTo(800);
      await tester.pumpAndSettle();
      expect(button.hitTestable(), findsOneWidget);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(controller.offset, 0);
    });

    const fill = Color(0xFFFF0000);
    Finder fillBox() => find.descendant(
      of: find.byType(FxScrollProgress),
      matching: find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == fill,
      ),
    );

    Future<ScrollController> pumpProgress(
      WidgetTester tester, {
      required bool barFirst,
    }) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final bar = FxScrollProgress(controller: controller, color: fill);
      await _pump(
        tester,
        SizedBox(
          width: 300,
          height: 400,
          child: Column(
            children: [
              if (barFirst) bar,
              Expanded(child: list(controller)),
              if (!barFirst) bar,
            ],
          ),
        ),
      );
      controller.jumpTo(controller.position.maxScrollExtent / 2);
      await tester.pump();
      return controller;
    }

    testWidgets('FxScrollProgress fill width follows the scroll fraction', (
      tester,
    ) async {
      final controller = await pumpProgress(tester, barFirst: false);
      expect(tester.getSize(fillBox()).width, closeTo(150, 0.5));
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      expect(tester.getSize(fillBox()).width, closeTo(300, 0.5));
    });

    catalogTestWidgets(
      'FxScrollProgress fill is as tall as the bar',
      (tester) async {
        await pumpProgress(tester, barFirst: false);
        expect(tester.getSize(fillBox()).height, 4);
      },
      skip:
          'BUG FxScrollProgress: the fill is invisible. It is a child-less '
          'ColoredBox inside Align > FractionallySizedBox(widthFactor); Align '
          'loosens the height constraint, so the fill lays out 0px tall at '
          'every scroll offset (the golden is skipped for the same reason).',
    );

    catalogTestWidgets(
      'FxScrollProgress tracks a controller attached after the bar is built',
      (tester) async {
        await pumpProgress(tester, barFirst: true);
        expect(tester.getSize(fillBox()).width, closeTo(150, 0.5));
      },
      skip:
          'BUG FxScrollProgress: if the bar builds before its scrollable (e.g. '
          'a progress bar above the list), `controller.hasClients` is false in '
          'didChangeDependencies, `_position` stays null, and nothing retries: '
          'the bar never moves. It should listen to the controller (or retry '
          'post-frame) instead of resolving the position once.',
    );
  });

  group('direct manipulation', () {
    testWidgets('FxColorWheel maps the touch point to hue / saturation', (
      tester,
    ) async {
      final reported = <Color>[];
      await _pump(
        tester,
        FxColorWheel(
          color: const Color(0xFF448AFF),
          size: 200,
          onChanged: reported.add,
        ),
      );
      final center = tester.getCenter(find.byType(FxColorWheel));
      await tester.tapAt(center + const Offset(99, 0)); // hue 0, sat ~1
      await tester.pump();
      expect(reported.last.r, closeTo(1, 0.02));
      expect(reported.last.g, closeTo(0, 0.02));
      expect(reported.last.b, closeTo(0, 0.02));

      await tester.tapAt(center); // saturation 0 -> white
      await tester.pump();
      expect(reported.last.r, closeTo(1, 0.01));
      expect(reported.last.g, closeTo(1, 0.01));
      expect(reported.last.b, closeTo(1, 0.01));
    });

    testWidgets('FxImageCompare divider follows taps and drags', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 300,
          child: FxImageCompare(
            before: ColoredBox(color: Color(0xFFEC008C)),
            after: ColoredBox(color: Color(0xFF448AFF)),
          ),
        ),
      );
      final box = tester.getRect(find.byType(FxImageCompare));
      double divider() =>
          tester.getCenter(find.byType(AnimatedPositioned).first).dx - box.left;
      expect(divider(), closeTo(150, 0.5));

      await tester.tapAt(Offset(box.left + 75, box.center.dy));
      await tester.pumpAndSettle();
      expect(divider(), closeTo(75, 0.5));

      await tester.dragFrom(
        Offset(box.left + 75, box.center.dy),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();
      expect(divider(), closeTo(300, 0.5)); // clamped to the right edge
    });

    testWidgets('FxDraggableSheet snaps to the nearest size / flings a step', (
      tester,
    ) async {
      final snaps = <int>[];
      await _pump(
        tester,
        SizedBox(
          width: 300,
          height: 400,
          child: FxDraggableSheet(
            onSnapChanged: snaps.add,
            child: const Text('Sheet'),
          ),
        ),
      );
      final handle = find.byWidgetPredicate(
        (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
      );
      // 0.3 -> ~0.55 (slow) settles on the nearest snap, 0.6.
      await tester.timedDrag(
        handle,
        const Offset(0, -120),
        const Duration(milliseconds: 800),
      );
      await tester.pumpAndSettle();
      expect(snaps, [1]);

      // A slow 60px pull (0.6 -> ~0.5) settles back on the nearest snap …
      await tester.timedDrag(
        handle,
        const Offset(0, 60),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(snaps, [1, 1]);

      // … while the same distance as a fast flick carries one snap further.
      // (Shorter flicks don't register as a fling at all: the velocity
      // tracker's last 20 samples must span more than the 18px touch slop.)
      await tester.fling(handle, const Offset(0, 60), 1500);
      await tester.pumpAndSettle();
      expect(snaps, [1, 1, 0]);

      // Upward: 0.3 -> ~0.4 is still nearest 0.3, the flick steps to 0.6.
      await tester.fling(handle, const Offset(0, -60), 1500);
      await tester.pumpAndSettle();
      expect(snaps, [1, 1, 0, 1]);
    });

    testWidgets('FxCarousel reports page changes', (tester) async {
      final pages = <int>[];
      await _pump(
        tester,
        SizedBox(
          width: 300,
          child: FxCarousel(
            onPageChanged: pages.add,
            children: [
              for (var i = 0; i < 3; i++)
                catalogSwatch(const Color(0xFF6A11CB), child: Text('P$i')),
            ],
          ),
        ),
      );
      await tester.fling(find.text('P0'), const Offset(-200, 0), 1000);
      await tester.pumpAndSettle();
      expect(pages, [1]);
    });

    testWidgets('FxFloatingField reports input and floats its label', (
      tester,
    ) async {
      final reported = <String>[];
      await _pump(
        tester,
        SizedBox(
          width: 240,
          child: FxFloatingField(label: 'Email', onChanged: reported.add),
        ),
      );
      final restingTop = tester.getTopLeft(find.text('Email')).dy;
      await tester.tap(find.byType(FxFloatingField));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Email')).dy, lessThan(restingTop));

      await tester.enterText(find.byType(EditableText), 'ada');
      await tester.pump();
      expect(reported.last, 'ada');
    });
  });

  group('painted feedback', () {
    // These widgets drive a CustomPainter through a `repaint:` notifier. The
    // checks inspect the recorded paint calls (flutter_test `paints`).
    bool circleWhere(
      Symbol method,
      List<dynamic> args,
      bool Function(double radius) test,
    ) => method == #drawCircle && test(args[1] as double);

    catalogTestWidgets(
      'FxRipple draws a growing ripple after a tap',
      (tester) async {
        await _pump(
          tester,
          const FxRipple(
            onTap: _noop,
            child: SizedBox(width: 160, height: 100),
          ),
        );
        await tester.tap(find.byType(FxRipple));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          tester.renderObject(
            find.descendant(
              of: find.byType(FxRipple),
              matching: find.byType(CustomPaint),
            ),
          ),
          paints..something((m, a) => circleWhere(m, a, (r) => r > 1)),
        );
      },
      skip:
          'BUG FxRipple: the ripple is never visible. `_RipplePainter` gets '
          '`elapsed` at build time; ticks only bump the `_frame` repaint '
          'notifier (no rebuild), so progress stays 0 and every ripple is '
          'drawn with radius 0. (The ticker also restarts from 0 on each '
          'start, while new ripples record the previous run\'s `_elapsed`.)',
    );

    catalogTestWidgets(
      'FxRippleGrid enlarges dots on the wave front after a tap',
      (tester) async {
        await _pump(
          tester,
          const SizedBox(width: 200, height: 200, child: FxRippleGrid()),
        );
        await tester.tap(find.byType(FxRippleGrid));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(
          tester.renderObject(
            find.descendant(
              of: find.byType(FxRippleGrid),
              matching: find.byType(CustomPaint),
            ),
          ),
          // Idle dots have radius dotSize / 2 = 2.5.
          paints..something((m, a) => circleWhere(m, a, (r) => r > 2.6)),
        );
      },
      skip:
          'BUG FxRippleGrid: tapping never starts a ripple. `_tap` assigns '
          '`_center` / `_maxRadius` without setState, so the painter (built '
          'once with center == null) keeps energy 0 and draws only idle dots.',
    );

    catalogTestWidgets(
      'FxFireworks sparks spread and shrink as a burst ages',
      (tester) async {
        await _pump(
          tester,
          const SizedBox(width: 200, height: 200, child: FxFireworks(seed: 1)),
        );
        // First burst spawns at ~850ms; look ~300ms into it.
        for (var i = 0; i < 24; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(
          tester.renderObject(
            find.descendant(
              of: find.byType(FxFireworks),
              matching: find.byType(CustomPaint),
            ),
          ),
          // A fresh spark has radius 2.2 and shrinks to 0 over its life.
          paints..something((m, a) => circleWhere(m, a, (r) => r < 2.1)),
        );
      },
      skip:
          'BUG FxFireworks: bursts never expand. `_FireworksPainter` gets '
          '`now` at build time; `_tick` only bumps `_frame` (no rebuild), so '
          'every repaint sees now == 0 and each burst is a single static dot '
          'at its origin (radius 2.2) until it expires.',
    );
  });

  group('FxSpinWheel', () {
    testWidgets('spin() lands on a valid segment exactly once', (tester) async {
      final controller = FxSpinWheelController();
      final results = <int>[];
      await _pump(
        tester,
        FxSpinWheel(
          items: const ['A', 'B', 'C', 'D'],
          colors: const [
            Color(0xFF6A11CB),
            Color(0xFF448AFF),
            Color(0xFFEC008C),
            Color(0xFF00C9A7),
          ],
          size: 160,
          controller: controller,
          onResult: results.add,
        ),
      );
      controller.spin();
      await tester.pump();
      controller.spin(); // ignored while spinning
      await tester.pump(const Duration(milliseconds: 3700));
      await tester.pumpAndSettle();
      expect(results, hasLength(1));
      expect(results.single, inInclusiveRange(0, 3));
    });

    catalogTestWidgets(
      'controller.spin() after the wheel is disposed is a no-op',
      (tester) async {
        final controller = FxSpinWheelController();
        await _pump(
          tester,
          FxSpinWheel(
            items: const ['A', 'B'],
            colors: const [Color(0xFF6A11CB), Color(0xFF448AFF)],
            controller: controller,
          ),
        );
        await tester.pumpWidget(const SizedBox());
        expect(controller.spin, returnsNormally);
      },
      skip:
          'BUG FxSpinWheelController: never detached. The wheel attaches '
          '`_spin` in initState but has no detach in dispose (unlike '
          'FxFlipCardController / FxSlideToConfirmController), so spin() on '
          'a disposed wheel calls forward() on a disposed AnimationController '
          'and throws.',
    );
  });
}
