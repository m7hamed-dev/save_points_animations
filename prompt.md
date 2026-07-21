# Flutter FX - Professional Animation Extensions Package

## Role

Act as a **Senior Flutter Framework Engineer** with **10+ years of experience** in Flutter SDK, Dart, rendering pipeline, implicit/explicit animations, package architecture, API design, developer experience (DX), performance optimization, and open-source package development.

Your goal is to design and implement a **production-ready Flutter package** that provides an elegant, powerful, extensible, and developer-friendly animation framework using Extension Methods and a Fluent Builder API.

The final package should be suitable for publishing on **pub.dev** and should follow Flutter and Dart best practices.

---

# Main Objective

Build a Flutter package that allows developers to animate any widget using a beautiful and expressive API like:

```dart
Text("Hello")
    .animate()
    .fade()
    .moveY(50)
    .scale()
    .rotate(15)
    .duration(600.ms)
    .delay(200.ms)
    .curve(Curves.easeOutBack);
```

or

```dart
Container()
    .fadeIn()
    .slideFromBottom()
    .scaleIn();
```

The package should combine the simplicity of extension methods with the flexibility of a complete animation engine.

---

# Design Philosophy

The package must prioritize:

- Clean API
- Minimal boilerplate
- Readable syntax
- High performance
- Extensibility
- Composition over inheritance
- Immutable configuration
- Type safety
- Null safety
- Flutter best practices
- Production-ready architecture

Every animation should be chainable.

Everything should feel natural to Flutter developers.

---

# Core Principles

## Simplicity

Simple animations should require one line.

Example:

```dart
Text("Welcome").fadeIn();
```

---

## Flexibility

Complex animations should also be possible.

Example:

```dart
Image.asset("logo.png")
    .animate()
    .fade()
    .moveX(-100)
    .moveY(50)
    .rotate(15)
    .scale(begin: .5)
    .delay(300.ms)
    .duration(800.ms)
    .curve(Curves.elasticOut);
```

---

## Extensibility

Developers should be able to create their own custom effects without modifying the package.

Example:

```dart
class SwingEffect extends FxEffect {}
```

---

# Architecture

Follow a modular architecture.

```
lib/

    flutter_fx.dart

    src/

        core/

        animation_engine/

        builders/

        controllers/

        extensions/

        effects/

        transitions/

        presets/

        widgets/

        utilities/

        enums/

        mixins/

        painters/

        physics/

        themes/

        debug/

        timeline/

        examples/
```

---

# Package Layers

## Core

Contains:

- configuration
- shared constants
- animation settings
- defaults
- utilities

---

## Engine

Responsible for:

- animation lifecycle
- ticker management
- controller creation
- scheduling
- synchronization
- timeline execution
- effect composition

---

## Effects

Each animation is represented as an independent effect.

Examples:

- FadeEffect
- ScaleEffect
- RotateEffect
- MoveEffect
- SlideEffect
- BlurEffect
- ColorEffect
- OpacityEffect
- ShakeEffect
- BounceEffect
- FlipEffect
- SkewEffect

Every effect should inherit from:

```dart
abstract class FxEffect
```

---

## Builder API

Support fluent chaining.

Example:

```dart
Container()
    .animate()
    .fade()
    .moveY()
    .scale()
    .rotate()
    .delay()
    .duration()
    .curve();
```

---

# Extension Methods

Provide expressive extensions.

Examples:

```dart
.fadeIn()

.fadeOut()

.scaleIn()

.scaleOut()

.slideFromBottom()

.slideFromTop()

.slideFromLeft()

.slideFromRight()

.rotate()

.flipX()

.flipY()

.shake()

.bounce()

.pulse()

.elastic()

.zoom()

.blur()

.glow()

.float()

.wobble()

.swing()

.flash()

.heartbeat()

.jelly()

.rubberBand()

.tada()

.attention()
```

---

# Timeline System

Support sequential animations.

Example:

```dart
.animate()
.fade()
.then()
.scale()
.then()
.rotate();
```

---

Support parallel animations.

```dart
.animate()
.parallel(
    FadeEffect(),
    ScaleEffect(),
    RotateEffect(),
);
```

---

Support intervals.

```dart
.interval(100.ms)
```

---

# Presets

Include predefined professional animations.

Examples:

