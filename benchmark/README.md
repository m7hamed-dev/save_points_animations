# Benchmarks & performance validation

Two layers, matching the performance contract in `prompt.enhanced.md` §11.

## 1. Smoke benchmark (CI-runnable)

`test/benchmark/stagger_benchmark_test.dart` builds 200 staggered animated
tiles, pumps the animation, and prints build + per-frame timing. Hard
assertions cover correctness (all tiles build, settle, and dispose with no
leaked tickers); the printed timing is informational, since wall-clock in CI is
noisy.

```bash
flutter test --tags benchmark
```

Typical local output:

```
[benchmark] 200 tiles — initial build ~215ms, avg pump ~4ms/frame
```

It is tagged `benchmark`, runs in CI as part of the normal suite, and can be
run on its own with `--tags benchmark`.

## 2. On-device frame timing + Impeller (manual)

Real frame timings require a physical device in profile mode. See
`example/integration_test/perf_test.dart`:

```bash
cd example

# Frame timings while scrolling the animated showcase:
flutter test integration_test/perf_test.dart --profile

# Validate correct rendering under Impeller:
flutter test integration_test/perf_test.dart --profile --enable-impeller
```

The test wraps a scripted scroll in `binding.traceAction(...)`, producing a
timeline you can summarize (raster/UI thread frame times, jank count) with the
`flutter_driver` timeline helpers.
