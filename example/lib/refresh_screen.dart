import 'dart:ui' show PointerDeviceKind;

import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';

/// Pull-to-refresh in each [FxRefreshStyle] on a real list: every refresh
/// fetches a message. Light/dark and LTR/RTL switch locally, so the screen
/// shows how the indicators follow the theme and the text direction. The text
/// styles draw a word picked from a second row of chips.
class RefreshScreen extends StatefulWidget {
  const RefreshScreen({super.key});

  @override
  State<RefreshScreen> createState() => _RefreshScreenState();
}

typedef _Message = ({int id, String sender, String text, String time});

const List<_Message> _inbox = [
  (
    id: 0,
    sender: 'Ava Thompson',
    text: 'Design review moved to Thursday',
    time: '9:40',
  ),
  (id: 1, sender: 'Omar Haddad', text: 'Invoice #2048 is ready', time: '9:12'),
  (
    id: 2,
    sender: 'Lena Fischer',
    text: 'New comment on the roadmap',
    time: '8:55',
  ),
  (
    id: 3,
    sender: 'Kenji Mori',
    text: 'Weekly summary: 12 tasks done',
    time: '8:30',
  ),
  (
    id: 4,
    sender: 'Sara Ali',
    text: 'Can we move the sync to 3pm?',
    time: 'Mon',
  ),
  (
    id: 5,
    sender: 'Diego Ruiz',
    text: 'Shared “Q3 launch plan” with you',
    time: 'Mon',
  ),
  (id: 6, sender: 'Mia Chen', text: 'Build #311 passed', time: 'Sun'),
  (id: 7, sender: 'Noah Smith', text: 'Thanks for the quick fix!', time: 'Sun'),
];

const List<(String, String)> _incoming = [
  ('Release bot', 'v2.4.0 is live'),
  ('Ava Thompson', 'Notes from the design review'),
  ('Support', 'Ticket #812 was resolved'),
  ('Kenji Mori', 'Lunch at 1?'),
];

const _arabicLabels = FxRefreshLabels(
  pull: 'اسحب للتحديث',
  release: 'أفلت للتحديث',
  refreshing: 'جارٍ التحديث…',
  done: 'تم التحديث',
);

/// The styles that draw a word, and some words to try in them.
const _wordStyles = {
  FxRefreshStyle.textFill,
  FxRefreshStyle.textWave,
  FxRefreshStyle.textShimmer,
};
const _words = ['savyo', 'hunger', 'تحديث'];

class _RefreshScreenState extends State<RefreshScreen> {
  final _indicator = GlobalKey<FxRefreshIndicatorState>();
  final List<_Message> _messages = [..._inbox];
  FxRefreshStyle _style = FxRefreshStyle.ring;
  String _word = _words.first;
  bool _dark = false;
  bool _rtl = false;
  int _fetched = 0;

  /// Stands in for a network call: waits, then adds one message on top.
  Future<void> _reload() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    final (sender, text) = _incoming[_fetched % _incoming.length];
    setState(() {
      _messages.insert(0, (
        id: _inbox.length + _fetched,
        sender: sender,
        text: text,
        time: 'now',
      ));
      _fetched++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorSchemeSeed: Colors.indigo,
      brightness: _dark ? Brightness.dark : Brightness.light,
    );
    return AnimatedTheme(
      data: theme,
      child: Directionality(
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Builder(builder: _buildScreen),
      ),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wordy = _wordStyles.contains(_style);
    // App-wide defaults would usually sit in MaterialApp.builder.
    final screen = FxRefreshTheme(
      color: scheme.primary,
      labels: _rtl ? _arabicLabels : null,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_rtl ? 'السحب للتحديث' : 'Pull to refresh'),
          actions: [
            IconButton(
              tooltip: 'Refresh from code',
              icon: const Icon(Icons.refresh),
              onPressed: () => _indicator.currentState?.show(),
            ),
            IconButton(
              tooltip: _dark ? 'Light mode' : 'Dark mode',
              icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _dark = !_dark),
            ),
            IconButton(
              tooltip: _rtl ? 'Left to right' : 'Right to left',
              icon: Icon(
                _rtl
                    ? Icons.format_textdirection_l_to_r
                    : Icons.format_textdirection_r_to_l,
              ),
              onPressed: () => setState(() => _rtl = !_rtl),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(wordy ? 104 : 52),
            child: Column(
              children: [
                _chips(
                  key: const ValueKey('styles'),
                  values: FxRefreshStyle.values,
                  label: (style) => style.name,
                  selected: _style,
                  onSelected: (style) => setState(() => _style = style),
                ),
                // The text styles draw a word: pick one to try.
                if (wordy)
                  _chips(
                    key: const ValueKey('words'),
                    values: _words,
                    label: (word) => word,
                    selected: _word,
                    onSelected: (word) => setState(() => _word = word),
                  ),
              ],
            ),
          ),
        ),
        body: FxRefreshIndicator(
          key: _indicator,
          style: _style,
          text: _word,
          onRefresh: _reload,
          child: ListView(
            // Pullable even when the list is shorter than the screen.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final m in _messages)
                KeyedSubtree(
                  key: ValueKey(m.id),
                  child: _tile(context, m, isNew: m.id >= _inbox.length),
                ),
            ],
          ),
        ),
      ),
    );
    // On desktop a list scrolls by touch and trackpad only; let a mouse drag
    // pull the list and scroll the style chips too, so every style can be
    // tried there.
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: screen,
    );
  }

  /// A row of choice chips, one per value, that scrolls sideways.
  Widget _chips<T>({
    required Key key,
    required List<T> values,
    required String Function(T value) label,
    required T selected,
    required ValueChanged<T> onSelected,
  }) {
    return SizedBox(
      height: 52,
      child: ListView(
        key: key,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        children: [
          for (final value in values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(label(value)),
                selected: selected == value,
                onSelected: (_) => onSelected(value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, _Message m, {required bool isNew}) {
    final scheme = Theme.of(context).colorScheme;
    final tile = ListTile(
      leading: CircleAvatar(
        backgroundColor: isNew ? scheme.primary : scheme.primaryContainer,
        foregroundColor: isNew ? scheme.onPrimary : scheme.onPrimaryContainer,
        child: Text(m.sender[0]),
      ),
      title: Text(m.sender),
      subtitle: Text(m.text),
      trailing: Text(m.time, style: Theme.of(context).textTheme.labelSmall),
    );
    // Fetched messages drop in from above; the rest keep still.
    return isNew ? tile.animate().fade().slideY(-0.4) : tile;
  }
}
