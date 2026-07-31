import 'package:flutter/material.dart';
import 'package:save_points_animations/save_points_animations.dart';

import 'package:save_points_animations_example/detail_screen.dart';
import 'package:save_points_animations_example/widgets/demo_chip.dart';

part 'sections/effects_section.dart';
part 'sections/text_media_section.dart';
part 'sections/controls_section.dart';
part 'sections/nav_charts_section.dart';
part 'sections/widgets_section.dart';
part 'sections/more_section.dart';
part 'sections/inputs_new_section.dart';

/// Nav items reused across the bottom bar and the nav-bar demos.
const List<FxNavItem> _navItems = [
  FxNavItem(icon: Icon(Icons.home), label: 'Home'),
  FxNavItem(icon: Icon(Icons.search), label: 'Search'),
  FxNavItem(icon: Icon(Icons.favorite), label: 'Likes'),
  FxNavItem(icon: Icon(Icons.person), label: 'Profile'),
];

/// Base date for the date-strip demo.
final DateTime _dayBase = DateTime(2026, 7, 20);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FxController _card = FxController();
  final FxConfettiController _confetti = FxConfettiController();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  bool _showBanner = true;
  int _rating = 3;
  double _progress = 0.4;
  int _score = 1234;
  int _segment = 0;
  bool _menuOpen = false;
  bool _toggle = true;
  int _step = 1;
  bool _liked = false;
  FxButtonState _btnState = FxButtonState.idle;
  int _navIndex = 0;
  bool _checked = true;
  int _tab = 0;
  int _pin = 2;
  int _radio = 0;
  final Set<int> _chips = {0};
  final FxSpinWheelController _wheel = FxSpinWheelController();
  double _slider = 0.4;
  int _qty = 1;
  bool _toast = false;
  Color _wheelColor = const Color(0xFFE91E63);
  DateTime _day = DateTime(2026, 7, 22);
  FxRange _range = const FxRange(0.2, 0.7);
  int _carousel = 0;
  bool _playing = true;
  String _pinEntry = '';
  int? _reaction = 1;
  int _wizard = 1;
  int _wheel2 = 1;
  bool _dark = false;
  bool _busy = false;

  /// Wraps [setState] so the section extensions in the `part` files can request
  /// a rebuild without touching the protected [setState] directly.
  void update(VoidCallback fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Save Points Animations V 1.0',
        ).animate().fade().slideY(-0.5).duration(400.ms),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _card.restart,
        label: const Text('Replay card'),
        icon: const Icon(Icons.refresh),
      ).animate().scale().curve(FxCurves.elastic),
      bottomNavigationBar: FxPillNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          FxNavItem(icon: Icon(Icons.home), label: 'Home'),
          FxNavItem(icon: Icon(Icons.search), label: 'Search'),
          FxNavItem(icon: Icon(Icons.favorite), label: 'Likes'),
          FxNavItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              ...effects(context),
              ...textMedia(context),
              ...controls(context),
              ...navCharts(context),
              ...widgetsGallery(context),
              ...more(context),
              ...inputsNew(context),
            ],
          ),
          FxToast(
            visible: _toast,
            icon: const Icon(Icons.check_circle),
            onTap: () => setState(() => _toast = false),
            child: Text('Added $_qty item${_qty == 1 ? '' : 's'} to cart'),
          ),
          FxScrollToTop(controller: _scrollController),
          FxLoadingOverlay(visible: _busy, message: 'Saving…'),
          // Demo-only: tap anywhere to dismiss the overlay.
          if (_busy)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _busy = false),
              ),
            ),
        ],
      ),
    );
  }
}
