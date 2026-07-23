import 'package:flutter/widgets.dart';

/// An animated horizontal step indicator — dots joined by connectors that fill
/// as [currentStep] advances (onboarding, checkout, wizards).
///
/// ```dart
/// FxStepProgress(count: 4, currentStep: _step);
/// ```
class FxStepProgress extends StatelessWidget {
  const FxStepProgress({
    super.key,
    required this.count,
    required this.currentStep,
    this.size = 14,
    this.activeColor = const Color(0xFF448AFF),
    this.inactiveColor = const Color(0x33448AFF),
    this.duration = const Duration(milliseconds: 320),
  });

  final int count;
  final int currentStep;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < count; i++) {
      children.add(_dot(i));
      if (i < count - 1) children.add(Expanded(child: _connector(i)));
    }
    return Row(children: children);
  }

  Widget _dot(int index) {
    final active = index <= currentStep;
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? activeColor : inactiveColor,
      ),
    );
  }

  Widget _connector(int index) {
    final filled = index < currentStep ? 1.0 : 0.0;
    return SizedBox(
      height: 3,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: inactiveColor)),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: filled),
                duration: duration,
                curve: Curves.easeOut,
                builder: (context, v, child) =>
                    FractionallySizedBox(widthFactor: v, child: child),
                child: ColoredBox(color: activeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
