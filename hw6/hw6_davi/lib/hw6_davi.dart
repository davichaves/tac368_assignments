import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const DealOrNoDealApp());
}

class DealOrNoDealApp extends StatelessWidget {
  const DealOrNoDealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deal or No Deal - Davi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

enum GamePhase { pickingHold, pickingToOpen, dealerOffer, gameOver }

enum CaseStatus { hidden, hold, opened }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<int> _allValues = [
    1,
    5,
    10,
    100,
    1000,
    5000,
    10000,
    100000,
    500000,
    1000000,
  ];

  late List<int> _caseValues;
  late List<CaseStatus> _caseStatuses;

  GamePhase _phase = GamePhase.pickingHold;
  int? _holdCaseIndex;
  double _currentOffer = 0;
  String _message = "Select a suitcase to hold!";
  int _winnings = 0;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _formatCurrency(num value) {
    String str = value is double ? value.toStringAsFixed(2) : value.toString();
    List<String> parts = str.split('.');
    String formatted = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return parts.length > 1 ? '$formatted.${parts[1]}' : formatted;
  }

  void _startNewGame() {
    setState(() {
      _caseValues = List.from(_allValues)..shuffle(Random());
      _caseStatuses = List.generate(10, (_) => CaseStatus.hidden);
      _phase = GamePhase.pickingHold;
      _holdCaseIndex = null;
      _currentOffer = 0;
      _message = "Select a suitcase to hold! (0-9)";
      _winnings = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  void _calculateOffer() {
    int total = 0;
    int remainingCount = 0;
    for (int i = 0; i < 10; i++) {
      if (_caseStatuses[i] == CaseStatus.hidden ||
          _caseStatuses[i] == CaseStatus.hold) {
        total += _caseValues[i];
        remainingCount++;
      }
    }
    double expectedValue = total / remainingCount;
    _currentOffer = expectedValue * 0.9;
    setState(() {
      _phase = GamePhase.dealerOffer;
      _message =
          "Dealer offers \$${_formatCurrency(_currentOffer)}. Deal or No Deal? (d/n)";
    });
  }

  void _handleCaseSelection(int index) {
    if (index < 0 || index > 9) return;

    setState(() {
      if (_phase == GamePhase.pickingHold) {
        if (_caseStatuses[index] == CaseStatus.hidden) {
          _holdCaseIndex = index;
          _caseStatuses[index] = CaseStatus.hold;
          _phase = GamePhase.pickingToOpen;
          _message = "Now open a suitcase!";
        }
      } else if (_phase == GamePhase.pickingToOpen) {
        if (_caseStatuses[index] == CaseStatus.hidden) {
          _caseStatuses[index] = CaseStatus.opened;

          // Check if only hold case is left
          int remainingHidden = _caseStatuses
              .where((s) => s == CaseStatus.hidden)
              .length;
          if (remainingHidden == 0) {
            _winnings = _caseValues[_holdCaseIndex!];
            _phase = GamePhase.gameOver;
            _message =
                "Game Over! You win \$${_formatCurrency(_winnings)} from your case!";
          } else {
            _calculateOffer();
          }
        }
      }
    });
  }

  void _handleDeal() {
    if (_phase == GamePhase.dealerOffer) {
      setState(() {
        _winnings = _currentOffer.round(); // or keep double
        _phase = GamePhase.gameOver;
        _message =
            "Deal accepted! You win \$${_formatCurrency(_currentOffer)}!";
      });
    }
  }

  void _handleNoDeal() {
    if (_phase == GamePhase.dealerOffer) {
      setState(() {
        _phase = GamePhase.pickingToOpen;
        _message = "No Deal! Open another suitcase.";
      });
    }
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (_phase == GamePhase.dealerOffer) {
        if (event.logicalKey == LogicalKeyboardKey.keyD) {
          _handleDeal();
        } else if (event.logicalKey == LogicalKeyboardKey.keyN) {
          _handleNoDeal();
        }
      } else if (_phase == GamePhase.pickingHold ||
          _phase == GamePhase.pickingToOpen) {
        if (event.character != null &&
            RegExp(r'^[0-9]$').hasMatch(event.character!)) {
          int digit = int.parse(event.character!);
          _handleCaseSelection(digit);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Deal or No Deal - Davi'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startNewGame,
              tooltip: 'New Game',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                _message,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_phase == GamePhase.dealerOffer)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _handleDeal,
                      child: const Text('DEAL'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _handleNoDeal,
                      child: const Text('NO DEAL'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Values Table
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Values',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Divider(),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _allValues.length,
                                  itemBuilder: (context, index) {
                                    int val = _allValues[index];
                                    // check if val is revealed (i.e. in an opened case)
                                    bool isRevealed = false;
                                    for (int i = 0; i < 10; i++) {
                                      if (_caseValues[i] == val &&
                                          _caseStatuses[i] ==
                                              CaseStatus.opened) {
                                        isRevealed = true;
                                        break;
                                      }
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Container(
                                        color: isRevealed
                                            ? Colors.grey.shade300
                                            : Colors.amber.shade200,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '\$${_formatCurrency(val)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isRevealed
                                                ? Colors.grey
                                                : Colors.black,
                                            decoration: isRevealed
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Suitcases Grid
                    Expanded(
                      flex: 2,
                      child: GridView.builder(
                        itemCount: 10,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemBuilder: (context, index) {
                          CaseStatus status = _caseStatuses[index];

                          Color bgColor;
                          String text;

                          if (status == CaseStatus.opened) {
                            bgColor = Colors.grey;
                            text = '\$${_formatCurrency(_caseValues[index])}';
                          } else if (status == CaseStatus.hold) {
                            bgColor = Colors.blue;
                            text = 'Hold\n($index)';
                          } else {
                            bgColor = Colors.brown.shade400;
                            text = '$index';
                          }

                          return InkWell(
                            onTap: () {
                              _handleCaseSelection(index);
                              FocusScope.of(context).requestFocus(_focusNode);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
