import 'dart:math';

import 'package:flutter/material.dart';

import '../game/entity.dart';
import '../game/game_controller.dart';
import '../game/game_painter.dart';

/// Full-screen host for the game: owns the [Ticker] (via [GameController]) and
/// binds a [CustomPaint] to it. This is the boundary between the Flutter widget
/// tree and the engine.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GameController _controller;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController(vsync: this);
  }

  /// Populates the empty scene with a few moving demo entities once we know the
  /// real play-field size. Real spawning logic comes in later tasks.
  void _seed(Size size) {
    if (_seeded) return;
    _seeded = true;

    _controller.world.bounds = size;
    final rng = Random(42);
    for (var i = 0; i < 6; i++) {
      final speed = 40 + rng.nextDouble() * 80;
      final dir = rng.nextDouble() * pi * 2;
      _controller.world.entities.add(
        Entity(
          position: Offset(
            rng.nextDouble() * size.width,
            rng.nextDouble() * size.height,
          ),
          velocity: Offset(cos(dir), sin(dir)) * speed,
          angularVelocity: (rng.nextDouble() - 0.5) * 2,
          radius: 12 + rng.nextDouble() * 16,
        ),
      );
    }
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          // Seed after this frame so we don't mutate during layout.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _seed(size);
            _controller.world.bounds = size;
          });
          return CustomPaint(
            size: size,
            painter: GamePainter(_controller),
          );
        },
      ),
    );
  }
}
