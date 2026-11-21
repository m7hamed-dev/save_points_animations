import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';

/// Every [FxGlowStyle] on a button, a card and an avatar, with a color, the
/// spread and light/dark to play with.
class GlowScreen extends StatefulWidget {
  const GlowScreen({super.key});

  @override
  State<GlowScreen> createState() => _GlowScreenState();
}

const List<(String, Color)> _colors = [
  ('Violet', Color(0xFF6C5CE7)),
  ('Blue', Color(0xFF0984E3)),
  ('Mint', Color(0xFF00B894)),
  ('Pink', Color(0xFFFF4D9D)),
  ('Amber', Color(0xFFFFA726)),
];

class _GlowScreenState extends State<GlowScreen> {
  FxGlowStyle _style = FxGlowStyle.aurora;
  Color _color = _colors.first.$2;
  double _spread = 18;
  bool _dark = true;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorSchemeSeed: Colors.indigo,
      brightness: _dark ? Brightness.dark : Brightness.light,
    );
    return AnimatedTheme(
      data: theme,
      child: Builder(builder: _buildScreen),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      // Glows read best on a deep background.
      backgroundColor: _dark
          ? const Color(0xFF0D0E14)
          : const Color(0xFFF2F1F7),
      appBar: AppBar(
        title: const Text('Glow'),
        actions: [
          IconButton(
            tooltip: _dark ? 'Light mode' : 'Dark mode',
            icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _dark = !_dark),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 52,
            child: ListView(
              key: const ValueKey('styles'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              children: [
                for (final style in FxGlowStyle.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(style.name),
                      selected: _style == style,
                      onSelected: (_) => setState(() => _style = style),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
        child: Column(
          children: [
            Wrap(
              spacing: 64,
              runSpacing: 64,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _glow(
                  borderRadius: 28,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Get Pro'),
                  ),
                ),
                _glow(borderRadius: 20, child: _card(scheme)),
                _glow(
                  shape: BoxShape.circle,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: _color,
                    foregroundColor: Colors.white,
                    child: const Text(
                      'AT',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 72),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final (name, color) in _colors)
                  ChoiceChip(
                    avatar: CircleAvatar(backgroundColor: color),
                    label: Text(name),
                    selected: _color == color,
                    onSelected: (_) => setState(() => _color = color),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Row(
                children: [
                  const Text('Spread'),
                  Expanded(
                    child: Slider(
                      value: _spread,
                      max: 36,
                      divisions: 12,
                      label: _spread.round().toString(),
                      onChanged: (value) => setState(() => _spread = value),
                    ),
                  ),
                ],
              ),
            ),
            if (_style == FxGlowStyle.hover)
              Text(
                'Point at a sample with the mouse, or press it.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }

  Widget _glow({
    required Widget child,
    double borderRadius = 16,
    BoxShape shape = BoxShape.rectangle,
  }) => FxGlow(
    style: _style,
    color: _color,
    spread: _spread,
    borderRadius: borderRadius,
    shape: shape,
    child: child,
  );

  Widget _card(ColorScheme scheme) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _dark ? const Color(0xFF1A1C25) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: _color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask AI',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Summarize this thread',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
