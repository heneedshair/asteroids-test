import 'dart:ui';

import 'package:asteroids/game/asteroid.dart';
import 'package:asteroids/game/game_world.dart';
import 'package:asteroids/game/ship.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bounds = Size(800, 600);
  const centre = Offset(400, 300);
  const dt = 1 / 60;

  group('Life loss & respawn (SR-7, AC1)', () {
    test('ship↔asteroid overlap costs one life and respawns at centre', () {
      final ship = Ship(position: const Offset(100, 100));
      final world = GameWorld(bounds: bounds)
        ..entities.add(ship)
        ..entities.add(
          Asteroid(position: const Offset(100, 100), size: AsteroidSize.large),
        );

      world.update(dt);

      expect(world.lives, GameWorld.initialLives - 1);
      expect(world.shipCollided, isTrue);
      expect(ship.position, centre);
      expect(ship.velocity, Offset.zero);
    });

    test('the respawned ship is invulnerable (AC2)', () {
      final ship = Ship(position: centre);
      final world = GameWorld(bounds: bounds)
        ..entities.add(ship)
        ..entities.add(
          Asteroid(position: centre, size: AsteroidSize.large),
        );

      world.update(dt);

      expect(ship.isInvulnerable, isTrue);
    });

    test('invulnerability wears off after its duration', () {
      final ship = Ship(position: centre, respawnInvulnerability: 0.1)
        ..invulnerabilityRemaining = 0.1;
      final world = GameWorld(bounds: bounds)..entities.add(ship);

      // 0.1s of invulnerability, stepped past at 1/60s per step (~6 steps).
      for (var i = 0; i < 10; i++) {
        world.update(dt);
      }

      expect(ship.isInvulnerable, isFalse);
    });
  });

  group('Negative: no damage while invulnerable (SR-7, AC4)', () {
    test('an overlap during invulnerability keeps lives unchanged', () {
      final ship = Ship(position: centre)..invulnerabilityRemaining = 1.0;
      final world = GameWorld(bounds: bounds)
        ..entities.add(ship)
        ..entities.add(Asteroid(position: centre, size: AsteroidSize.large));

      world.update(dt);

      expect(world.lives, GameWorld.initialLives);
      expect(world.shipCollided, isFalse);
    });
  });

  group('Game over & life floor (SR-7, AC3/AC5)', () {
    test('lives reach zero → game over, ship removed, never below zero', () {
      // Zero-duration invulnerability so each overlapping step lands a hit;
      // the asteroid sits at centre so the respawned ship keeps overlapping it.
      final ship = Ship(position: centre, respawnInvulnerability: 0.0);
      final world = GameWorld(bounds: bounds)
        ..entities.add(ship)
        ..entities.add(Asteroid(position: centre, size: AsteroidSize.large));

      world.update(dt); // 3 → 2
      expect(world.lives, 2);
      world.update(dt); // 2 → 1
      expect(world.lives, 1);
      world.update(dt); // 1 → 0 : game over
      expect(world.lives, 0);
      expect(world.isGameOver, isTrue);
      expect(world.entities.whereType<Ship>(), isEmpty);

      // The frozen game-over world never drives lives below zero (AC5).
      world.update(dt);
      world.update(dt);
      expect(world.lives, 0);
    });

    test('a game-over world is frozen: asteroids stop drifting (AC3)', () {
      final asteroid = Asteroid(
        position: centre,
        size: AsteroidSize.large,
        velocity: const Offset(50, 0),
      );
      final world = GameWorld(bounds: bounds)..entities.add(asteroid);
      world.lives = 0; // force game over

      world.update(dt);

      expect(asteroid.position, centre);
    });
  });
}
