import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';

import 'package:save_points_animations_example/widgets/demo_chip.dart';

/// An interactive playground: pick effects, timing, direction and mode, watch
/// the result, and copy the chain that produces it.
class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

typedef _NamedCurve = ({String name, Curve curve});

const List<_NamedCurve> _curves = [
  (name: 'FxCurves.emphasized', curve: FxCurves.emphasized),
  (name: 'FxCurves.snappy', curve: FxCurves.snappy),
  (name: 'FxCurves.smooth', curve: FxCurves.smooth),
  (name: 'FxCurves.elastic', curve: FxCurves.elastic),
  (name: 'FxCurves.bounce', curve: FxCurves.bounce),
  (name: 'Curves.linear', curve: Curves.linear),
];

enum _Effect {
  fade('.fade()'),
  slideFromStart('.slideFromStart()'),
  moveY('.moveY(40)'),
  scale('.scale(begin: 0.6)'),
  rotate('.rotate(25)'),
  blur('.blur()');

  const _Effect(this.code);
  final String code;
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  final Set<_Effect> _effects = {_Effect.fade, _Effect.slideFromStart};
  double _durationMs = 600;
  double _delayMs = 0;
  int _curve = 0;
  bool _rtl = false;
  bool _loop = false;
  bool _targetMode = false;
  bool _selected = false;
  int _replay = 0;
  int _completions = 0;

  Duration get _duration => Duration(milliseconds: _durationMs.round());
  Duration get _delay => Duration(milliseconds: _delayMs.round());

  FxBuilder _chain() {
    var fx = const DemoChip(color: Colors.indigo).animate(
      duration: _duration,
      delay: _targetMode ? null : _delay,
      curve: _curves[_curve].curve,
      target: _targetMode ? (_selected ? 1 : 0) : null,
      onComplete: () => setState(() => _completions++),
    );
    for (final effect in _Effect.values) {
      if (!_effects.contains(effect)) continue;
      fx = switch (effect) {
        _Effect.fade => fx.fade(),
        _Effect.slideFromStart => fx.slideFromStart(distance: 1),
        _Effect.moveY => fx.moveY(40),
        _Effect.scale => fx.scale(begin: 0.6),
        _Effect.rotate => fx.rotate(25),
        _Effect.blur => fx.blur(),
      };
    }
    if (_loop && !_targetMode) fx = fx.looping(mirror: true);
    return fx;
  }

  String _code() {
    final args = <String>[
      'duration: ${_duration.inMilliseconds}.ms',
      if (!_targetMode && _delay > Duration.zero)
        'delay: ${_delay.inMilliseconds}.ms',
      'curve: ${_curves[_curve].name}',
      if (_targetMode) 'target: selected ? 1 : 0',
    ];
    final buffer = StringBuffer('child\n    .animate(${args.join(', ')})');
    for (final effect in _Effect.values) {
      if (_effects.contains(effect)) buffer.write('\n    ${effect.code}');
    }
    if (_loop && !_targetMode) buffer.write('\n    .looping(mirror: true)');
    buffer.write(';');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Playground')),
      floatingActionButton: _targetMode
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _selected = !_selected),
              icon: Icon(_selected ? Icons.undo : Icons.play_arrow),
              label: Text(_selected ? 'target: 0' : 'target: 1'),
            )
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _replay++),
              icon: const Icon(Icons.replay),
              label: const Text('Replay'),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
        children: [
          SizedBox(
            height: 200,
            child: Center(
              child: Directionality(
                textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
                // A new key restarts the chain from scratch: on "Replay", and
                // when switching between playing, looping and target modes.
                child: KeyedSubtree(
                  key: ValueKey((_replay, _loop, _targetMode)),
                  child: _chain(),
                ),
              ),
            ),
          ),
          Text(
            'Completed $_completions time${_completions == 1 ? '' : 's'}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final effect in _Effect.values)
                FilterChip(
                  label: Text(effect.code),
                  selected: _effects.contains(effect),
                  onSelected: (on) => setState(
                    () => on ? _effects.add(effect) : _effects.remove(effect),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Duration: ${_duration.inMilliseconds}ms'),
          Slider(
            value: _durationMs,
            min: 100,
            max: 2000,
            divisions: 19,
            label: '${_duration.inMilliseconds}ms',
            onChanged: (v) => setState(() => _durationMs = v),
          ),
          if (!_targetMode) ...[
            Text('Delay: ${_delay.inMilliseconds}ms'),
            Slider(
              value: _delayMs,
              max: 1000,
              divisions: 10,
              label: '${_delay.inMilliseconds}ms',
              onChanged: (v) => setState(() => _delayMs = v),
            ),
          ],
          DropdownButton<int>(
            value: _curve,
            isExpanded: true,
            items: [
              for (var i = 0; i < _curves.length; i++)
                DropdownMenuItem(value: i, child: Text(_curves[i].name)),
            ],
            onChanged: (v) => setState(() => _curve = v ?? 0),
          ),
          SwitchListTile(
            title: const Text('Right-to-left'),
            subtitle: const Text('slideFromStart() enters from the right'),
            value: _rtl,
            onChanged: (v) => setState(() => _rtl = v),
          ),
          SwitchListTile(
            title: const Text('State-driven (target)'),
            subtitle: const Text('Animate toward a value instead of playing'),
            value: _targetMode,
            onChanged: (v) => setState(() {
              _targetMode = v;
              _selected = false;
            }),
          ),
          if (!_targetMode)
            SwitchListTile(
              title: const Text('Loop (mirrored)'),
              value: _loop,
              onChanged: (v) => setState(() => _loop = v),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              _code(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
