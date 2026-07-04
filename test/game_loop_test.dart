import 'dart:ui';

import 'package:asteroids/game/entity.dart';
import 'package:asteroids/game/game_loop.dart';
import 'package:asteroids/game/game_world.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FixedTimestep', () {
    test('runs one step per fixed interval at target framerate', () {
      final ts = FixedTimestep(fixedDt: 1 / 60);
      expect(ts.advance(1 / 60), 1);
    });

    test('a slow frame runs multiple small steps, never one big step', () {
      final ts = FixedTimestep(fixedDt: 1 / 60);
      // A frame ~4x too long should produce ~4 fixed steps of 1/60 each,
      // not a single 4/60 step. This is what prevents tunneling.
      final steps = ts.advance(4 / 60);
      expect(steps, 4);
    });

    test('clamps huge frame times to avoid the spiral of death', () {
      final ts = FixedTimestep(fixedDt: 1 / 60, maxFrameTime: 0.25);
      // A 10 second stall must not queue 600 steps.
      final steps = ts.advance(10.0);
      expect(steps, 0.25 * 60);
    });

    test('accumulates leftover time across frames', () {
      final ts = FixedTimestep(fixedDt: 1 / 60);
      // Two half-steps should together produce exactly one step.
      expect(ts.advance(0.5 / 60), 0);
      expect(ts.advance(0.5 / 60), 1);
    });

    test('ignores non-positive / NaN frame times', () {
      final ts = FixedTimestep();
      expect(ts.advance(0), 0);
      expect(ts.advance(-1), 0);
      expect(ts.advance(double.nan), 0);
    });
  });

  group('Negative scenario: no tunneling under FPS drop', () {
    test('object does not skip past a target during one slow render frame', () {
      // A fast mover crossing a 600px field. With a single big step the
      // integrated displacement would leap across the whole field; with fixed
      // sub-stepping the maximum per-step displacement stays small.
      const fixedDt = 1 / 60;
      final ts = FixedTimestep(fixedDt: fixedDt);
      // Field wide enough that no wrap occurs over the frame, so we isolate the
      // per-step displacement invariant itself.
      final world = GameWorld(bounds: const Size(100000, 600));
      final mover = Entity(
        position: const Offset(0, 300),
        velocity: const Offset(3000, 0), // 50px per fixed step
      );
      world.entities.add(mover);

      // Simulate a badly janky frame of 0.2s (12 fixed steps).
      final steps = ts.advance(0.2);
      double maxStepDisplacement = 0;
      for (var i = 0; i < steps; i++) {
        final before = mover.position.dx;
        world.update(fixedDt);
        final delta = (mover.position.dx - before).abs();
        if (delta > maxStepDisplacement) maxStepDisplacement = delta;
      }

      expect(steps, 12);
      // Each step advances at most velocity*fixedDt = 50px, never the whole
      // field in one leap — regardless of how long the render frame took.
      expect(maxStepDisplacement, lessThanOrEqualTo(50.0 + 1e-6));
    });
  });

  group('Render separation', () {
    test('renderPosition interpolates without mutating entity state', () {
      final e = Entity(position: const Offset(0, 0), velocity: const Offset(60, 0));
      e.update(1 / 60, const Size(1000, 1000)); // prev=(0,0) current=(1,0)

      final mid = e.renderPosition(0.5);
      expect(mid.dx, closeTo(0.5, 1e-9));

      // Rendering must not have changed simulation state.
      expect(e.position, const Offset(1, 0));
      expect(e.prevPosition, const Offset(0, 0));
    });
  });
}
