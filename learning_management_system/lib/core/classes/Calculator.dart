// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../constants/FontGlobals.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorPopupState();
}

class _CalculatorPopupState extends State<Calculator> {
  String _input = "";
  String _output = "0";
  bool _showScientific = false;

  final List<List<String>> _basicButtons = [
    ['C', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['.', '0', '00', '='],
  ];

  final List<String> _scientificButtons = [
    'sin',
    'cos',
    'tan',
    'π',
    '√',
    'x²',
    'x³',
    'e',
    '|x|',
    'ln',
    '(',
    ')',
  ];

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _input = "";
        _output = "0";
      } else if (buttonText == "⌫") {
        _input =
            _input.isNotEmpty ? _input.substring(0, _input.length - 1) : "";
      } else if (buttonText == "=") {
        _calculateResult();
      } else {
        _input += buttonText;
      }
    });
  }

  void _calculateResult() {
    try {
      String expression = _input
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', 'pi')
          .replaceAll('√', 'sqrt')
          .replaceAll('x²', '^2')
          .replaceAll('x³', '^3')
          .replaceAll('e', '2.71828')
          .replaceAll('00', '*100')
          .replaceAll('|x|', 'abs');

      // Use the correct API for math_expressions
      final parser = Parser();
      final exp = parser.parse(expression);
      final cm = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        _output =
            result % 1 == 0
                ? result.toInt().toString()
                : result.toStringAsFixed(4);
      });
    } catch (e) {
      setState(() {
        _output = "Error input";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 24,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _input,
                        style: TextStyle(
                          fontSize:
                              globalFontSizeChange <= 17
                                  ? (globalFontSizeChange / 5) + 20
                                  : 20 - (globalFontSizeChange / 5),
                          fontFamily: globalFontFamily,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _output,
                    style: TextStyle(
                      fontSize:
                          globalFontSizeChange <= 17
                              ? (globalFontSizeChange / 5) + 28
                              : 28 - (globalFontSizeChange / 5),
                      fontFamily: globalFontFamily,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Scientific Buttons
            if (_showScientific)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 2,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                children:
                    _scientificButtons.map((btn) => _buildButton(btn)).toList(),
              ),
            // Toggle Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () => setState(() => _showScientific = !_showScientific),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showScientific
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showScientific ? 'Hide functions' : 'Show functions',
                        style: TextStyle(
                          fontFamily: globalFontFamily,
                          fontSize:
                              globalFontSizeChange <= 17
                                  ? (globalFontSizeChange / 5) + 14
                                  : 14 - (globalFontSizeChange / 5),
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Buttons
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.6,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: _basicButtons.expand((row) => row).length,
                itemBuilder: (context, index) {
                  final text = _basicButtons
                      .expand((row) => row)
                      .elementAt(index);
                  //  if (text == '=') return _buildButtonEquals('=');
                  return _buildButton(text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    Color buttonColor;
    if (text == "C") {
      buttonColor = Colors.red[400]!;
    } else if (text == "=")
      buttonColor = Colors.green[400]!;
    else if (text == "⌫")
      buttonColor = Colors.blue[400]!;
    else if (_scientificButtons.contains(text))
      buttonColor = Colors.purple[400]!;
    else if (['÷', '×', '-', '+', '%'].contains(text))
      buttonColor = Colors.orange[400]!;
    else
      buttonColor = Colors.grey[200]!;

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(8),
      color: buttonColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _onButtonPressed(text),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 18
                      : 18 - (globalFontSizeChange / 5),
              fontFamily: globalFontFamily,
              fontWeight: FontWeight.bold,
              color:
                  buttonColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/*
showDialog(
  context: context,
  builder: (context) => const CalculatorPopup(),
);
*/
