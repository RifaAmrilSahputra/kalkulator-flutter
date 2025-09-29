import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String userInput = "";
  String? result;
  double? _lastResult;
  bool _justEvaluated = false;

  // NEW: history list
  final List<String> _history = [];

  final List<String> buttons = [
    "C",
    "⌫",
    "%",
    "/",
    "7",
    "8",
    "9",
    "×",
    "4",
    "5",
    "6",
    "-",
    "1",
    "2",
    "3",
    "+",
    "0",
    ".",
    "=",
  ];

  void _buttonPressed(String text) {
    setState(() {
      if (text == "C") {
        userInput = "";
        result = null;
        _lastResult = null;
        _justEvaluated = false;
      } else if (text == "⌫") {
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
        }
        _justEvaluated = false;
      } else if (text == "=") {
        _evaluateExpression();
      } else if (_isOperator(text)) {
        if (_justEvaluated && _lastResult != null) {
          userInput = _formatDoubleForExpression(_lastResult!) + text;
          _justEvaluated = false;
          result = null;
        } else {
          if (userInput.isEmpty) {
            if (_lastResult != null) {
              userInput = _formatDoubleForExpression(_lastResult!) + text;
            }
          } else {
            if (_isOperator(userInput[userInput.length - 1])) {
              userInput = userInput.substring(0, userInput.length - 1) + text;
            } else {
              userInput += text;
            }
          }
        }
      } else {
        if (_justEvaluated) {
          userInput = text;
          result = null;
          _justEvaluated = false;
        } else {
          if (text == ".") {
            String lastNumber = _getLastNumber(userInput);
            if (lastNumber.contains(".")) return;
            if (lastNumber.isEmpty) {
              userInput += "0";
            }
          }
          userInput += text;
        }
      }
    });
  }

  void _evaluateExpression() {
    if (userInput.isEmpty) return;
    try {
      String sanitized = userInput.trim();
      while (sanitized.isNotEmpty &&
          (_isOperator(sanitized[sanitized.length - 1]) ||
              sanitized[sanitized.length - 1] == '.')) {
        sanitized = sanitized.substring(0, sanitized.length - 1);
      }
      if (sanitized.isEmpty) return;

      sanitized = sanitized.replaceAll('×', '*').replaceAll('÷', '/');
      sanitized = sanitized.replaceAll('%', '/100');

      Parser p = Parser();
      Expression exp = p.parse(sanitized);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      _lastResult = eval;
      result = _formatDouble(eval);
      _justEvaluated = true;

      // Tambahkan ke history
      _history.insert(0, "$userInput = $result");
    } catch (e) {
      result = "Error";
      _lastResult = null;
      _justEvaluated = true;
    }
  }

  String _formatDouble(double val) {
    if (val == val.truncateToDouble()) {
      return val.toInt().toString();
    } else {
      String s = val.toStringAsFixed(8);
      s = s.replaceFirst(RegExp(r'\.?0+$'), '');
      return s;
    }
  }

  String _formatDoubleForExpression(double val) {
    return _formatDouble(val);
  }

  bool _isOperator(String x) {
    return (x == "%" ||
        x == "/" ||
        x == "×" ||
        x == "-" ||
        x == "+" ||
        x == "=");
  }

  String _getLastNumber(String expr) {
    if (expr.isEmpty) return "";
    int i = expr.length - 1;
    StringBuffer buf = StringBuffer();
    while (i >= 0) {
      String ch = expr[i];
      if ((ch.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
              ch.codeUnitAt(0) <= '9'.codeUnitAt(0)) ||
          ch == '.') {
        buf.write(ch);
        i--;
      } else {
        break;
      }
    }
    return String.fromCharCodes(buf.toString().runes.toList().reversed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // History Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 120,
              child: ListView.builder(
                reverse: true,
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return Text(
                    _history[index],
                    style: const TextStyle(fontSize: 18, color: Colors.white54),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),

            // Display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        userInput,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        result ?? "",
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Buttons
            Expanded(
              flex: 2,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                itemCount: buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final value = buttons[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: _buttonColor(value),
                        foregroundColor: Colors.white,
                        shadowColor: Colors.black54,
                        elevation: 6,
                      ),
                      onPressed: () => _buttonPressed(value),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: _textColor(value),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _buttonColor(String value) {
    if (value == "C" || value == "⌫") {
      return Colors.redAccent;
    } else if (_isOperator(value)) {
      return Colors.orange;
    } else {
      return const Color(0xFF2C2C2E);
    }
  }

  Color _textColor(String value) {
    return Colors.white;
  }
}
