import 'dart:math' as math;
import 'dart:ui';

import 'asteroid.dart';
import 'collision.dart';
import 'entity.dart';
import 'projectile.dart';
import 'ship.dart';

/// Holds the full simulation state of the game.
///
/// This is the single source of truth for everything the renderer draws. It is
/// mutated only by the simulation ([update]); the painter reads it but must not
/// change it.
class GameWorld {
  GameWorld({this.bounds = Size.zero, math.Random? random})
      : _random = random ?? math.Random();

  final List<Entity> entities = <Entity>[];

  /// Current play-field size in pixels (updated on resize/layout).
  Size bounds;

  final math.Random _random;

  /// Number of lives a fresh game starts with (SR-7, AC1).
  static const int initialLives = 3;

  /// Lives remaining. A ship↔asteroid hit costs one; it never drops below zero
  /// (SR-7, AC5 boundary) and reaching zero ends the game.
  int lives = initialLives;

  /// True once all lives are spent — the game-over state (SR-7, AC3). Derived
  /// from [lives] so the two can never disagree.
  bool get isGameOver => lives <= 0;

  /// Points scored this game (SR-6). Each destroyed asteroid adds its size's
  /// [AsteroidSize.points]; a ship↔asteroid collision never scores. Reset to
  /// zero when a fresh game is seeded/restarted.
  int score = 0;

  /// True when a *damaging* [Ship]↔[Asteroid] overlap was detected during the
  /// most recent [update] (i.e. one that actually cost a life). Reset to
  /// `false` at the start of every step; an overlap that hits an invulnerable
  /// ship does not set it (SR-7, AC4).
  bool shipCollided = false;

  /// Invoked once for each asteroid the moment a projectile destroys it, with
  /// the destroyed asteroid (its [Asteroid.points] carry the score value).
  /// Left as an extension seam for the scoring task (SR-6); no-op by default.
  void Function(Asteroid destroyed)? onAsteroidDestroyed;

  /// Advances the whole world by one fixed physics step of [dt] seconds.
  ///
  /// Step order follows SPEC-ARCH-1: integrate movement → detect & resolve
  /// collisions → spawn new projectiles → remove dead entities.
  ///
  /// Called zero or more times per rendered frame by the game loop.
  void update(double dt) {
    // Once the game is over the simulation freezes (SR-7, AC3): no movement,
    // no collisions, no spawns until the world is restarted.
    if (isGameOver) return;

    for (final entity in entities) {
      if (entity.alive) {
        entity.update(dt, bounds);
      }
    }
    // Collisions are resolved against the state produced by movement above,
    // before new projectiles are spawned — a bullet spawned this step waits
    // until next step to be able to hit anything, mirroring how a freshly
    // spawned projectile is not moved on its spawn frame.
    _resolveCollisions();
    _spawnProjectiles();
    entities.removeWhere((e) => !e.alive);
  }

  /// Detects circular-bound collisions (SR-5) and resolves fragmentation
  /// (SR-4 / TR-3).
  ///
  /// A projectile that overlaps an asteroid destroys both and the asteroid
  /// splits into its fragments. The `alive` guard is what upholds the negative
  /// scenario (SR-4): once an asteroid is marked dead by the first projectile
  /// this step, a second projectile overlapping the same asteroid in the same
  /// step skips it — no double fragmentation. Fragments are collected and only
  /// added after the loop, so they cannot be hit on their own birth step.
  void _resolveCollisions() {
    final asteroids = entities.whereType<Asteroid>().toList(growable: false);
    if (asteroids.isEmpty) {
      shipCollided = false;
      return;
    }

    final fragments = <Asteroid>[];
    for (final projectile in entities.whereType<Projectile>()) {
      if (!projectile.alive) continue;
      for (final asteroid in asteroids) {
        if (!asteroid.alive) continue;
        if (!circlesOverlap(projectile, asteroid)) continue;

        projectile.alive = false;
        asteroid.alive = false;
        // Scored exactly here — once per destroyed asteroid, since the `alive`
        // guard above stops a second bullet re-scoring the same rock this step
        // (SR-6; upholds the "not scored twice" negative). Ship↔asteroid hits
        // are resolved below and deliberately award nothing.
        score += asteroid.size.points;
        fragments.addAll(asteroid.split());
        onAsteroidDestroyed?.call(asteroid);
        break; // one projectile destroys exactly one asteroid (SR-4 negative).
      }
    }

    // Ship↔asteroid costs a life and respawns the ship (SR-7). A dead asteroid
    // (just fragmented) no longer counts, and an invulnerable ship shrugs the
    // hit off entirely (AC4 negative).
    shipCollided = false;
    for (final ship in entities.whereType<Ship>()) {
      if (!ship.alive || ship.isInvulnerable) continue;
      for (final asteroid in asteroids) {
        if (asteroid.alive && circlesOverlap(ship, asteroid)) {
          shipCollided = true;
          _handleShipHit(ship);
          break;
        }
      }
      if (shipCollided) break;
    }

    entities.addAll(fragments);
  }

  /// Applies one asteroid hit to [ship]: spends a life (never below zero — AC5)
  /// and either respawns the ship at the play-field centre with invulnerability
  /// (AC1/AC2) or, if that was the last life, retires the ship so the game-over
  /// state (AC3) takes hold.
  void _handleShipHit(Ship ship) {
    if (lives > 0) lives--;
    if (lives > 0) {
      ship.respawn(Offset(bounds.width / 2, bounds.height / 2));
    } else {
      ship.alive = false;
    }
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

  /// Spawns a wave of [count] large asteroids at the screen edges, each at
  /// least [safeRadius] pixels from [shipPosition] so the wave never appears
  /// on top of the player (SPEC-PROC-1: "у краёв, вне безопасного радиуса").
  ///
  /// Each asteroid drifts in a random direction at its size's base speed.
  /// Rejection-samples an edge point until one clears the safe zone; after a
  /// bounded number of tries it falls back to the farthest candidate so the
  /// spawn always terminates even on a tiny play-field.
  void spawnWave(int count, {required Offset shipPosition, double safeRadius = 150.0}) {
    for (var i = 0; i < count; i++) {
      entities.add(_spawnLargeAsteroid(shipPosition, safeRadius));
    }
  }

  Asteroid _spawnLargeAsteroid(Offset shipPosition, double safeRadius) {
    const maxTries = 16;
    var best = _randomEdgePoint();
    var bestDistSq = (best - shipPosition).distanceSquared;
    final safeSq = safeRadius * safeRadius;

    for (var attempt = 0; attempt < maxTries && bestDistSq < safeSq; attempt++) {
      final candidate = _randomEdgePoint();
      final distSq = (candidate - shipPosition).distanceSquared;
      if (distSq > bestDistSq) {
        best = candidate;
        bestDistSq = distSq;
      }
    }

    final heading = _random.nextDouble() * 2 * math.pi;
    return Asteroid(
      position: best,
      size: AsteroidSize.large,
      velocity: Offset(math.cos(heading), math.sin(heading)) *
          AsteroidSize.large.speed,
    );
  }

  /// A random point on the perimeter of the play-field.
  Offset _randomEdgePoint() {
    final w = bounds.width;
    final h = bounds.height;
    switch (_random.nextInt(4)) {
      case 0: // top
        return Offset(_random.nextDouble() * w, 0);
      case 1: // bottom
        return Offset(_random.nextDouble() * w, h);
      case 2: // left
        return Offset(0, _random.nextDouble() * h);
      default: // right
        return Offset(w, _random.nextDouble() * h);
    }
  }
}
