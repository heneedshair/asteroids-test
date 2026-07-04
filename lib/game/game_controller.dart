import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'game_loop.dart';
import 'game_world.dart';

/// Drives the simulation from a Flutter [Ticker] and notifies listeners
/// (the painter) once per rendered frame.
///
/// Responsibilities:
///  * translate the [Ticker]'s cumulative elapsed time into per-frame deltas,
///  * pump the [FixedTimestep] accumulator and step the [GameWorld],
///  * expose the interpolation [alpha] and act as the repaint [Listenable].
///
/// It never draws anything — that is the painter's job.
class GameController extends ChangeNotifier {
  GameController({
    required TickerProvider vsync,
    GameWorld? world,
    FixedTimestep? timestep,
  })  : world = world ?? GameWorld(),
        _timestep = timestep ?? FixedTimestep() {
    _ticker = vsync.createTicker(_onTick);
  }

  final GameWorld world;
  final FixedTimestep _timestep;

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  double _alpha = 0.0;

  /// Interpolation factor in [0, 1) for the current frame.
  double get alpha => _alpha;

  /// Whether the loop is currently running.
  bool get isRunning => _ticker.isActive;

  /// Starts (or resumes) the loop.
  void start() {
    if (_ticker.isActive) return;
    _lastElapsed = Duration.zero;
    _timestep.reset();
    _ticker.start();
  }

  /// Pauses the loop without disposing it.
  void stop() {
    if (!_ticker.isActive) return;
    _ticker.stop();
  }

  void _onTick(Duration elapsed) {
    // First tick establishes the baseline; no time has passed yet.
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final frameSeconds =
        (elapsed - _lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;

    final steps = _timestep.advance(frameSeconds);
    for (var i = 0; i < steps; i++) {
      world.update(_timestep.fixedDt);
    }

    _alpha = _timestep.alpha;

    // Trigger a repaint for this frame (even a zero-step frame still animates
    // interpolation forward, keeping motion smooth).
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
