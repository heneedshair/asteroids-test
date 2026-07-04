/// A deterministic fixed-timestep accumulator.
///
/// This is the core of the game loop, isolated from Flutter's [Ticker] so it can
/// be unit-tested. It implements the classic "fix your timestep" pattern:
///
///  * Physics always advances in discrete steps of exactly [fixedDt] seconds,
///    regardless of how long the real render frame took. Slow frames therefore
///    run *more* steps rather than *bigger* steps — objects never tunnel through
///    each other because a single step is always small and constant.
///  * The wall-clock time between frames is clamped by [maxFrameTime] so a huge
///    stall (breakpoint, GC pause, tab backgrounded) cannot queue thousands of
///    steps and enter the "spiral of death".
///  * Leftover time is exposed as [alpha] in [0, 1) so the renderer can
///    interpolate between the previous and current physics states.
class FixedTimestep {
  FixedTimestep({
    this.fixedDt = 1.0 / 60.0,
    this.maxFrameTime = 0.25,
  })  : assert(fixedDt > 0),
        assert(maxFrameTime >= fixedDt);

  /// Seconds simulated per physics step.
  final double fixedDt;

  /// Upper bound on the real time consumed by a single frame, in seconds.
  final double maxFrameTime;

  double _accumulator = 0.0;

  /// Leftover fraction of a step after the last [advance], in [0, 1).
  double get alpha => _accumulator / fixedDt;

  /// Feeds [frameTime] (real seconds since the previous frame) into the
  /// accumulator and returns how many fixed physics steps should run now.
  ///
  /// Pure with respect to the world: the caller runs the returned number of
  /// steps. This keeps the timing math trivially testable.
  int advance(double frameTime) {
    if (frameTime.isNaN || frameTime <= 0) return 0;

    // Clamp to avoid the spiral of death on a very long frame.
    final clamped = frameTime > maxFrameTime ? maxFrameTime : frameTime;

    _accumulator += clamped;

    var steps = 0;
    while (_accumulator >= fixedDt) {
      _accumulator -= fixedDt;
      steps++;
    }
    return steps;
  }

  /// Resets accumulated time, e.g. when the loop is (re)started.
  void reset() => _accumulator = 0.0;
}
