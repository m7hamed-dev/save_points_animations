# Contributing

Thanks for your interest in improving Save Points Animations!

## Getting started

```bash
flutter pub get
flutter test
```

## Before opening a PR

Please make sure all of these pass (they mirror CI):

```bash
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze lib test
flutter test --exclude-tags golden
```

## Adding an effect

1. Create a class extending `FxEffect` in `lib/src/effects/`. Implement
   `apply(FxAccumulator acc, double t)` (t is already eased) and
   `copyWithTiming(...)`.
2. Contribute to the shared `Matrix4` / opacity where possible so effects keep
   collapsing into a single `Transform` / `Opacity` (see the performance
   contract in `prompt.enhanced.md` §0.2).
3. Add a fluent method on `FxBuilder` and, if it's a common one-shot, mirror it
   on the `Widget` extension.
4. Add a unit test (assert the accumulator contribution) and, ideally, a golden
   at a fixed `t`.

## Golden tests

Golden images are platform-sensitive and tagged `golden`. Regenerate them on
your machine after intentional visual changes:

```bash
flutter test --update-goldens --tags golden
```

## Style

- Follow `flutter_lints` (the analyzer must be clean).
- Prefer composition over inheritance; keep effects immutable value objects.
- Document public API with dartdoc comments.
