import 'dart:ui';

import 'entity.dart';

/// Who fired a projectile — later tasks use this to decide who it can hit
/// (e.g. a ship's own bullets must not collide with the ship).
enum ProjectileOwner { ship, ufo }

/// A single shot fired by the ship (or, in a later task, a UFO).
///
/// Travels in a straight line at constant velocity and expires once
/// [timeToLive] runs out, independent of any collision system. This is a
/// time-based proxy for range: at a given speed, a fixed [timeToLive]
/// corresponds to a fixed travel distance.
class Projectile extends Entity {
  Projectile({
    required super.position,
    required super.velocity,
    required this.owner,
    this.timeToLive = 1.2,
    super.radius = 2.0,
  });

  /// Who fired this projectile.
  final ProjectileOwner owner;

  /// Remaining seconds before the projectile despawns.
  double timeToLive;

  @override
  void update(double dt, Size bounds) {
    timeToLive -= dt;
    if (timeToLive <= 0) {
      alive = false;
      return;
    }
    super.update(dt, bounds);
  }
}
