/// The discrete control intents the game understands, independent of the
/// physical input device that produced them.
///
/// An [InputAdapter] translates raw device events (key presses, screen taps)
/// into a set of these commands. The simulation only ever reacts to commands,
/// so keyboard and touch input stay fully interchangeable.
enum InputCommand {
  /// Rotate the ship counter-clockwise while held.
  turnLeft,

  /// Rotate the ship clockwise while held.
  turnRight,

  /// Accelerate along the ship's current heading while held.
  thrust,

  /// Fire a projectile.
  fire,
}

/// A snapshot of which control intents are active on a given physics step.
///
/// This is an immutable value read by the simulation each step. Holding a key
/// keeps the corresponding command present in every snapshot until released,
/// which is what gives thrust/turn their "while held" semantics.
///
/// [turnLeft] and [turnRight] being active simultaneously must cancel out to a
/// net-zero turn — that is the simulation's responsibility, not the snapshot's.
class InputState {
  const InputState({
    this.turnLeft = false,
    this.turnRight = false,
    this.thrust = false,
    this.fire = false,
  });

  /// An input state with nothing held — the canonical "no input" value.
  static const InputState idle = InputState();

  final bool turnLeft;
  final bool turnRight;
  final bool thrust;
  final bool fire;

  /// Whether [command] is currently active in this snapshot.
  bool isActive(InputCommand command) {
    switch (command) {
      case InputCommand.turnLeft:
        return turnLeft;
      case InputCommand.turnRight:
        return turnRight;
      case InputCommand.thrust:
        return thrust;
      case InputCommand.fire:
        return fire;
    }
  }

  /// Returns a new state where each command is active if it is active in
  /// *either* `this` or [other] (a per-field logical OR).
  ///
  /// Used to fuse several input devices into one: holding thrust on the
  /// keyboard *or* the touch button both count as thrust, so there is no notion
  /// of one device "owning" the ship. Conflicting turns (left on one device,
  /// right on the other) simply both become active and cancel via
  /// [turnDirection].
  InputState merge(InputState other) => InputState(
        turnLeft: turnLeft || other.turnLeft,
        turnRight: turnRight || other.turnRight,
        thrust: thrust || other.thrust,
        fire: fire || other.fire,
      );

  /// Net turn direction from the two turn commands.
  ///
  /// Returns `-1` for a pure left turn, `+1` for a pure right turn, and `0`
  /// when neither or both are held. Encapsulating the cancellation here means
  /// every consumer gets the "left + right = no turn" rule for free.
  int get turnDirection {
    final left = turnLeft ? 1 : 0;
    final right = turnRight ? 1 : 0;
    return right - left;
  }

  @override
  bool operator ==(Object other) =>
      other is InputState &&
      other.turnLeft == turnLeft &&
      other.turnRight == turnRight &&
      other.thrust == thrust &&
      other.fire == fire;

  @override
  int get hashCode => Object.hash(turnLeft, turnRight, thrust, fire);

  @override
  String toString() =>
      'InputState(left: $turnLeft, right: $turnRight, thrust: $thrust, fire: $fire)';
}
