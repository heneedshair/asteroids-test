import 'dart:ui';

/// Base class for every object living in the game world.
///
/// An entity owns its physics state (position, velocity, orientation). It knows
/// how to advance itself by a fixed physics step but never how to draw itself —
/// rendering lives entirely in the painter layer.
///
/// To support render interpolation, each entity keeps the previous step's
/// position/angle. The renderer blends between [prevPosition]/[prevAngle] and
/// the current values using an `alpha` in [0, 1]; it never writes them.
class Entity {
  Entity({
    required this.position,
    this.velocity = Offset.zero,
    this.angle = 0.0,
    this.angularVelocity = 0.0,
    this.radius = 0.0,
    this.alive = true,
  })  : prevPosition = position,
        prevAngle = angle;

  /// Current simulated position (top-left origin, pixels).
  Offset position;

  /// Position at the start of the current physics step, kept for interpolation.
  Offset prevPosition;

  /// Linear velocity in pixels per second.
  Offset velocity;

  /// Current orientation in radians.
  double angle;

  /// Orientation at the start of the current physics step.
  double prevAngle;

  /// Angular velocity in radians per second.
  double angularVelocity;

  /// Collision radius in pixels.
  double radius;

  /// When false the entity is scheduled for removal by the world.
  bool alive;

  /// Advances the entity by one fixed physics step of [dt] seconds.
  ///
  /// Snapshots the pre-step state first so the renderer can interpolate. World
  /// bounds are passed in so entities wrap around the screen edges.
  void update(double dt, Size bounds) {
    prevPosition = position;
    prevAngle = angle;

    position += velocity * dt;
    angle += angularVelocity * dt;

    _wrap(bounds);
  }

  /// Wraps the position around the toroidal play field.
  void _wrap(Size bounds) {
    var x = position.dx;
    var y = position.dy;
    final w = bounds.width;
    final h = bounds.height;

    if (w > 0) {
      if (x < 0) x += w;
      if (x >= w) x -= w;
    }
    if (h > 0) {
      if (y < 0) y += h;
      if (y >= h) y -= h;
    }

    // If a wrap happened, collapse the interpolation so the renderer does not
    // draw a long streak across the whole screen for a single step.
    if (x != position.dx || y != position.dy) {
      position = Offset(x, y);
      prevPosition = position;
    }
  }

  /// Read-only interpolated position for rendering at blend factor [alpha].
  ///
  /// Pure: it does not mutate any entity state.
  Offset renderPosition(double alpha) =>
      Offset.lerp(prevPosition, position, alpha) ?? position;

  /// Read-only interpolated angle for rendering at blend factor [alpha].
  double renderAngle(double alpha) =>
      prevAngle + (angle - prevAngle) * alpha;
}
