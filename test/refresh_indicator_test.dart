import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

// FxRefreshIndicator keeps Material RefreshIndicator's mechanics, so most of
// these mirror its behavior; the rest cover the styles, theming and
// accessibility. Built on package:flutter/widgets.dart only: the indicator
// must not need a Material ancestor.

const _lightText = Color(0xFF222222);
const _darkText = Color(0xFFEEEEEE);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  bool dark = false,
  bool reduceMotion = false,
}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Directionality(
      textDirection: direction,
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 14, color: dark ? _darkText : _lightText),
        child: ColoredBox(
          color: dark ? const Color(0xFF101014) : const Color(0xFFF4F4F6),
          child: child,
        ),
      ),
    ),
  );
}

Widget _list({
  ScrollController? controller,
  ScrollPhysics? physics,
  void Function(int index)? onTap,
}) {
  return ListView.builder(
    controller: controller,
    physics: physics,
    itemCount: 40,
    itemBuilder: (context, i) => GestureDetector(
      onTap: onTap == null ? null : () => onTap(i),
      child: SizedBox(height: 50, child: Text('Item $i')),
    ),
  );
}

/// Drags the list down by [dy] in small steps, one frame each, and lets go
/// unless [hold].
Future<TestGesture> _pull(
  WidgetTester tester,
  double dy, {
  bool hold = false,
  Offset? from,
}) async {
  final gesture = await tester.startGesture(
    from ?? tester.getCenter(find.byType(ListView)),
  );
  for (var moved = 0.0; moved < dy; moved += 10) {
    await gesture.moveBy(const Offset(0, 10));
    await tester.pump(const Duration(milliseconds: 16));
  }
  if (!hold) await gesture.up();
  return gesture;
}

/// Pumps [ms] milliseconds as 16ms frames. A ticker takes its start time from
/// its first frame, so one long pump would not advance an animation that
/// starts during it.
Future<void> _frames(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 16) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// The default test surface is 800x600, so the trigger point is at 100px of
/// pull (a quarter of the viewport, over 1.5).
const _past = 200.0;
const _short = 40.0;

