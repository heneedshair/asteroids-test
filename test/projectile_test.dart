import 'dart:ui';

import 'package:asteroids/game/game_world.dart';
import 'package:asteroids/game/projectile.dart';
import 'package:asteroids/game/ship.dart';
import 'package:asteroids/input/input_adapter.dart';
import 'package:asteroids/input/input_command.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test double whose reported [state] can be swapped between steps to script
/// player input.
class FakeInput implements InputAdapter {
  FakeInput([this._state = InputState.idle]);

  InputState _state;

  void set(InputState state) => _state = state;

  @override
  InputState get state => _state;

  @override
  void dispose() {}
}

void main() {
  const bounds = Size(800, 600);

  group('Firing (TR-2 AC1)', () {
    test('fire spawns a projectile from the ship nose along its heading', () {
      final input = FakeInput(const InputState(fire: true));
      final world = GameWorld(bounds: bounds);
      final ship = Ship(
        position: const Offset(400, 300),
        input: input,
        angle: 0,
        velocity: const Offset(20, 0),
        projectileSpeed: 500,
      );
      world.entities.add(ship);

      world.update(1 / 60);

      final projectiles = world.entities.whereType<Projectile>().toList();
      expect(projectiles, hasLength(1));
      final bullet = projectiles.single;
      expect(bullet.owner, ProjectileOwner.ship);
      // Heading is +x at angle 0: nose sits ahead of the ship's centre.
      expect(bullet.position.dx, greaterThan(ship.position.dx));
      expect(bullet.position.dy, closeTo(ship.position.dy, 1e-9));
      // Bullet speed sums the ship's own velocity with the muzzle speed.
      expect(bullet.velocity.dx, closeTo(520, 1e-9));
    });

    test('a projectile does not move on the frame it spawns', () {
      // GameWorld.update() must run the entity-update loop before spawning,
      // so a bullet created this step isn't itself moved/TTL-decremented
      // until the next fixed step.
      final input = FakeInput(const InputState(fire: true));
      final world = GameWorld(bounds: bounds);
      final ship = Ship(
        position: const Offset(400, 300),
        input: input,
        angle: 0,
      );
      world.entities.add(ship);

      world.update(1 / 60);

      final bullet = world.entities.whereType<Projectile>().single;
      // Ship never thrusted, so its position is unchanged; the bullet must
      // still sit exactly at the nose, not one dt further along its velocity.
      expect(bullet.position, ship.position + Offset(ship.radius, 0));
    });

    test('releasing fire stops new projectiles from spawning', () {
      final input = FakeInput(InputState.idle);
      final world = GameWorld(bounds: bounds);
      world.entities.add(Ship(position: const Offset(400, 300), input: input));

      world.update(1 / 60);

      expect(world.entities.whereType<Projectile>(), isEmpty);
    });
  });

  group('Lifetime (TR-2 AC2)', () {
    test('a projectile despawns once its time to live runs out', () {
      final projectile = Projectile(
        position: const Offset(0, 0),
        velocity: const Offset(100, 0),
        owner: ProjectileOwner.ship,
        timeToLive: 0.05,
      );
      final world = GameWorld(bounds: bounds);
      world.entities.add(projectile);

      world.update(0.03);
      expect(world.entities, contains(projectile));

      world.update(0.03);
      expect(world.entities, isEmpty);
    });
  });

  group('Negative scenario: projectile limit (TR-2 AC3)', () {
    test('holding fire past the limit does not create new projectiles once capped', () {
      final input = FakeInput(const InputState(fire: true));
      final world = GameWorld(bounds: bounds);
      final ship = Ship(
        position: const Offset(400, 300),
        input: input,
        maxProjectiles: 2,
      );
      world.entities.add(ship);

      // Two steps fill the cap.
      world.update(1 / 60);
      world.update(1 / 60);
      final capped = world.entities.whereType<Projectile>().toList();
      expect(capped, hasLength(2));

      // Ten more steps (~0.17s, comfortably under the default 1.2s TTL, so
      // none of these expire) while still holding fire must not add a third
      // projectile or swap out the two already alive — proving the cap
      // blocks new spawns rather than the population size merely coinciding
      // with the limit.
      for (var i = 0; i < 10; i++) {
        world.update(1 / 60);
      }
      final afterHolding = world.entities.whereType<Projectile>().toList();
      expect(afterHolding, hasLength(2));
      expect(afterHolding, containsAll(capped));
    });

    test('a ship already at the limit yields a null shot, not an error', () {
      final input = FakeInput(const InputState(fire: true));
      final ship = Ship(
        position: const Offset(400, 300),
        input: input,
        maxProjectiles: 1,
      );

      expect(ship.tryFire(1), isNull);
      expect(() => ship.tryFire(1), returnsNormally);
    });
  });
}
