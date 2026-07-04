import 'dart:math' as math;
import 'dart:ui';

import 'package:asteroids/game/asteroid.dart';
import 'package:asteroids/game/game_world.dart';
import 'package:asteroids/game/ship.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bounds = Size(800, 600);
  const centre = Offset(400, 300);
  const dt = 1 / 60;

  int rockCount(GameWorld w) => w.entities.whereType<Asteroid>().length;

  group('Wave count progression (SPEC-PROC-1, AC1)', () {
    test('formula: wave N seeds 4+(N-1) large asteroids', () {
      expect(GameWorld.waveAsteroidCount(1), 4);
      expect(GameWorld.waveAsteroidCount(2), 5);
      expect(GameWorld.waveAsteroidCount(5), 8);
    });

    test('startNextWave seeds wave 1 with four large rocks', () {
      final world = GameWorld(bounds: bounds, random: math.Random(1));

      world.startNextWave(shipPosition: centre);

      expect(world.wave, 1);
      expect(rockCount(world), 4);
      expect(
        world.entities.whereType<Asteroid>().every(
              (a) => a.size == AsteroidSize.large,
            ),
        isTrue,
      );
    });

    test('clearing the field advances to wave N+1 with one more rock', () {
      final world = GameWorld(bounds: bounds, random: math.Random(2))
        ..startNextWave(shipPosition: centre);

      // Simulate the player wiping out wave 1.
      world.entities.removeWhere((e) => e is Asteroid);

      world.update(dt);

      expect(world.wave, 2);
      expect(rockCount(world), GameWorld.waveAsteroidCount(2)); // 5
    });
  });

  group('Wave speed progression (AC2)', () {
    test('speed scale compounds by a fixed percent per wave', () {
      expect(GameWorld.waveSpeedScale(1), closeTo(1.0, 1e-9));
      expect(
        GameWorld.waveSpeedScale(2),
        closeTo(1 + GameWorld.waveSpeedGrowth, 1e-9),
      );
      expect(
        GameWorld.waveSpeedScale(3),
        closeTo(math.pow(1 + GameWorld.waveSpeedGrowth, 2).toDouble(), 1e-9),
      );
    });

    test('wave 2 rocks drift faster than wave 1 base speed', () {
      final world = GameWorld(bounds: bounds, random: math.Random(3))
        ..startNextWave(shipPosition: centre);

      // Wave 1 drifts at base speed.
      for (final rock in world.entities.whereType<Asteroid>()) {
        expect(rock.velocity.distance, closeTo(AsteroidSize.large.speed, 1e-6));
      }

      // Clear → wave 2.
      world.entities.removeWhere((e) => e is Asteroid);
      world.update(dt);

      final expected =
          AsteroidSize.large.speed * GameWorld.waveSpeedScale(2);
      for (final rock in world.entities.whereType<Asteroid>()) {
        expect(rock.velocity.distance, closeTo(expected, 1e-6));
        expect(rock.velocity.distance,
            greaterThan(AsteroidSize.large.speed)); // strictly faster
      }
    });
  });

  group('Negative: no wave switch on a non-empty field (AC3)', () {
    test('one surviving asteroid blocks the next wave', () {
      final world = GameWorld(bounds: bounds, random: math.Random(4))
        ..entities.add(Ship(position: centre))
        ..startNextWave(shipPosition: centre);

      // Knock the field down to a single remaining rock.
      final survivors = world.entities.whereType<Asteroid>().toList();
      for (var i = 1; i < survivors.length; i++) {
        world.entities.remove(survivors[i]);
      }
      expect(rockCount(world), 1);

      world.update(dt);
      world.update(dt);

      // Wave counter never advanced and no fresh wave was seeded.
      expect(world.wave, 1);
      expect(rockCount(world), 1);
    });

    test('a game-over world never advances the wave, even when cleared', () {
      final world = GameWorld(bounds: bounds, random: math.Random(5))
        ..startNextWave(shipPosition: centre);
      world.entities.removeWhere((e) => e is Asteroid);
      world.lives = 0; // force game over — simulation is frozen

      world.update(dt);

      expect(world.wave, 1);
      expect(rockCount(world), 0);
    });
  });
}
