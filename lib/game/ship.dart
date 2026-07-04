import 'dart:math' as math;
import 'dart:ui';

import '../input/input_adapter.dart';
import '../input/input_command.dart';
import 'entity.dart';
import 'projectile.dart';

/// The player-controlled ship.
///
/// Physics is a thin layer on top of [Entity]: each step the ship samples its
/// [input] adapter and translates held commands into angular velocity (turning)
/// and thrust (acceleration along the current heading). Movement, integration
/// and screen wrap-around are all inherited from [Entity.update].
///
/// Design invariants that back the acceptance criteria:
///  * Angular velocity is *set* from input every step, never accumulated — so
///    releasing the turn keys stops rotation instantly and no input means
///    exactly zero angular velocity (no self-spin).
///  * Thrust only adds to [velocity] while held; once released the existing
///    velocity carries the ship on inertia.
///  * Left + right held together resolve to a net-zero turn via
///    [InputState.turnDirection].
class Ship extends Entity {
  Ship({
    required super.position,
    this.input,
    this.turnRate = 3.2,
    this.thrustAccel = 220.0,
    this.friction = 0.0,
    this.maxSpeed = 400.0,
    this.projectileSpeed = 500.0,
    this.maxProjectiles = 4,
    this.respawnInvulnerability = 2.0,
    super.velocity,
    super.angle = -math.pi / 2,
    super.radius = 14.0,
  }) : assert(
          maxProjectiles > 0,
          'maxProjectiles must be positive '
          '(dev-time check only — a release build that somehow constructs '
          'maxProjectiles <= 0 still fails safe: activeCount >= maxProjectiles '
          'is then always true, so tryFire permanently returns null instead '
          'of throwing or firing unbounded).',
        );

  /// Source of player intent. May be null (e.g. in a headless/demo state), in
  /// which case the ship simply coasts on its current velocity.
  InputAdapter? input;

  /// Turn speed in radians per second when a single direction is held.
  final double turnRate;

  /// Forward acceleration in pixels per second squared while thrusting.
  final double thrustAccel;

  /// Linear damping per second in `[0, 1]`. `0` = frictionless (pure inertia,
  /// classic Asteroids); small positive values bleed off speed over time.
  final double friction;

  /// Upper bound on linear speed in pixels per second.
  final double maxSpeed;

  /// Speed added to the ship's own velocity along its heading when firing.
  final double projectileSpeed;

  /// Maximum number of this ship's projectiles allowed alive at once.
  final int maxProjectiles;

  /// How many seconds the ship stays invulnerable after a respawn (SR-7, AC2).
  final double respawnInvulnerability;

  /// Seconds of invulnerability still remaining. Counts down every step; while
  /// positive the ship ignores asteroid hits (SR-7, AC4 negative).
  double invulnerabilityRemaining = 0.0;

  /// Whether the ship is currently shielded from asteroid collisions.
  bool get isInvulnerable => invulnerabilityRemaining > 0;

  /// Resets the ship to [center] at rest, facing the default heading, and
  /// starts the post-respawn invulnerability window (SR-7, AC1/AC2). Snapshots
  /// the interpolation state too so the renderer does not streak from the old
  /// position to the centre.
  void respawn(Offset center) {
    position = center;
    prevPosition = center;
    velocity = Offset.zero;
    angle = -math.pi / 2;
    prevAngle = angle;
    angularVelocity = 0.0;
    invulnerabilityRemaining = respawnInvulnerability;
  }

  /// Fires a projectile from the ship's nose along its current heading, its
  /// velocity summed with the ship's own — provided [activeProjectileCount]
  /// (how many ship-owned projectiles are already alive, across the whole
  /// world — see [GameWorld._spawnProjectiles]) has not reached
  /// [maxProjectiles] and the "fire" command is currently held.
  ///
  /// Returns `null` when either condition fails, so an over-the-limit or
  /// input-less "fire" is silently ignored (TR-2 negative AC) — no exception,
  /// no projectile created.
  Projectile? tryFire(int activeProjectileCount) {
    final state = input?.state ?? InputState.idle;
    if (!state.isActive(InputCommand.fire)) return null;
    if (activeProjectileCount >= maxProjectiles) return null;

    final heading = Offset(math.cos(angle), math.sin(angle));
    return Projectile(
      position: position + heading * radius,
      velocity: velocity + heading * projectileSpeed,
      owner: ProjectileOwner.ship,
    );
  }

  @override
  void update(double dt, Size bounds) {
    // Bleed off any remaining invulnerability first (SR-7, AC2). Set on the
    // respawn step, so it starts counting down the following step.
    if (invulnerabilityRemaining > 0) {
      invulnerabilityRemaining = math.max(0.0, invulnerabilityRemaining - dt);
    }

    final state = input?.state ?? InputState.idle;

    // Turning: derived fresh each step. No input → angularVelocity == 0, and
    // left+right cancel to 0 (see InputState.turnDirection).
    angularVelocity = state.turnDirection * turnRate;

    // Thrust: accelerate along the current heading only while held.
    if (state.isActive(InputCommand.thrust)) {
      final heading = Offset(math.cos(angle), math.sin(angle));
      velocity += heading * (thrustAccel * dt);
    }

    // Optional friction, then clamp so speed can't grow without bound.
    if (friction > 0) {
      velocity *= math.max(0.0, 1.0 - friction * dt);
    }
    _clampSpeed();

    // Entity handles integration (position/angle) and toroidal wrap-around,
    // which preserves velocity across the seam (AC2).
    super.update(dt, bounds);
  }

  void _clampSpeed() {
    final speed = velocity.distance;
    if (speed > maxSpeed && speed > 0) {
      velocity = velocity * (maxSpeed / speed);
    }
  }
}
