import 'package:asteroids/input/composite_input_adapter.dart';
import 'package:asteroids/input/input_adapter.dart';
import 'package:asteroids/input/input_command.dart';
import 'package:asteroids/input/keyboard_input_adapter.dart';
import 'package:asteroids/input/touch_input_adapter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test double whose reported [state] can be set directly.
class _StubAdapter implements InputAdapter {
  _StubAdapter([this.state = InputState.idle]);

  @override
  InputState state;

  @override
  void dispose() {}
}

KeyDownEvent _down(LogicalKeyboardKey key, PhysicalKeyboardKey physical) =>
    KeyDownEvent(
      logicalKey: key,
      physicalKey: physical,
      timeStamp: Duration.zero,
    );

KeyUpEvent _up(LogicalKeyboardKey key, PhysicalKeyboardKey physical) =>
    KeyUpEvent(
      logicalKey: key,
      physicalKey: physical,
      timeStamp: Duration.zero,
    );

void main() {
  group('InputState.turnDirection', () {
    test('left only turns -1', () {
      expect(const InputState(turnLeft: true).turnDirection, -1);
    });

    test('right only turns +1', () {
      expect(const InputState(turnRight: true).turnDirection, 1);
    });

    test('no turn input is 0', () {
      expect(InputState.idle.turnDirection, 0);
    });

    test('left + right cancel to 0 (AC3)', () {
      expect(
        const InputState(turnLeft: true, turnRight: true).turnDirection,
        0,
      );
    });
  });

  group('InputState.isActive', () {
    test('reports the held command', () {
      const s = InputState(thrust: true, fire: true);
      expect(s.isActive(InputCommand.thrust), isTrue);
      expect(s.isActive(InputCommand.fire), isTrue);
      expect(s.isActive(InputCommand.turnLeft), isFalse);
    });
  });

  group('KeyboardInputAdapter', () {
    test('arrow keys map to turn/thrust while held', () {
      final kb = KeyboardInputAdapter();
      expect(
        kb.handleKeyEvent(
          _down(LogicalKeyboardKey.arrowLeft, PhysicalKeyboardKey.arrowLeft),
        ),
        isTrue,
      );
      expect(kb.state.turnLeft, isTrue);

      kb.handleKeyEvent(
        _up(LogicalKeyboardKey.arrowLeft, PhysicalKeyboardKey.arrowLeft),
      );
      expect(kb.state.turnLeft, isFalse);
    });

    test('WASD/space are alternate bindings', () {
      final kb = KeyboardInputAdapter();
      kb.handleKeyEvent(_down(LogicalKeyboardKey.keyD, PhysicalKeyboardKey.keyD));
      kb.handleKeyEvent(_down(LogicalKeyboardKey.keyW, PhysicalKeyboardKey.keyW));
      kb.handleKeyEvent(_down(LogicalKeyboardKey.space, PhysicalKeyboardKey.space));
      final s = kb.state;
      expect(s.turnRight, isTrue);
      expect(s.thrust, isTrue);
      expect(s.fire, isTrue);
    });

    test('unbound key is ignored and never changes state (AC5)', () {
      final kb = KeyboardInputAdapter();
      final handled = kb.handleKeyEvent(
        _down(LogicalKeyboardKey.keyZ, PhysicalKeyboardKey.keyZ),
      );
      expect(handled, isFalse);
      expect(kb.state, InputState.idle);
    });

    test('reset clears stuck keys', () {
      final kb = KeyboardInputAdapter();
      kb.handleKeyEvent(
        _down(LogicalKeyboardKey.arrowUp, PhysicalKeyboardKey.arrowUp),
      );
      expect(kb.state.thrust, isTrue);
      kb.reset();
      expect(kb.state, InputState.idle);
    });
  });

  group('TouchInputAdapter', () {
    test('press/release toggle commands', () {
      final touch = TouchInputAdapter();
      touch.press(InputCommand.thrust);
      expect(touch.state.thrust, isTrue);
      touch.release(InputCommand.thrust);
      expect(touch.state.thrust, isFalse);
    });

    test('left + right pressed together cancel to net-zero turn (AC3)', () {
      final touch = TouchInputAdapter();
      touch.press(InputCommand.turnLeft);
      touch.press(InputCommand.turnRight);
      expect(touch.state.turnDirection, 0);
    });

    test('releaseAll clears everything', () {
      final touch = TouchInputAdapter();
      touch.press(InputCommand.turnLeft);
      touch.press(InputCommand.fire);
      touch.releaseAll();
      expect(touch.state, InputState.idle);
    });
  });

  group('InputState.merge', () {
    test('ORs each field', () {
      const a = InputState(thrust: true);
      const b = InputState(fire: true, turnLeft: true);
      final m = a.merge(b);
      expect(m, const InputState(thrust: true, fire: true, turnLeft: true));
    });
  });

  group('CompositeInputAdapter', () {
    test('a command held on ANY device stays active (no ownership steal)', () {
      final keyboard = _StubAdapter(const InputState(thrust: true));
      final touch = _StubAdapter(const InputState(turnLeft: true));
      final composite = CompositeInputAdapter([keyboard, touch]);

      // Thrust (keyboard) is NOT dropped just because touch is also active.
      final s = composite.state;
      expect(s.thrust, isTrue);
      expect(s.turnLeft, isTrue);

      // Releasing touch leaves the still-held keyboard thrust intact.
      touch.state = InputState.idle;
      expect(composite.state, const InputState(thrust: true));
    });

    test('conflicting turns from two devices cancel to net-zero (AC3)', () {
      final keyboard = _StubAdapter(const InputState(turnLeft: true));
      final touch = _StubAdapter(const InputState(turnRight: true));
      final composite = CompositeInputAdapter([keyboard, touch]);

      expect(composite.state.turnDirection, 0);
    });
  });
}
