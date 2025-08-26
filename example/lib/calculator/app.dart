import 'package:example/calculator/calc_manager/calc_manager.dart';
import 'package:example/calculator/notifier.dart';
import 'package:example/calculator/widgets/buttons.dart';
import 'package:example/calculator/widgets/display.dart';
import 'package:flutter/services.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OmarchyApp(
      debugShowCheckedModeBanner: false,
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _notifier = CalculatorNotifier();
  final _focusNode = FocusNode();

  final _simulatedPress = <int, SimulatedPressController>{
    for (final row in ButtonGrid.rows)
      for (final action in row) action: SimulatedPressController(),
  };

  @override
  void dispose() {
    super.dispose();
    _notifier.dispose();
    for (final controller in _simulatedPress.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return OmarchyScaffold(
      child: LayoutBuilder(
        builder: (context, layout) {
          if (layout.maxWidth < 40 || layout.maxHeight < 84) {
            return Center(
              child: Icon(
                OmarchyIcons.faMaximize,
                color: theme.colors.normal.black,
              ),
            );
          }
          return Focus(
            focusNode: _focusNode,
            descendantsAreFocusable: false,
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;
              void press(int action) {
                _notifier.engine.processCommand(action);
                _simulatedPress[action]?.press();
              }

              if (event.logicalKey == LogicalKeyboardKey.digit0 ||
                  event.logicalKey == LogicalKeyboardKey.numpad0) {
                press(OpCode.digit0);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.digit1 ||
                  event.logicalKey == LogicalKeyboardKey.numpad1) {
                press(OpCode.digit1);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.digit2 ||
                  event.logicalKey == LogicalKeyboardKey.numpad2) {
                press(OpCode.digit2);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.digit3 ||
                  event.logicalKey == LogicalKeyboardKey.numpad3) {
                press(OpCode.digit3);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.digit4 ||
                  event.logicalKey == LogicalKeyboardKey.numpad4) {
                press(OpCode.digit4);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.digit5 ||
                  event.logicalKey == LogicalKeyboardKey.numpad5) {
                press(OpCode.digit5);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.digit6 ||
                  event.logicalKey == LogicalKeyboardKey.numpad6) {
                press(OpCode.digit6);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.digit7 ||
                  event.logicalKey == LogicalKeyboardKey.numpad7) {
                press(OpCode.digit7);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.digit8 ||
                  event.logicalKey == LogicalKeyboardKey.numpad8) {
                press(OpCode.digit8);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.digit9 ||
                  event.logicalKey == LogicalKeyboardKey.numpad9) {
                press(OpCode.digit9);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.add ||
                  event.logicalKey == LogicalKeyboardKey.numpadAdd ||
                  event.character == '+') {
                press(OpCode.add);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.asterisk ||
                  event.logicalKey == LogicalKeyboardKey.numpadMultiply ||
                  event.character == '*') {
                press(OpCode.multiply);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.minus ||
                  event.logicalKey == LogicalKeyboardKey.numpadSubtract ||
                  event.character == '-') {
                press(OpCode.subtract);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.slash ||
                  event.logicalKey == LogicalKeyboardKey.numpadDivide ||
                  event.character == '/') {
                press(OpCode.divide);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.equal ||
                  event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEqual ||
                  event.character == '=') {
                press(OpCode.equals);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.period ||
                  event.logicalKey == LogicalKeyboardKey.comma ||
                  event.logicalKey == LogicalKeyboardKey.numpadDecimal ||
                  event.character == '.' ||
                  event.character == ',') {
                press(OpCode.decimalSeparator);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.delete ||
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                press(OpCode.backspace);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: AnimatedBuilder(
                animation: _notifier,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Display(
                        history: layout.maxHeight > 500
                            ? _notifier.history.join()
                            : null,
                        display: _notifier.primaryDisplay,
                        isConfirmed: false,
                        isIntermediateValue: false,
                        isCondensed: layout.maxHeight < 1000,
                      ),
                      if (layout.maxWidth > 100 && layout.maxHeight > 220) ...[
                        const SizedBox(height: 14),
                        Expanded(
                          child: ButtonGrid(
                            simulated: _simulatedPress,
                            onPressed: (action) {
                              _notifier.engine.processCommand(action);
                            },
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