```dart
.success()

.error()

.warning()

.loading()

.attention()

.heroEntry()

.heroExit()

.dialog()

.tooltip()

.toast()

.snackbar()

.cardEntry()

.listItem()

.pageTransition()

.modal()

.popup()

.emptyState()

.onboarding()

.fab()

.notification()
```

---

# Animation Triggers

Support automatic triggers.

```dart
.onTap()

.onDoubleTap()

.onLongPress()

.onHover()

.onFocus()

.onVisible()

.onScroll()

.onAppear()

.onDisappear()

.onStateChanged()
```

---

# Physics Animations

Support spring animations.

Example:

```dart
.spring(
    stiffness: 300,
    damping: 15,
    mass: 1,
)
```

---

Support:

- spring
- bounce
- gravity
- friction
- velocity
- inertia

---

# Animation Controller

Expose a controller.

```dart
FxController controller;
```

Capabilities:

```dart
play()

pause()

resume()

restart()

reverse()

stop()

repeat()

seek()

reset()

dispose()
```

---

# Global Theme

Allow global animation configuration.

Example:

```dart
FxTheme(
    duration: 300.ms,
    curve: Curves.easeOut,
    delay: Duration.zero,
);
```

---

# Duration Extensions

Provide readable duration syntax.

```dart
100.ms

500.ms

1.seconds

2.seconds

3.minutes
```

---

# Curves Library

Provide custom curves.

```dart
FxCurves.soft

FxCurves.snappy

FxCurves.spring

FxCurves.smooth

FxCurves.bounce

FxCurves.elastic

FxCurves.fastOut

FxCurves.flutter

FxCurves.material
```

---

# List Animations

Support stagger animations.

```dart
items
    .animateList()
    .fade()
    .slideY()
    .interval(80.ms);
```

---

# Page Transitions

Provide page transition builders.

Examples:

- FadeTransition
- SharedAxis
- ScaleTransition
- CupertinoTransition
- MaterialTransition
- ZoomTransition
- SlideTransition

---

# Hero Animations

Support Hero enhancements.

```dart
.heroAnimate()
```

---

# Visibility Detection

Automatically animate when entering viewport.

```dart
.animateOnVisible()
```

---

# Gesture Animations

Examples:

```dart
.pressScale()

.hoverScale()

.pressBounce()

.dragScale()

.swipeRotate()
```

---

# Debug Tools

Provide development helpers.

```dart
.showTimeline()

.showBounds()

.showFPS()

.showControllers()

.showPerformance()
```

---

# Performance Requirements

The package must:

- avoid unnecessary rebuilds
- minimize widget tree depth
- use RepaintBoundary where appropriate
- support Impeller
- support Flutter Web
- support Desktop
- support Mobile
- support Material 3
- support Cupertino
- maintain 60–120 FPS
- avoid memory leaks
- dispose controllers properly

---

# Testing

Provide:

- Unit Tests
- Widget Tests
- Golden Tests
- Performance Tests
- Integration Tests

Coverage should exceed **95%**.

---

# Documentation

Generate complete documentation including:

- API Reference
- Getting Started
- Installation
- Architecture
- Examples
- Best Practices
- Migration Guide
- FAQ
- Cookbook
- Performance Guide

---

# Examples

Provide complete example applications.

Examples:

- Login Screen
- Dashboard
- Ecommerce
- Social Feed
- Onboarding
- Splash Screen
- Settings
- Chat
- Profile
- Cards
- ListView
- GridView

---

# Code Standards

Follow:

- Effective Dart
- Flutter Lints
- SOLID
- Clean Architecture principles where applicable
- Composition over inheritance
- Immutable models
- Null Safety
- Const constructors
- Generic APIs
- Type-safe builders

---

# Pub.dev Readiness

The package should include:

- CHANGELOG.md
- LICENSE
- README.md
- CONTRIBUTING.md
- CODE_OF_CONDUCT.md
- example/
- screenshots/
- benchmarks/
- GitHub Actions CI
- semantic versioning
- complete pub.dev scoring optimization

---

# Inspiration

Take inspiration from (without copying):

- flutter_animate
- simple_animations
- animations
- flutter_staggered_animations
- rive
- lottie
- motion
- Framer Motion
- GSAP
- SwiftUI Animation APIs
- Jetpack Compose Animation APIs

The final result should feel like a **next-generation animation framework for Flutter**, offering a fluent, extensible, highly performant, and delightful developer experience while remaining intuitive for both beginners and advanced Flutter developers.
