import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ConverterHomePage(title: 'CalcDavi'),
    );
  }
}

class ConverterHomePage extends StatefulWidget {
  const ConverterHomePage({super.key, required this.title});

  final String title;

  @override
  State<ConverterHomePage> createState() => _ConverterHomePageState();
}

class _ConverterHomePageState extends State<ConverterHomePage> {
  // State variables to hold the current raw input and the formatted output result
  String _input = '0';
  String _output = '';
  // Flag to determine if the next button press should start a fresh input (e.g. after a conversion)
  bool _newInputExpected = false;

  // Core logic handler triggered whenever any calculator button is pressed
  void _onKeyPress(String key) {
    setState(() {
      if (key == 'C') {
        // Clear everything and reset the calculator state
        _input = '0';
        _output = '';
        _newInputExpected = false;
      } else if (key == '±') {
        // Toggle negative/positive sign on the currently active input
        if (_input.startsWith('-')) {
          _input = _input.substring(1);
        } else {
          if (_input != '0' && _input != '') {
            _input = '-$_input';
          }
        }
      } else if (key == '.') {
        // Add a decimal point if one doesn't exist, or start a new decimal input if a calculation just finished
        if (_newInputExpected) {
          _input = '0.';
          _output = '';
          _newInputExpected = false;
        } else if (!_input.contains('.')) {
          _input += '.';
        }
      } else if (['F to C', 'C to F', 'lb to kg', 'kg to lb'].contains(key)) {
        // Perform the requested conversion on the current input value
        double? val = double.tryParse(_input);
        if (val != null) {
          double result = 0;
          String unit = '';
          if (key == 'F to C') {
            result = (val - 32) * 5 / 9;
            unit = '°C';
          } else if (key == 'C to F') {
            result = (val * 9 / 5) + 32;
            unit = '°F';
          } else if (key == 'lb to kg') {
            result = val * 0.453592;
            unit = 'kg';
          } else if (key == 'kg to lb') {
            result = val / 0.453592;
            unit = 'lb';
          }
          String resultStr = result.toStringAsFixed(4);
          if (resultStr.contains('.')) {
            resultStr = resultStr
                .replaceAll(RegExp(r'0*$'), '')
                .replaceAll(RegExp(r'\.$'), '');
          }
          _output = '$resultStr $unit';
          _newInputExpected = true;
        }
      } else {
        // Handle numeric input appending
        if (_newInputExpected) {
          // Start a fresh input sequence with the newly pressed number
          _input = key;
          _output = '';
          _newInputExpected = false;
        } else {
          if (_input == '0') {
            _input = key;
          } else if (_input == '-0') {
            _input = '-$key';
          } else {
            _input += key;
          }
        }
      }
    });
  }

  // Helper method to radically reduce boilerplate when constructing the keypad grid
  Widget _buildButton(String text, {Color? color, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => _onKeyPress(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // ==============================
          // TOP SECTION: The display area
          // ==============================
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              alignment: Alignment.bottomRight,
              // FittedBox ensures that if the numbers get too wide, they physically scale down rather than overflow
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _input,
                      style: TextStyle(
                        fontSize: 48,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _output,
                      style: TextStyle(
                        fontSize: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // ==============================
          // BOTTOM SECTION: The numeric and operations keypad
          // ==============================
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton(
                          'C',
                          color: Colors.red[100],
                          textColor: Colors.red[900],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('±'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('.'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildButton('0'),
                        _buildButton(
                          'F to C',
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        _buildButton(
                          'C to F',
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildButton(
                          'lb to kg',
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                        ),
                        _buildButton(
                          'kg to lb',
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
