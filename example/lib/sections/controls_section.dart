part of '../home_screen.dart';

extension _ControlsSection on _HomeScreenState {
  List<Widget> controls(BuildContext context) {
    final theme = Theme.of(context);
    return [
      const SizedBox(height: 32),
      Text('Hold · Skeleton · Radio', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      Row(
        children: [
          FxHoldButton(
            onConfirmed: () {},
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(child: FxSkeletonText()),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            FxAnimatedRadio<int>(
              value: i,
              groupValue: _radio,
              onChanged: (v) => update(() => _radio = v),
            ),
            const SizedBox(width: 4),
            Text('Option $i'),
            const SizedBox(width: 16),
          ],
        ],
      ),

      const SizedBox(height: 32),
      Text('Avatars · Tabs · PIN', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      FxAvatarStack(
        avatars: [
          for (final c in [
            Colors.pink,
            Colors.teal,
            Colors.amber,
            Colors.indigo,
          ])
            ColoredBox(color: c),
        ],
      ),
      const SizedBox(height: 12),
      FxAnimatedTabBar(
        tabs: const ['Overview', 'Activity', 'Settings'],
        selectedIndex: _tab,
        onChanged: (i) => update(() => _tab = i),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          FxPinDots(length: 4, filled: _pin),
          OutlinedButton(
            onPressed: () => update(() => _pin = (_pin + 1) % 5),
            child: const Text('Type'),
          ),
        ],
      ),

      const SizedBox(height: 32),
      Text('Checkbox · Timeline · DotGrid', style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),

      Row(
        children: [
          FxAnimatedCheckbox(
            value: _checked,
            onChanged: (v) => update(() => _checked = v),
          ),
          const SizedBox(width: 12),
          const Text('Animated checkbox'),
        ],
      ),
      const SizedBox(height: 12),
      const FxTimeline(
        items: [
          Text('Order placed'),
          Text('Shipped'),
          Text('Out for delivery'),
          Text('Delivered'),
        ],
      ),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: .circular(16),
        child: SizedBox(
          height: 90,
          width: double.infinity,
          child: FxDotGrid(
            child: Center(
              child: Text('Dot grid', style: theme.textTheme.titleLarge),
            ),
          ),
        ),
      ),
    ];
  }
}
