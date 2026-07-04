import 'dart:math' as math;
import 'dart:ui';

import 'entity.dart';

/// The three asteroid sizes (SR-4). Each size derives its own collision
/// radius, drift/fragment speed and score value; a hit fragments a size into
/// the next one down, and the smallest is destroyed outright.
enum AsteroidSize {
  large,
  medium,
  small;

  /// Collision-bound radius in pixels.
  double get radius => switch (this) {
        AsteroidSize.large => 40.0,
        AsteroidSize.medium => 22.0,
        AsteroidSize.small => 12.0,
      };

  /// Speed of this size's own drift, and of the fragments it produces
  /// (pixels/sec). Smaller rocks move faster (SPEC-PROC-1).
  double get speed => switch (this) {
        AsteroidSize.large => 40.0,
        AsteroidSize.medium => 70.0,
        AsteroidSize.small => 110.0,
      };

  /// Points awarded when an asteroid of this size is destroyed. Smaller is
  /// worth more (SR-6): risk/precision are rewarded.
  int get points => switch (this) {
        AsteroidSize.large => 20,
        AsteroidSize.medium => 50,
        AsteroidSize.small => 100,
      };

  /// The size each fragment becomes when this one is hit, or `null` when this
  /// size shatters without producing fragments (the smallest).
  AsteroidSize? get fragmentSize => switch (this) {
        AsteroidSize.large => AsteroidSize.medium,
        AsteroidSize.medium => AsteroidSize.small,
        AsteroidSize.small => null,
      };
}

/// A drifting asteroid (SR-4). Movement, integration and screen wrap-around
/// are inherited from [Entity]; the only asteroid-specific behaviour is
/// [split], which turns one rock into its fragments on a projectile hit.
class Asteroid extends Entity {
  Asteroid({
    required super.position,
    required this.size,
    super.velocity,
    super.angle,
    super.angularVelocity,
  }) : super(radius: size.radius);

  final AsteroidSize size;

  /// Points awarded when this asteroid is destroyed.
  int get points => size.points;

  /// Fragments produced by a hit on this asteroid (TR-3):
  ///  * large → two medium, medium → two small, small → `[]` (no fragments).
  ///
  /// Fragments inherit the parent's position and fly apart along diverging
  /// headings (parent heading rotated by ±[spreadRadians]) at their own size's
  /// [AsteroidSize.speed]. A stationary parent falls back to a fixed axis so
  /// the pieces still separate.
  List<Asteroid> split({double spreadRadians = math.pi / 4}) {
    final childSize = size.fragmentSize;
    if (childSize == null) return const <Asteroid>[];

    final baseHeading =
        velocity.distance > 0 ? velocity / velocity.distance : const Offset(1, 0);
    final baseAngle = math.atan2(baseHeading.dy, baseHeading.dx);
    final childSpeed = childSize.speed;

    return <Asteroid>[
      _child(childSize, baseAngle + spreadRadians, childSpeed),
      _child(childSize, baseAngle - spreadRadians, childSpeed),
    ];
  }

  Asteroid _child(AsteroidSize childSize, double heading, double speed) {
    return Asteroid(
      position: position,
      size: childSize,
      velocity: Offset(math.cos(heading), math.sin(heading)) * speed,
    );
  }
}
