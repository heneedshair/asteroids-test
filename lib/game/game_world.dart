import 'dart:ui';

import 'entity.dart';

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
    entities.removeWhere((e) => !e.alive);
  }
}
