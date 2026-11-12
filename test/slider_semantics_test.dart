import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: SizedBox(width: 300, child: child)),
);

/// The semantics of an adjustable node: Flutter asserts that a node with an
/// increase/decrease action and a `value` also carries the value the action
/// would produce, so building these with semantics enabled is itself a test.
SemanticsData _node(String value) =>
    find.semantics.byValue(value).evaluate().single.getSemanticsData();

void main() {
  group('FxAnimatedSlider semantics', () {
    testWidgets('announces the increased and decreased values', (tester) async {
      final handle = tester.ensureSemantics();
      double? changed;
      await tester.pumpWidget(
        _host(FxAnimatedSlider(value: 0.5, onChanged: (v) => changed = v)),
      );

      final data = _node('0.50');
      expect(data.increasedValue, '0.60');
      expect(data.decreasedValue, '0.40');

      tester.semantics.increase(find.semantics.byValue('0.50'));
      expect(changed, closeTo(0.6, 1e-9));
      handle.dispose();
    });

    testWidgets('clamps the announced values at the track ends', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(FxAnimatedSlider(value: 100, max: 100, onChanged: (_) {})),
      );

      final data = _node('100');
      expect(data.increasedValue, '100');
      expect(data.decreasedValue, '90');
      handle.dispose();
    });
  });

  group('FxRangeSlider semantics', () {
    testWidgets('each thumb announces values bounded by the other thumb', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      FxRange? changed;
      await tester.pumpWidget(
        _host(
          FxRangeSlider(
            values: const FxRange(20, 80),
            max: 100,
            onChanged: (v) => changed = v,
          ),
        ),
      );

      final start = _node('20.00');
      expect(start.increasedValue, '25.00');
      expect(start.decreasedValue, '15.00');

      final end = _node('80.00');
      expect(end.increasedValue, '85.00');
      expect(end.decreasedValue, '75.00');

      tester.semantics.decrease(find.semantics.byValue('80.00'));
      expect(changed?.start, 20);
      expect(changed?.end, closeTo(75, 1e-9));
      handle.dispose();
    });

    testWidgets('collapsed thumbs cannot announce crossing each other', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          FxRangeSlider(
            values: const FxRange(0, 0),
            max: 100,
            onChanged: (_) {},
          ),
        ),
      );

      // Both thumbs sit at 0: the start thumb can't pass the end thumb, and
      // the end thumb can't drop below the start thumb.
      final thumbs = find.semantics
          .byValue('0.00')
          .evaluate()
          .map((n) => n.getSemanticsData())
          .toList();
      expect(thumbs, hasLength(2));
      expect(
        thumbs.map((d) => '${d.decreasedValue}/${d.increasedValue}').toSet(),
        {'0.00/0.00', '0.00/5.00'},
      );
      handle.dispose();
    });
  });
}
