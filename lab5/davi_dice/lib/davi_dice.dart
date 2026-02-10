import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const Lab5Dice());
}

class Lab5Dice extends StatelessWidget {
  const Lab5Dice({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Davi Dice Lab 5',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DicePage(title: 'Davi Dice Lab 5'),
    );
  }
}

class DicePage extends StatefulWidget {
  const DicePage({super.key, required this.title});

  final String title;

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  // Initialize dice with 1
  final List<int> _diceValues = [1, 1, 1, 1, 1];
  // Initialize hold status as false
  final List<bool> _isHeld = [false, false, false, false, false];
  final Random _random = Random();

  // Function to roll the dice
  void _rollDice() {
    setState(() {
      for (int i = 0; i < _diceValues.length; i++) {
        if (!_isHeld[i]) {
          _diceValues[i] = _random.nextInt(6) + 1;
        }
      }
    });
  }

  // Function to toggle hold status for a specific die
  void _toggleHold(int index) {
    setState(() {
      _isHeld[index] = !_isHeld[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Dice Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Column(
                    children: [
                      Text(
                        _diceValues[index].toString(),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: _isHeld[index] ? Colors.red : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _toggleHold(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isHeld[index]
                              ? Colors.red.shade100
                              : null,
                        ),
                        child: Text(_isHeld[index] ? 'Held' : 'Hold'),
                      ),
                    ],
                  );
                }),
              ),
            ),
            // Roll Button
            FloatingActionButton.extended(
              onPressed: _rollDice,
              label: const Text('ROLL DICE', style: TextStyle(fontSize: 20)),
              icon: const Icon(Icons.casino),
            ),
          ],
        ),
      ),
    );
  }
}
