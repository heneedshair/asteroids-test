import 'dart:ui';

import 'entity.dart';
import 'projectile.dart';
import 'ship.dart';

/// Holds the full simulation state of the game.
///
/// This is the single source of truth for everything the renderer draws. It is
/// mutated only by the simulation ([update]); the painter reads it but must not
/// change it.
class GameWorld {
  GameWorld({this.bounds = Size.zero});

  final List<Entity> entities = <Entity>[];

  /// Current play-field size in pixels (updated on resize/layout).
  Size bounds;

  /// Advances the whole world by one fixed physics step of [dt] seconds.
  ///
  /// Called zero or more times per rendered frame by the game loop.
  void update(double dt) {
    for (final entity in entities) {
      if (entity.alive) {
        entity.update(dt, bounds);
      }
    }
    // Must run after the loop above: a projectile spawned this step must not
    // be moved/TTL-decremented on its own spawn frame.
    _spawnProjectiles();
    entities.removeWhere((e) => !e.alive);
  }

  /// Lets every live [Ship] attempt a shot, capped at [Ship.maxProjectiles]
  /// alive at once (TR-2).
  ///
  /// The cap is counted across all `ProjectileOwner.ship` projectiles in the
  /// world, not per ship instance — correct as long as at most one [Ship] is
  /// ever in [entities] (true for the current single-player game).
  void _spawnProjectiles() {
    final ships = entities.whereType<Ship>().where((s) => s.alive).toList();
    for (final ship in ships) {
      final activeCount = entities
          .whereType<Projectile>()
          .where((p) => p.alive && p.owner == ProjectileOwner.ship)
          .length;
      final projectile = ship.tryFire(activeCount);
      if (projectile != null) entities.add(projectile);
    }
  }
}
