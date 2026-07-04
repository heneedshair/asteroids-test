import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/game_world.dart';
import '../game/highscore_store.dart';
import '../game/ship.dart';
import '../input/composite_input_adapter.dart';
import '../input/input_command.dart';
import '../input/keyboard_input_adapter.dart';
import '../input/touch_input_adapter.dart';
import '../game/game_painter.dart';
import 'touch_controls.dart';

/// Full-screen host for the game: owns the [Ticker] (via [GameController]) and
/// binds a [CustomPaint] to it. This is the boundary between the Flutter widget
/// tree and the engine.
///
/// It owns both [InputAdapter]s (keyboard + touch) and fuses them with a
/// [CompositeInputAdapter], so the ship reads the OR of the two devices. There
/// is no "active device" to steal: a key held on the keyboard stays effective
/// even while touch buttons are used, and vice-versa.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final GameController _controller;
  final KeyboardInputAdapter _keyboard = KeyboardInputAdapter();
  final TouchInputAdapter _touch = TouchInputAdapter();
  late final CompositeInputAdapter _input =
      CompositeInputAdapter([_keyboard, _touch]);
  final FocusNode _focusNode = FocusNode();

  /// Owns the persisted best score; displayed in the game-over overlay and
  /// updated once per game when the run ends (SR-6).
  final HighscoreService _highscore =
      HighscoreService(const SharedPrefsHighscoreStore());

  bool _seeded = false;

  /// Guards the once-per-game high-score submit: the controller notifies every
  /// frame, but the current run's score must be offered to storage only once
  /// when the game first enters the game-over state.
  bool _scoreSubmitted = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController(vsync: this);
    _controller.addListener(_onFrame);
    WidgetsBinding.instance.addObserver(this);
    // Best-effort: pull the stored record so the overlay can show it. A failure
    // degrades to "no record yet" inside the service; refresh the UI on load.
    _highscore.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  /// Per-frame hook driven by the controller. Submits the final score to the
  /// high-score store exactly once, the moment the game ends.
  void _onFrame() {
    if (_controller.world.isGameOver && !_scoreSubmitted) {
      _scoreSubmitted = true;
      _highscore.submit(_controller.world.score).then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  /// Spawns the player ship centred in the play field and an opening wave of
  /// asteroids once we know the real size. Wave *progression* (new waves as
  /// rocks clear) is a later task; this only seeds the starting field so the
  /// lives/game-over loop is actually playable.
  void _seed(Size size) {
    if (_seeded) return;
    _seeded = true;

    _controller.world.bounds = size;
    _populate(size);
    _controller.start();
  }

  /// Adds a fresh ship at the centre plus an opening asteroid wave. Shared by
  /// the initial seed and by [_restart].
  void _populate(Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    _controller.world.entities.add(Ship(position: centre, input: _input));
    _controller.world.spawnWave(4, shipPosition: centre);
  }

  /// Resets the world after game over (SR-7, AC3): clears the field, restores
  /// full lives, and repopulates ship + asteroids.
  void _restart() {
    final world = _controller.world;
    world.entities.clear();
    world.lives = GameWorld.initialLives;
    world.shipCollided = false;
    world.score = 0;
    _scoreSubmitted = false;
    _populate(world.bounds);
  }

  /// Feeds key events to the keyboard adapter. Bound keys are marked handled;
  /// anything else (Esc, Tab, …) is left for the framework to route.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    return _keyboard.handleKeyEvent(event)
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  void _onTouch(InputCommand command, bool pressed) {
    if (pressed) {
      _touch.press(command);
    } else {
      _touch.release(command);
    }
  }

  /// Releases all held input when the app is no longer in the foreground.
  ///
  /// A finger or key held while the app is backgrounded may never deliver its
  /// release event, so we clear both adapters to guarantee no phantom input
  /// survives (protects the "no self-motion without input" contract).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _keyboard.reset();
      _touch.releaseAll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onFrame);
    _controller.dispose();
    _keyboard.dispose();
    _touch.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060A),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        // Clear held keys if focus is lost so nothing stays "stuck down".
        onFocusChange: (hasFocus) {
          if (!hasFocus) _keyboard.reset();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _seed(size);
              _controller.world.bounds = size;
            });
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    size: size,
                    painter: GamePainter(_controller),
                  ),
                ),
                Positioned.fill(
                  child: TouchControls(onCommand: _onTouch),
                ),
                // Lives HUD + game-over overlay both depend on live world state,
                // so they rebuild off the controller's per-frame notifications.
                Positioned.fill(
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) => _Hud(
                      world: _controller.world,
                      highscore: _highscore.best,
                      onRestart: _restart,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The overlay layer: a lives counter that always shows and, once the game is
/// over, a full-screen "GAME OVER" panel that restarts on tap (SR-7, AC3).
class _Hud extends StatelessWidget {
  const _Hud({
    required this.world,
    required this.highscore,
    required this.onRestart,
  });

  final GameWorld world;

  /// Best score persisted across launches (SR-6). `0` until it loads.
  final int highscore;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Non-interactive so it never swallows touches meant for the on-screen
        // controls sitting beneath this layer.
        Positioned(
          top: 16,
          left: 16,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SCORE  ${world.score}', style: _hudTextStyle),
                const SizedBox(height: 4),
                Text('LIVES  ${world.lives}', style: _hudTextStyle),
              ],
            ),
          ),
        ),
        if (world.isGameOver)
          Positioned.fill(
            child: GestureDetector(
              onTap: onRestart,
              child: Container(
                color: const Color(0xCC05060A),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GAME OVER',
                      style: TextStyle(
                        color: Color(0xFF7CF6FF),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SCORE  ${world.score}',
                      style: const TextStyle(
                        color: Color(0xFFE8ECF2),
                        fontSize: 22,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'BEST  $highscore',
                      style: const TextStyle(
                        color: Color(0xFFB9C0CC),
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap to restart',
                      style: TextStyle(color: Color(0xFFB9C0CC), fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  static const TextStyle _hudTextStyle = TextStyle(
    color: Color(0xFF7CF6FF),
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
  );
}
