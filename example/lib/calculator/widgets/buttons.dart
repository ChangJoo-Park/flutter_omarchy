import 'package:example/calculator/calc_manager/calc_manager.dart';
import 'package:example/calculator/calc_manager/constants.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({
    super.key,
    required this.onPressed,
    required this.simulated,
    this.spacing = 4.0,
  });

  final ValueChanged<int> onPressed;
  final Map<int, SimulatedPressController> simulated;
  final double spacing;

  static const rows = <List<int>>[
    [
      OpCode.memoryClear,
      OpCode.openParenthesis,
      OpCode.closeParenthesis,
      OpCode.clearEntry,
      OpCode.backspace,
      OpCode.clear,
      OpCode.divide,
    ],
    [
      OpCode.memoryRecall,
      OpCode.sin,
      OpCode.pow,
      OpCode.digit7,
      OpCode.digit8,
      OpCode.digit9,
      OpCode.multiply,
    ],

    [
      OpCode.memoryAdd,
      OpCode.cos,
      OpCode.square,
      OpCode.digit4,
      OpCode.digit5,
      OpCode.digit6,
      OpCode.subtract,
    ],
    [
      OpCode.memorySubtract,
      OpCode.tan,
      OpCode.percent,
      OpCode.digit1,
      OpCode.digit2,
      OpCode.digit3,
      OpCode.add,
    ],
    [
      OpCode.pi,
      OpCode.ln,
      OpCode.sqrt,
      OpCode.inv,
      OpCode.digit0,
      OpCode.decimalSeparator,
      OpCode.equals,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, layout) {
        final startCol = (layout.maxWidth > 800) ? 0 : 3;
        return Column(
          spacing: spacing,
          children: [
            for (final row in rows)
              Expanded(
                child: Row(
                  spacing: spacing,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: row.skip(startCol).map((action) {
                    return SimulatedPress(
                      key: ValueKey(action),
                      controller: simulated[action],
                      child: CalculatorButton(
                        action,
                        onPressed: () => onPressed(action),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CalculatorButton extends StatelessWidget {
  const CalculatorButton(this.action, {super.key, required this.onPressed});

  final int action;
  final VoidCallback onPressed;
  AnsiColor get color => switch (action) {
    OpCode.clear => AnsiColor.red,
    OpCode.clearEntry => AnsiColor.red,
    OpCode.backspace => AnsiColor.red,
    OpCode.inv => AnsiColor.blue,
    OpCode.percent => AnsiColor.cyan,
    OpCode.sqrt => AnsiColor.cyan,
    OpCode.square => AnsiColor.cyan,
    OpCode.pow => AnsiColor.cyan,
    OpCode.ln => AnsiColor.cyan,
    OpCode.pi => AnsiColor.cyan,
    OpCode.openParenthesis || OpCode.closeParenthesis => AnsiColor.blue,
    OpCode.sin || OpCode.cos || OpCode.tan => AnsiColor.cyan,
    OpCode.equals => AnsiColor.green,
    OpCode.digit0 ||
    OpCode.digit1 ||
    OpCode.digit2 ||
    OpCode.digit3 ||
    OpCode.digit4 ||
    OpCode.digit5 ||
    OpCode.digit6 ||
    OpCode.digit7 ||
    OpCode.digit8 ||
    OpCode.digit9 => AnsiColor.white,
    OpCode.decimalSeparator => AnsiColor.white,
    OpCode.add ||
    OpCode.subtract ||
    OpCode.multiply ||
    OpCode.divide => AnsiColor.yellow,
    OpCode.memoryRecall ||
    OpCode.memoryClear ||
    OpCode.memoryAdd ||
    OpCode.memorySubtract ||
    OpCode.memoryStore => AnsiColor.magenta,
    _ => AnsiColor.white,
  };

  Widget symbol(bool isSmall) => switch (action) {
    OpCode.backspace => Icon(
      OmarchyIcons.mdBackspaceOutline,
      size: isSmall ? 30 : 48,
    ),
    final other => Text(
      CalcEngine.opCodeToUnaryString(action, true, AngleType.radians),
      style: TextStyle(fontSize: isSmall ? 20 : 32),
    ),
  };
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FadeIn(
        child: LayoutBuilder(
          builder: (context, layout) {
            final isSmall = layout.maxHeight < 75 || layout.maxWidth < 80;
            return OmarchyButton(
              style: OmarchyButtonStyle.filled(color, padding: EdgeInsets.zero),
              onPressed: onPressed,
              child: Center(child: symbol(isSmall)),
            );
          },
        ),
      ),
    );
  }
}
