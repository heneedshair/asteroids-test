import 'dart:math' as math;
import 'dart:ui';

import 'package:asteroids/game/asteroid.dart';
import 'package:asteroids/game/collision.dart';
import 'package:asteroids/game/entity.dart';
import 'package:asteroids/game/game_world.dart';
import 'package:asteroids/game/projectile.dart';
import 'package:asteroids/game/ship.dart';
import 'package:flutter_test/flutter_test.dart';

/// A projectile placed exactly on top of [target] so it collides on the next
/// step. Uses a large TTL so it survives the step under test.
Projectile _bulletAt(Offset position) => Projectile(
      position: position,
      velocity: Offset.zero,
      owner: ProjectileOwner.ship,
      timeToLive: 10,
    );

void main() {
  const bounds = Size(800, 600);

  group('Fragmentation (TR-3 AC1)', () {
    test('large asteroid splits into two medium', () {
      final asteroid =
          Asteroid(position: const Offset(400, 300), size: AsteroidSize.large);
      final world = GameWorld(bounds: bounds)
        ..entities.add(asteroid)
        ..entities.add(_bulletAt(const Offset(400, 300)));

      world.update(1 / 60);

      final rocks = world.entities.whereType<Asteroid>().toList();
      expect(rocks, hasLength(2));
      expect(rocks.every((a) => a.size == AsteroidSize.medium), isTrue);
    });

    test('medium asteroid splits into two small', () {
      final asteroid =
          Asteroid(position: const Offset(400, 300), size: AsteroidSize.medium);
      final world = GameWorld(bounds: bounds)
        ..entities.add(asteroid)
        ..entities.add(_bulletAt(const Offset(400, 300)));

      world.update(1 / 60);

      final rocks = world.entities.whereType<Asteroid>().toList();
      expect(rocks, hasLength(2));
      expect(rocks.every((a) => a.size == AsteroidSize.small), isTrue);
    });

    test('small asteroid is destroyed without fragments', () {
      final asteroid =
          Asteroid(position: const Offset(400, 300), size: AsteroidSize.small);
      final world = GameWorld(bounds: bounds)
        ..entities.add(asteroid)
        ..entities.add(_bulletAt(const Offset(400, 300)));

      world.update(1 / 60);

      expect(world.entities.whereType<Asteroid>(), isEmpty);
      expect(world.entities.whereType<Projectile>(), isEmpty);
    });
  });

  group('Fragment kinematics (TR-3 AC2)', () {
    test('fragments inherit parent position and diverge', () {
      final parent = Asteroid(
        position: const Offset(400, 300),
        size: AsteroidSize.large,
        velocity: const Offset(50, 0),
      );

      final fragments = parent.split();

      expect(fragments, hasLength(2));
      for (final f in fragments) {
        expect(f.position, parent.position);
        expect(f.velocity.distance, greaterThan(0));
      }
      // Diverging: the two headings are not identical.
      final a0 = math.atan2(fragments[0].velocity.dy, fragments[0].velocity.dx);
      final a1 = math.atan2(fragments[1].velocity.dy, fragments[1].velocity.dx);
      expect(a0, isNot(closeTo(a1, 1e-6)));
    });

    test('a stationary parent still produces separating fragments', () {
      final parent =
          Asteroid(position: const Offset(10, 10), size: AsteroidSize.medium);

      final fragments = parent.split();

      expect(fragments, hasLength(2));
      expect(fragments[0].velocity, isNot(fragments[1].velocity));
    });
  });

  group('Collision detection (SR-5, AC3)', () {
    test('ship↔asteroid overlap is detected by circular bounds', () {
      final ship = Ship(position: const Offset(400, 300));
      final asteroid =
          Asteroid(position: const Offset(410, 300), size: AsteroidSize.large);
      final world = GameWorld(bounds: bounds)
        ..entities.add(ship)
        ..entities.add(asteroid);

      world.update(1 / 60);

      expect(world.shipCollided, isTrue);
    });
  });

  group('Negative: no double fragmentation (SR-4)', () {
    test('two bullets hitting one asteroid in the same step split it once', () {
      final asteroid =
          Asteroid(position: const Offset(400, 300), size: AsteroidSize.large);
      final world = GameWorld(bounds: bounds)
        ..entities.add(asteroid)
        ..entities.add(_bulletAt(const Offset(400, 300)))
        ..entities.add(_bulletAt(const Offset(400, 300)));

      world.update(1 / 60);

      // Large → exactly two medium (not four), and one bullet survives because
      // only one was consumed.
      final rocks = world.entities.whereType<Asteroid>().toList();
      expect(rocks, hasLength(2));
      expect(rocks.every((a) => a.size == AsteroidSize.medium), isTrue);
      expect(world.entities.whereType<Projectile>(), hasLength(1));
    });
  });

  group('Negative: bounding overlap without circle overlap (SR-5)', () {
    test('sharing a bounding box but not circles is not a collision', () {
      // Ship at origin, asteroid diagonally offset so their bounding boxes
      // overlap but the centre distance exceeds the summed radii.
      final ship = Entity(position: const Offset(0, 0), radius: 14);
      final asteroid = Asteroid(
        position: Offset(14 + 40 + 5, 14 + 40 + 5),
        size: AsteroidSize.large, // radius 40
      );

      expect(circlesOverlap(ship, asteroid), isFalse);
    });

    test('overlapping circles are a collision', () {
      final a = Entity(position: const Offset(0, 0), radius: 14);
      final b = Entity(position: const Offset(10, 0), radius: 14);
      expect(circlesOverlap(a, b), isTrue);
    });
  });

  group('Wave spawn (SPEC-PROC-1)', () {
    test('initial wave spawns the requested count outside the safe radius', () {
      final world = GameWorld(bounds: bounds, random: math.Random(42));
      const ship = Offset(400, 300);

      world.spawnWave(4, shipPosition: ship, safeRadius: 150);

      final rocks = world.entities.whereType<Asteroid>().toList();
      expect(rocks, hasLength(4));
      expect(rocks.every((a) => a.size == AsteroidSize.large), isTrue);
      for (final rock in rocks) {
        expect((rock.position - ship).distance, greaterThanOrEqualTo(150));
      }
    });
  });
}
