import 'entity.dart';

/// True when the circular collision bounds of [a] and [b] overlap (SR-5).
///
/// Collision is decided purely by geometry: two entities touch when the
/// distance between their centres is less than the sum of their radii. This is
/// deliberately independent of the screen edges — an asteroid straddling the
/// toroidal seam, or merely sharing a bounding box with the ship, does not
/// count as a hit unless the circles themselves actually overlap (SR-5
/// negative scenario).
///
/// Uses squared distances to avoid a `sqrt` per pair.
bool circlesOverlap(Entity a, Entity b) {
  final radii = a.radius + b.radius;
  final delta = a.position - b.position;
  return delta.distanceSquared < radii * radii;
}
