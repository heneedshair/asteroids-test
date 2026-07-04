import 'input_command.dart';

/// Abstract source of player intent.
///
/// Concrete adapters (keyboard, touch) turn device-specific events into a
/// device-agnostic [InputState] that the simulation samples once per physics
/// step via [state]. Keeping this behind an interface lets the game run on
/// desktop and mobile without any conditional input logic in the engine.
abstract class InputAdapter {
  /// The control intents currently active.
  ///
  /// Read every physics step; must never mutate simulation state itself.
  InputState get state;

  /// Releases any resources / listeners held by the adapter.
  void dispose() {}
}
