import 'package:flutter/rendering.dart';

import 'game_controller.dart';
import 'game_world.dart';
import 'ship.dart';

/// Renders the [GameWorld] using the controller's interpolation [alpha].
///
/// Strictly read-only with respect to game state: it queries entity positions
/// via [Entity.renderPosition]/[Entity.renderAngle] and never mutates the world.
/// It repaints whenever the [GameController] notifies (once per frame).
class GamePainter extends CustomPainter {
  GamePainter(this.controller) : super(repaint: controller);

  final GameController controller;

  GameWorld get _world => controller.world;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFF05060A);
    canvas.drawRect(Offset.zero & size, background);

    final alpha = controller.alpha;
    final entityPaint = Paint()
      ..color = const Color(0xFF7CF6FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final entity in _world.entities) {
      // A freshly respawned, invulnerable ship blinks (~5 Hz) as visible
      // feedback for the invulnerability window (SR-7, AC2).
      if (entity is Ship && entity.isInvulnerable) {
        if ((entity.invulnerabilityRemaining * 10).floor().isOdd) continue;
      }

      final p = entity.renderPosition(alpha);
      final a = entity.renderAngle(alpha);

      // Placeholder scaffold rendering: a triangle pointing along `angle`.
      // Concrete shapes (ship, asteroid, bullet) arrive in later tasks.
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(a);
      final r = entity.radius == 0 ? 12.0 : entity.radius;
      final path = Path()
        ..moveTo(r, 0)
        ..lineTo(-r * 0.7, r * 0.7)
        ..lineTo(-r * 0.7, -r * 0.7)
        ..close();
      canvas.drawPath(path, entityPaint);
      canvas.restore();
    }
  }

  // Repaint is driven by the `repaint` Listenable (the controller), so this can
  // safely return false: no per-instance field changes to compare.
  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => false;
}
