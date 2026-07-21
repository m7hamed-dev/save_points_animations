/// Readable duration literals: `300.ms`, `1.5.seconds`, `2.minutes`.
extension FxNumDuration on num {
  /// This value as milliseconds.
  Duration get ms => Duration(microseconds: (this * 1000).round());

  /// This value as seconds (fractional supported).
  Duration get seconds => Duration(microseconds: (this * 1000 * 1000).round());

  /// Alias for [seconds].
  Duration get s => seconds;

  /// This value as minutes (fractional supported).
  Duration get minutes =>
      Duration(microseconds: (this * 60 * 1000 * 1000).round());
}
