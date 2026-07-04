import 'package:flutter/services.dart';

import 'input_adapter.dart';
import 'input_command.dart';

/// Maps physical/hardware keyboard state onto [InputState].
///
/// The adapter tracks which of the *bound* keys are currently held. The widget
/// layer feeds it raw [KeyEvent]s (via [handleKeyEvent]); the simulation reads
/// the derived [state] each step. Because holding a key keeps it in
/// [_pressed], thrust and turning naturally have "while held" semantics.
///
/// Controls:
///  * turn left  — ArrowLeft / A
///  * turn right — ArrowRight / D
///  * thrust     — ArrowUp / W
///  * fire       — Space
class KeyboardInputAdapter implements InputAdapter {
  /// Logical keys bound to each command. A command is active when *any* of its
  /// keys is held.
  static const Map<InputCommand, List<LogicalKeyboardKey>> _bindings = {
    InputCommand.turnLeft: [
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.keyA,
    ],
    InputCommand.turnRight: [
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.keyD,
    ],
    InputCommand.thrust: [
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.keyW,
    ],
    InputCommand.fire: [
      LogicalKeyboardKey.space,
    ],
  };

  /// Currently held keys that are bound to a command. Unbound keys are never
  /// stored, so an unknown/invalid key press can never affect [state].
  final Set<LogicalKeyboardKey> _pressed = <LogicalKeyboardKey>{};

  /// Every logical key that maps to some command, precomputed for O(1) lookup.
  static final Set<LogicalKeyboardKey> _boundKeys = {
    for (final keys in _bindings.values) ...keys,
  };

  @override
  InputState get state => InputState(
        turnLeft: _isCommandHeld(InputCommand.turnLeft),
        turnRight: _isCommandHeld(InputCommand.turnRight),
        thrust: _isCommandHeld(InputCommand.thrust),
        fire: _isCommandHeld(InputCommand.fire),
      );

  bool _isCommandHeld(InputCommand command) =>
      _bindings[command]!.any(_pressed.contains);

  /// Feeds one Flutter [KeyEvent] into the adapter.
  ///
  /// Returns `true` when the key is one we care about (so the widget layer can
  /// mark the event handled) and `false` for unbound keys — those are ignored
  /// entirely and never alter [state].
  bool handleKeyEvent(KeyEvent event) {
    final key = event.logicalKey;
    if (!_boundKeys.contains(key)) return false;

    if (event is KeyDownEvent) {
      _pressed.add(key);
    } else if (event is KeyUpEvent) {
      _pressed.remove(key);
    }
    // KeyRepeatEvent: key is already in _pressed, nothing to do.
    return true;
  }

  /// Clears all held keys. Useful when focus is lost so a key isn't left
  /// "stuck down" because its release event was delivered elsewhere.
  void reset() => _pressed.clear();

  @override
  void dispose() => _pressed.clear();
}
