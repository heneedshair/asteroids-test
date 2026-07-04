import 'package:flutter/material.dart';

import '../input/input_command.dart';

/// Semi-transparent on-screen controls for touch devices.
///
/// Left/right rotate buttons sit at the bottom-left, thrust and fire at the
/// bottom-right. Each button reports press and release via [onCommand] so the
/// [TouchInputAdapter] gets true "while held" behaviour (fingers down = held).
///
/// The overlay ignores pointers outside the buttons, so it never blocks the
/// game surface underneath.
class TouchControls extends StatelessWidget {
  const TouchControls({super.key, required this.onCommand});

  /// Called with `(command, pressed)` on pointer down (`true`) and up (`false`).
  final void Function(InputCommand command, bool pressed) onCommand;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: 16,
            bottom: 24,
            child: Row(
              children: [
                _HoldButton(
                  key: const ValueKey(InputCommand.turnLeft),
                  icon: Icons.rotate_left,
                  onChange: (p) => onCommand(InputCommand.turnLeft, p),
                ),
                const SizedBox(width: 12),
                _HoldButton(
                  key: const ValueKey(InputCommand.turnRight),
                  icon: Icons.rotate_right,
                  onChange: (p) => onCommand(InputCommand.turnRight, p),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Row(
              children: [
                _HoldButton(
                  key: const ValueKey(InputCommand.fire),
                  icon: Icons.gps_fixed,
                  onChange: (p) => onCommand(InputCommand.fire, p),
                ),
                const SizedBox(width: 12),
                _HoldButton(
                  key: const ValueKey(InputCommand.thrust),
                  icon: Icons.keyboard_arrow_up,
                  onChange: (p) => onCommand(InputCommand.thrust, p),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A round button that reports press/release rather than tap, so a command
/// stays active for exactly as long as the finger is down.
class _HoldButton extends StatelessWidget {
  const _HoldButton({super.key, required this.icon, required this.onChange});

  final IconData icon;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onChange(true),
      onPointerUp: (_) => onChange(false),
      onPointerCancel: (_) => onChange(false),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0x227CF6FF),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x557CF6FF), width: 1.5),
        ),
        child: Icon(icon, color: const Color(0xFF7CF6FF), size: 30),
      ),
    );
  }
}
