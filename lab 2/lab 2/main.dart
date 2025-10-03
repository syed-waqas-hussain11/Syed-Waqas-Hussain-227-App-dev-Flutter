import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
  String _equation = "0";
  String _result = "0";
  String _expression = "";

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _equation = "0";
        _result = "0";
      } else if (buttonText == "DEL") {
        _equation = _equation.substring(0, _equation.length - 1);
        if (_equation == "") {
          _equation = "0";
        }
      } else if (buttonText == "=") {
        _expression = _equation;
        _expression = _expression.replaceAll('×', '*');
        _expression = _expression.replaceAll('÷', '/');

        try {
          // This is a simple way to evaluate the expression.
          // For a production app, you might want to use a more robust math expression evaluator package.
          _result = _evaluateExpression(_expression).toString();
        } catch (e) {
          _result = "Error";
        }
      } else {
        if (_equation == "0") {
          _equation = buttonText;
        } else {
          _equation = _equation + buttonText;
        }
      }
    });
  }

  double _evaluateExpression(String expression) {
    // A simple implementation of an expression evaluator.
    List<String> tokens = expression.split(RegExp(r'([+\-*/])'));
    List<String> operators =
    expression.split(RegExp(r'(\d+\.?\d*)')).where((s) => s.isNotEmpty).toList();

    List<double> numbers = tokens.map((t) => double.tryParse(t) ?? 0).toList();

    // Handle multiplication and division first
    for (int i = 0; i < operators.length; i++) {
      if (operators[i] == '*' || operators[i] == '/') {
        if (operators[i] == '*') {
          numbers[i] = numbers[i] * numbers[i+1];
        } else {
          numbers[i] = numbers[i] / numbers[i+1];
        }
        numbers.removeAt(i+1);
        operators.removeAt(i);
        i--;
      }
    }

    // Handle addition and subtraction
    double result = numbers[0];
    for (int i = 0; i < operators.length; i++) {
      if (operators[i] == '+') {
        result += numbers[i+1];
      } else if (operators[i] == '-') {
        result -= numbers[i+1];
      }
    }
    return result;
  }

  Widget _buildButton(
      String buttonText, double buttonHeight, Color buttonColor) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1 * buttonHeight,
      color: buttonColor,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: Colors.white,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Text(
              _equation,
              style: const TextStyle(fontSize: 38.0),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: Text(
              _result,
              style: const TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width * .75,
                child: Table(
                  children: [
                    TableRow(children: [
                      _buildButton("C", 1, Colors.redAccent),
                      _buildButton("DEL", 1, Colors.blue),
                      _buildButton("÷", 1, Colors.blue),
                    ]),
                    TableRow(children: [
                      _buildButton("7", 1, Colors.black54),
                      _buildButton("8", 1, Colors.black54),
                      _buildButton("9", 1, Colors.black54),
                    ]),
                    TableRow(children: [
                      _buildButton("4", 1, Colors.black54),
                      _buildButton("5", 1, Colors.black54),
                      _buildButton("6", 1, Colors.black54),
                    ]),
                    TableRow(children: [
                      _buildButton("1", 1, Colors.black54),
                      _buildButton("2", 1, Colors.black54),
                      _buildButton("3", 1, Colors.black54),
                    ]),
                    TableRow(children: [
                      _buildButton(".", 1, Colors.black54),
                      _buildButton("0", 1, Colors.black54),
                      _buildButton("00", 1, Colors.black54),
                    ]),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Table(
                  children: [
                    TableRow(children: [
                      _buildButton("×", 1, Colors.blue),
                    ]),
                    TableRow(children: [
                      _buildButton("-", 1, Colors.blue),
                    ]),
                    TableRow(children: [
                      _buildButton("+", 1, Colors.blue),
                    ]),
                    TableRow(children: [
                      _buildButton("=", 2, Colors.redAccent),
                    ]),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
