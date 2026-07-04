import 'input_adapter.dart';
import 'input_command.dart';

/// Touch-driven [InputAdapter] fed by on-screen controls.
///
/// The widget layer draws control regions/buttons (a left/right rotate pad, a
/// thrust button, a fire button) and calls [press]/[release] as pointers go
/// down and up. This adapter only tracks *which commands* are held, so the
/// exact on-screen layout can change without touching the engine.
///
/// A command stays active until explicitly released (or [releaseAll] is
/// called), giving touch the same "while held" behaviour as the keyboard.
class TouchInputAdapter implements InputAdapter {
  final Set<InputCommand> _active = <InputCommand>{};

  @override
  InputState get state => InputState(
        turnLeft: _active.contains(InputCommand.turnLeft),
        turnRight: _active.contains(InputCommand.turnRight),
        thrust: _active.contains(InputCommand.thrust),
        fire: _active.contains(InputCommand.fire),
      );

  /// Marks [command] as held (pointer down on its control).
  void press(InputCommand command) => _active.add(command);

  /// Marks [command] as released (pointer up / left the control).
  void release(InputCommand command) => _active.remove(command);

  /// Releases every command — call when the pointer is cancelled or the
  /// controls lose the gesture, so nothing stays stuck on.
  void releaseAll() => _active.clear();

  @override
  void dispose() => _active.clear();
}
