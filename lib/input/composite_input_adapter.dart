import 'input_adapter.dart';
import 'input_command.dart';

/// Fuses several [InputAdapter]s into one by OR-ing their states.
///
/// This removes any concept of a device "owning" the ship: keyboard and touch
/// are both live at all times, and a command is active whenever *any* adapter
/// reports it. Holding thrust on the keyboard and then tapping a touch button
/// therefore never drops the thrust — the keyboard adapter still reports it and
/// the merge keeps it active.
///
/// Conflicting inputs (left on one device, right on another) both become
/// active and cancel out via [InputState.turnDirection], which is the same
/// well-defined behaviour as pressing both keys on a single keyboard.
class CompositeInputAdapter implements InputAdapter {
  CompositeInputAdapter(this._adapters);

  final List<InputAdapter> _adapters;

  @override
  InputState get state {
    var merged = InputState.idle;
    for (final adapter in _adapters) {
      merged = merged.merge(adapter.state);
    }
    return merged;
  }

  /// Does not dispose the wrapped adapters — ownership of their lifecycle stays
  /// with whoever created them.
  @override
  void dispose() {}
}