void main() {
  late List<FxRefreshStatus?> statuses;
  late int refreshes;
  late Completer<void> refresh;

  setUp(() {
    statuses = [];
    refreshes = 0;
    refresh = Completer<void>();
  });

  // A new completer per call, made inside the test's fake-async zone: one made
  // in setUp would complete on the real event loop, which pump() never runs.
  Future<void> onRefresh() {
    refreshes++;
    return (refresh = Completer<void>()).future;
  }

  Widget indicator({
    Key? key,
    FxRefreshStyle? style = FxRefreshStyle.ring,
    FxRefreshTriggerMode triggerMode = FxRefreshTriggerMode.onEdge,
    ScrollNotificationPredicate notificationPredicate =
        defaultScrollNotificationPredicate,
    bool enableFeedback = true,
    String? semanticsLabel,
    String? semanticsValue,
    Widget? child,
  }) {
    return FxRefreshIndicator(
      key: key,
      style: style,
      onRefresh: onRefresh,
      onStatusChange: statuses.add,
      triggerMode: triggerMode,
      notificationPredicate: notificationPredicate,
      enableFeedback: enableFeedback,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
      child: child ?? _list(),
    );
  }

  testWidgets('pulling past the trigger point runs onRefresh and walks '
      'through every status', (tester) async {
    await tester.pumpWidget(_host(indicator()));
    await _pull(tester, _past);
    await _frames(tester, 300);
    expect(refreshes, 1);
    expect(statuses, [
      FxRefreshStatus.drag,
      FxRefreshStatus.armed,
      FxRefreshStatus.snap,
      FxRefreshStatus.refresh,
    ]);

    refresh.complete();
    await tester.pumpAndSettle();
    expect(statuses.skip(4), [FxRefreshStatus.done, null]);
    expect(refreshes, 1);
  });

  testWidgets('a pull short of the trigger point cancels', (tester) async {
    await tester.pumpWidget(_host(indicator()));
    await _pull(tester, _short);
    await tester.pumpAndSettle();
    expect(refreshes, 0);
    expect(statuses, [FxRefreshStatus.drag, FxRefreshStatus.canceled, null]);
  });

  testWidgets('keeps refreshing until the future completes', (tester) async {
    await tester.pumpWidget(_host(indicator()));
    await _pull(tester, _past);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(statuses.last, FxRefreshStatus.refresh);

    refresh.complete();
    await tester.pump();
    expect(statuses.last, FxRefreshStatus.done);
    await tester.pumpAndSettle();
    expect(statuses.last, isNull);
  });

  testWidgets('show() refreshes from code; its future completes with '
      'onRefresh', (tester) async {
    final key = GlobalKey<FxRefreshIndicatorState>();
    await tester.pumpWidget(_host(indicator(key: key)));

    var shown = false;
    unawaited(key.currentState!.show().then((_) => shown = true));
    await tester.pump();
    await _frames(tester, 300);
    expect(refreshes, 1);
    expect(statuses, [FxRefreshStatus.snap, FxRefreshStatus.refresh]);

    // A second call while refreshing joins the running refresh.
    unawaited(key.currentState!.show());
    await _frames(tester, 300);
    expect(refreshes, 1);
    expect(shown, isFalse);

    refresh.complete();
    await tester.pump();
    expect(shown, isTrue);
    await tester.pumpAndSettle();
    expect(statuses.last, isNull);
  });

  testWidgets('works with bouncing (iOS) physics', (tester) async {
    await tester.pumpWidget(
      _host(
        indicator(
          child: _list(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
        ),
      ),
    );
    // Bouncing overscroll has friction, so the finger travels further.
    await _pull(tester, 450, from: const Offset(400, 100));
    await _frames(tester, 600);
    expect(refreshes, 1);
    expect(statuses, contains(FxRefreshStatus.refresh));
    refresh.complete();
    await tester.pumpAndSettle();
    expect(statuses.last, isNull);
  });

  testWidgets('ignores horizontal scrollables', (tester) async {
    await tester.pumpWidget(
      _host(
        indicator(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < 20; i++)
                SizedBox(width: 100, child: Text('Item $i')),
            ],
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(const Offset(400, 300));
    for (var i = 0; i < 20; i++) {
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(statuses, isEmpty);
    expect(refreshes, 0);
  });

  testWidgets('notificationPredicate filters the scrollables', (tester) async {
    await tester.pumpWidget(
      _host(indicator(notificationPredicate: (_) => false)),
    );
    await _pull(tester, _past);
    await tester.pumpAndSettle();
    expect(statuses, isEmpty);
    expect(refreshes, 0);
  });

  for (final mode in FxRefreshTriggerMode.values) {
    testWidgets(
      'a drag from mid-list ${mode == FxRefreshTriggerMode.anywhere ? 'refreshes' : 'does not refresh'} '
      'with triggerMode.${mode.name}',
      (tester) async {
        final controller = ScrollController(initialScrollOffset: 60);
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          _host(
            indicator(
              triggerMode: mode,
              child: _list(controller: controller),
            ),
          ),
        );
        await _pull(tester, 60 + _past);
        await _frames(tester, 300);
        expect(refreshes, mode == FxRefreshTriggerMode.anywhere ? 1 : 0);
        if (!refresh.isCompleted) refresh.complete();
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('plays one light haptic tick at the trigger point', (
    tester,
  ) async {
    final haptics = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    for (final feedback in [true, false]) {
      haptics.clear();
      await tester.pumpWidget(_host(indicator(enableFeedback: feedback)));
      await _pull(tester, _past);
      expect(haptics, [if (feedback) 'HapticFeedbackType.lightImpact']);
      await _frames(tester, 300);
      refresh.complete();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('under reduced motion it holds a still frame and skips the '
      'finish animation', (tester) async {
    await tester.pumpWidget(
      _host(
        indicator(
          // No overscroll glow, so only the indicator could be animating.
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: _list(),
          ),
        ),
        reduceMotion: true,
      ),
    );
    await _pull(tester, _past);
    await tester.pump();
    await tester.pump();
    expect(statuses.last, FxRefreshStatus.refresh);
    expect(tester.hasRunningAnimations, isFalse);

    refresh.complete();
    await tester.pump();
    await tester.pump();
    expect(statuses.last, isNull);
  });

  testWidgets('does not block taps on the list while refreshing', (
    tester,
  ) async {
    final tapped = <int>[];
    await tester.pumpWidget(_host(indicator(child: _list(onTap: tapped.add))));
    await _pull(tester, _past);
    await _frames(tester, 300);
    expect(statuses.last, FxRefreshStatus.refresh);

    // Item 1 sits right under the resting indicator.
    await tester.tapAt(const Offset(400, 75));
    expect(tapped, [1]);
    refresh.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('unmounting while refreshing is safe', (tester) async {
    await tester.pumpWidget(_host(indicator()));
    await _pull(tester, _past);
    await _frames(tester, 300);
    await tester.pumpWidget(const SizedBox());
    refresh.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('is announced as "Refresh", or semanticsLabel / Value', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(indicator()));
    final gesture = await _pull(tester, _past, hold: true);
    expect(find.semantics.byLabel('Refresh'), findsOne);
    await gesture.up();
    await _frames(tester, 300);
    refresh.complete();
    await tester.pumpAndSettle();
    expect(find.semantics.byLabel('Refresh'), findsNothing);

    await tester.pumpWidget(
      _host(indicator(semanticsLabel: 'Reload inbox', semanticsValue: '3 new')),
    );
    final again = await _pull(tester, _past, hold: true);
    expect(
      find.semantics.byLabel('Reload inbox'),
      isSemantics(label: 'Reload inbox', value: '3 new'),
    );
    await again.up();
    await _frames(tester, 300);
    refresh.complete();
    await tester.pumpAndSettle();
    handle.dispose();
  });

  group('capsule', () {
    testWidgets('its label follows the status', (tester) async {
      await tester.pumpWidget(_host(indicator(style: FxRefreshStyle.capsule)));
      final gesture = await _pull(tester, _short, hold: true);
      await _frames(tester, 400);
      expect(find.text('Pull to refresh'), findsOne);

      for (var i = 0; i < 16; i++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await _frames(tester, 400);
      expect(find.text('Release to refresh'), findsOne);
      expect(find.text('Pull to refresh'), findsNothing);

      await gesture.up();
      await _frames(tester, 200);
      await _frames(tester, 400);
      expect(find.text('Refreshing…'), findsOne);

      refresh.complete();
      await tester.pump();
      await _frames(tester, 400);
      expect(find.text('Updated'), findsOne);
      await tester.pumpAndSettle();
      expect(find.text('Updated'), findsNothing);
    });

    for (final dark in [false, true]) {
      testWidgets('its label meets WCAG AA contrast '
          '(${dark ? 'dark' : 'light'})', (tester) async {
        await tester.pumpWidget(
          _host(indicator(style: FxRefreshStyle.capsule), dark: dark),
        );
        await _pull(tester, _short, hold: true);
        await _frames(tester, 400);
        final label = find.text('Pull to refresh');
        final text = tester.widget<Text>(label).style!.color!;
        final surface = tester
            .widgetList<DecoratedBox>(
              find.ancestor(of: label, matching: find.byType(DecoratedBox)),
            )
            .map((box) => (box.decoration as BoxDecoration).color)
            .firstWhere((color) => color != null)!;
        expect(_contrast(text, surface), greaterThanOrEqualTo(4.5));
      });
    }
  });

  group('FxRefreshTheme', () {
    testWidgets('supplies the style and labels', (tester) async {
      await tester.pumpWidget(
        _host(
          FxRefreshTheme(
            style: FxRefreshStyle.capsule,
            labels: const FxRefreshLabels(pull: 'Tirez pour actualiser'),
            child: indicator(style: null),
          ),
        ),
      );
      await _pull(tester, _short, hold: true);
      await _frames(tester, 400);
      expect(find.text('Tirez pour actualiser'), findsOne);
    });

    testWidgets('loses to the indicator arguments', (tester) async {
      await tester.pumpWidget(
        _host(
          FxRefreshTheme(
            style: FxRefreshStyle.capsule,
            child: indicator(style: FxRefreshStyle.dots),
          ),
        ),
      );
      await _pull(tester, _short, hold: true);
      await _frames(tester, 400);
      expect(find.text('Pull to refresh'), findsNothing);
    });
  });

  test('FxRefreshLabels compares by value', () {
    expect(
      const FxRefreshLabels(pull: 'a'),
      FxRefreshLabels(pull: String.fromCharCode(97)),
    );
    expect(const FxRefreshLabels(), isNot(const FxRefreshLabels(done: 'OK')));
  });

  testWidgets('.fxRefreshIndicator() wraps the child', (tester) async {
    await tester.pumpWidget(
      _host(
        _list().fxRefreshIndicator(
          style: FxRefreshStyle.line,
          onRefresh: onRefresh,
          onStatusChange: statuses.add,
        ),
      ),
    );
    await _pull(tester, _past);
    await _frames(tester, 300);
    expect(refreshes, 1);
    refresh.complete();
    await tester.pumpAndSettle();
    expect(statuses.last, isNull);
  });

  // Every style through a full cycle on small and large screens, and in a
  // dark, right-to-left setting.
  group('every style', () {
    const sizes = {
      'small phone': Size(320, 480),
      'phone': Size(390, 844),
      'tablet': Size(820, 1180),
      'desktop': Size(1440, 900),
    };
    final settings = [
      for (final MapEntry(key: name, value: size) in sizes.entries)
        (name, size, TextDirection.ltr, false),
      ('phone, dark, RTL', sizes['phone']!, TextDirection.rtl, true),
    ];
    for (final style in FxRefreshStyle.values) {
      for (final (name, size, direction, dark) in settings) {
        testWidgets('${style.name} on a $name', (tester) async {
          tester.view
            ..devicePixelRatio = 1
            ..physicalSize = size;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            _host(
              indicator(style: style),
              direction: direction,
              dark: dark,
            ),
          );
          await _pull(tester, size.height * 0.3);
          for (var i = 0; i < 30; i++) {
            await tester.pump(const Duration(milliseconds: 50));
          }
          expect(refreshes, 1);
          refresh.complete();
          await tester.pumpAndSettle();
          expect(statuses, [
            FxRefreshStatus.drag,
            FxRefreshStatus.armed,
            FxRefreshStatus.snap,
            FxRefreshStatus.refresh,
            FxRefreshStatus.done,
            null,
          ]);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}

/// The WCAG contrast ratio of two opaque colors.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}
