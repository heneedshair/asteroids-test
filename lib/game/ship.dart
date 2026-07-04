import 'dart:math' as math;
import 'dart:ui';

import '../input/input_adapter.dart';
import '../input/input_command.dart';
import 'entity.dart';

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
    super.velocity,
    super.angle = -math.pi / 2,
    super.radius = 14.0,
  });

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

  @override
  void update(double dt, Size bounds) {
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
