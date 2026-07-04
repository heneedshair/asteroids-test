import 'dart:async';
import 'dart:ui';

import 'package:asteroids/game/asteroid.dart';
import 'package:asteroids/game/game_world.dart';
import 'package:asteroids/game/highscore_store.dart';
import 'package:asteroids/game/projectile.dart';
import 'package:asteroids/game/ship.dart';
import 'package:flutter_test/flutter_test.dart';

/// A projectile sitting on top of [position] so it collides on the next step.
Projectile _bulletAt(Offset position) => Projectile(
      position: position,
      velocity: Offset.zero,
      owner: ProjectileOwner.ship,
      timeToLive: 10,
    );

/// In-memory [HighscoreStore] for the service tests.
class _FakeStore implements HighscoreStore {
  _FakeStore([this.value = 0]);

  int value;
  int writes = 0;

  @override
  Future<int> read() async => value;

  @override
  Future<void> write(int v) async {
    writes++;
    value = v;
  }
}

/// A store whose read and write always fail — models a broken/unavailable
/// backing store (AC4).
class _ThrowingStore implements HighscoreStore {
  @override
  Future<int> read() async => throw StateError('read boom');

  @override
  Future<void> write(int value) async => throw StateError('write boom');
}

/// A store whose [read] blocks until [release] is called, so a test can force a
/// submit to happen *while* the load is still in flight.
class _GatedReadStore implements HighscoreStore {
  _GatedReadStore(this.stored);

  int stored;
  final List<int> writes = <int>[];
  final Completer<void> _gate = Completer<void>();

  void release() => _gate.complete();

  @override
  Future<int> read() async {
    await _gate.future;
    return stored;
  }

  @override
  Future<void> write(int value) async {
    writes.add(value);
    stored = value;
  }
}

void main() {
  const bounds = Size(800, 600);
  const centre = Offset(400, 300);
  const dt = 1 / 60;

  group('Scoring by size (SR-6, AC1)', () {
    test('destroying an asteroid adds exactly its size points', () {
      final world = GameWorld(bounds: bounds)
        ..entities.add(Asteroid(position: centre, size: AsteroidSize.large))
        ..entities.add(_bulletAt(centre));

      world.update(dt);

      expect(world.score, AsteroidSize.large.points); // 20
    });

    test('a destroyed small asteroid is worth more than a large one', () {
      final world = GameWorld(bounds: bounds)
        ..entities.add(Asteroid(position: centre, size: AsteroidSize.small))
        ..entities.add(_bulletAt(centre));

      world.update(dt);

      expect(world.score, AsteroidSize.small.points); // 100
      expect(AsteroidSize.small.points, greaterThan(AsteroidSize.large.points));
    });

    test('score starts at zero', () {
      expect(GameWorld(bounds: bounds).score, 0);
    });
  });

  group('Negative: no double scoring / no scoring on ship hit', () {
    test('two bullets hitting one asteroid the same step score it once', () {
      final world = GameWorld(bounds: bounds)
        ..entities.add(Asteroid(position: centre, size: AsteroidSize.large))
        ..entities.add(_bulletAt(centre))
        ..entities.add(_bulletAt(centre));

      world.update(dt);

      expect(world.score, AsteroidSize.large.points); // scored once, not twice
    });

    test('a ship↔asteroid collision awards no points', () {
      final world = GameWorld(bounds: bounds)
        ..entities.add(Ship(position: centre))
        ..entities.add(Asteroid(position: centre, size: AsteroidSize.large));

      world.update(dt);

      expect(world.shipCollided, isTrue); // the hit landed…
      expect(world.score, 0); // …but it scored nothing
    });
  });

  group('HighscoreService persistence (SR-6, AC2/AC3)', () {
    test('load surfaces the stored best', () async {
      final service = HighscoreService(_FakeStore(1500));
      await service.load();
      expect(service.best, 1500);
    });

    test('a new record is persisted and becomes the best', () async {
      final store = _FakeStore(100);
      final service = HighscoreService(store);
      await service.load();

      final saved = await service.submit(250);

      expect(saved, isTrue);
      expect(service.best, 250);
      expect(store.value, 250);
      expect(store.writes, 1);
    });

    test('a non-record score is neither saved nor promoted', () async {
      final store = _FakeStore(300);
      final service = HighscoreService(store);
      await service.load();

      final saved = await service.submit(120);

      expect(saved, isFalse);
      expect(service.best, 300);
      expect(store.writes, 0); // store left untouched
    });
  });

  group('Load/submit ordering & concurrency (SR-6, AC2/AC3)', () {
    test('a submit fired before load resolves never clobbers a real record',
        () async {
      // The stored best (500) is still being read when a lower score is
      // submitted. submit() must wait for the load and then reject 100.
      final store = _GatedReadStore(500);
      final service = HighscoreService(store);

      service.load(); // read is gated — _best is still 0 here
      final pending = service.submit(100); // must defer until load resolves
      store.release(); // load can now complete → _best becomes 500

      final saved = await pending;
      expect(saved, isFalse); // 100 is not a record vs the loaded 500
      expect(store.writes, isEmpty); // the real best was never overwritten
      expect(service.best, 500);
    });

    test('concurrent submits serialize; the highest score is kept', () async {
      final store = _FakeStore(0);
      final service = HighscoreService(store);
      await service.load();

      // Fire both without awaiting between them: they must not both compare
      // against the same stale _best and let the lower one win.
      final a = service.submit(150);
      final b = service.submit(300);
      await Future.wait([a, b]);

      expect(service.best, 300);
      expect(store.value, 300);
    });

    test('load reads the store only once even when called repeatedly',
        () async {
      final store = _FakeStore(42);
      final service = HighscoreService(store);

      await Future.wait([service.load(), service.load()]);
      await service.load();

      expect(service.best, 42);
    });
  });

  group('Negative: storage failure never crashes (AC4)', () {
    test('a failed load leaves best at zero instead of throwing', () async {
      final service = HighscoreService(_ThrowingStore());

      await expectLater(service.load(), completes);
      expect(service.best, 0);
    });

    test('a failed write keeps the previous in-memory best, no throw', () async {
      final service = HighscoreService(_ThrowingStore());

      final saved = await service.submit(999);

      expect(saved, isFalse); // write failed
      expect(service.best, 0); // unchanged from before the attempt
    });
  });
}
