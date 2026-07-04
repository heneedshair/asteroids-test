import 'dart:math' as math;
import 'dart:ui';

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

/// Advances a ship by [steps] fixed steps of [dt].
void _run(Ship ship, Size bounds, {int steps = 1, double dt = 1 / 60}) {
  for (var i = 0; i < steps; i++) {
    ship.update(dt, bounds);
  }
}

void main() {
  const bounds = Size(800, 600);

  group('Thrust + inertia (AC1)', () {
    test('holding thrust increases speed along heading', () {
      final input = FakeInput(const InputState(thrust: true));
      // angle 0 -> heading +x.
      final ship = Ship(
        position: const Offset(400, 300),
        input: input,
        angle: 0,
        friction: 0,
      );

      _run(ship, bounds, steps: 10);

      expect(ship.velocity.dx, greaterThan(0));
      expect(ship.velocity.dy, closeTo(0, 1e-9));
      expect(ship.position.dx, greaterThan(400));
    });

    test('after releasing thrust the ship keeps moving (inertia)', () {
      final input = FakeInput(const InputState(thrust: true));
      final ship = Ship(
        position: const Offset(400, 300),
        input: input,
        angle: 0,
        friction: 0,
      );

      _run(ship, bounds, steps: 10);
      final coastSpeed = ship.velocity.distance;
      expect(coastSpeed, greaterThan(0));

      // Release thrust; velocity must persist unchanged (frictionless).
      input.set(InputState.idle);
      _run(ship, bounds, steps: 30);

      expect(ship.velocity.distance, closeTo(coastSpeed, 1e-9));
      expect(ship.position.dx, greaterThan(400));
    });
  });

  group('Turning (AC3)', () {
    test('left + right held together yield zero angular velocity', () {
      final input = FakeInput(
        const InputState(turnLeft: true, turnRight: true),
      );
      final ship = Ship(position: const Offset(400, 300), input: input);

      _run(ship, bounds, steps: 5);

      expect(ship.angularVelocity, 0);
    });

    test('single direction produces a non-zero, signed turn', () {
      final left = Ship(
        position: const Offset(400, 300),
        input: FakeInput(const InputState(turnLeft: true)),
      );
      final right = Ship(
        position: const Offset(400, 300),
        input: FakeInput(const InputState(turnRight: true)),
      );

      _run(left, bounds);
      _run(right, bounds);

      expect(left.angularVelocity, lessThan(0));
      expect(right.angularVelocity, greaterThan(0));
    });
  });

  group('Negative scenario: no self-motion without input (AC4)', () {
    test('5 seconds of no input keeps angular velocity at exactly zero', () {
      final ship = Ship(
        position: const Offset(400, 300),
        input: FakeInput(InputState.idle),
      );

      // 5 seconds at 60 Hz = 300 fixed steps.
      _run(ship, bounds, steps: 300);

      expect(ship.angularVelocity, 0);
      expect(ship.angle, ship.prevAngle);
    });

    test('a ship at rest with no input never accelerates by itself', () {
      final ship = Ship(
        position: const Offset(400, 300),
        input: FakeInput(InputState.idle),
        velocity: Offset.zero,
      );

      _run(ship, bounds, steps: 300);

      expect(ship.velocity, Offset.zero);
      expect(ship.position, const Offset(400, 300));
    });
  });

  group('Wrap-around preserves velocity (AC2)', () {
    test('crossing an edge teleports to the far side keeping velocity', () {
      final input = FakeInput(InputState.idle);
      // Start near the right edge moving right; no input so it just coasts.
      final ship = Ship(
        position: const Offset(799, 300),
        input: input,
        velocity: const Offset(120, 0),
      );

      final before = ship.velocity;
      _run(ship, bounds, steps: 2);

      // Wrapped to the left side.
      expect(ship.position.dx, lessThan(400));
      // Velocity unchanged across the seam.
      expect(ship.velocity, before);
    });
  });

  group('Speed clamp', () {
    test('velocity magnitude never exceeds maxSpeed', () {
      final input = FakeInput(const InputState(thrust: true));
      final ship = Ship(
        position: const Offset(400, 300),
        input: input,
        angle: 0,
        maxSpeed: 100,
        thrustAccel: 5000,
      );

      _run(ship, bounds, steps: 120);

      expect(ship.velocity.distance, lessThanOrEqualTo(100 + 1e-6));
    });
  });

  test('default ship is frictionless (inertia contract, AC1)', () {
    final ship = Ship(position: Offset.zero);
    expect(ship.friction, 0.0);
  });

  test('null input coasts on current velocity', () {
    final ship = Ship(
      position: const Offset(10, 300),
      velocity: const Offset(60, 0),
      angle: math.pi, // heading -x, but no thrust so irrelevant
    );
    _run(ship, bounds, steps: 1);
    expect(ship.position.dx, closeTo(11, 1e-9));
    expect(ship.angularVelocity, 0);
  });
}
