import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

// Entry point for the application, so this file can be run standalone
void main() {
  runApp(const QuizzleApp());
}

// Main application widget that sets up the theme and initial screen
class QuizzleApp extends StatelessWidget {
  const QuizzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SelectionScreen(),
    );
  }
}

// Data class to hold a single question and its corresponding answer
class QuestionAnswer {
  final String question;
  final String answer;

  QuestionAnswer(this.question, this.answer);
}

// Screen where the user selects the data file and quiz mode (Multiple Choice / Fill in Blank)
class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  // Option to toggle between Multiple Choice and Fill in the Blank modes
  bool isMultipleChoice = true;

  // Loads the selected file, parses the data, and navigates to the quiz screen
  Future<void> _loadQuiz(String filename) async {
    try {
      // Read the file from the assets directory
      final String fileContent = await rootBundle.loadString(
        'assets/$filename',
      );

      // Split the content into individual lines. Trim whitespace and newlines attached to ends
      final List<String> lines = fileContent.trim().split('\n');

      if (lines.isEmpty) return;

      // The first line contains the header (e.g., "state,capital"), so we skip it based on assignment specs.
      // We parse the remaining lines into QuestionAnswer objects
      final List<QuestionAnswer> qaList = [];
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // Split by the first comma to separate question and answer
        final parts = line.split(',');
        if (parts.length >= 2) {
          // The question and answers might have spaces, so trim trailing spaces but no commas
          qaList.add(QuestionAnswer(parts[0].trim(), parts[1].trim()));
        }
      }

      // Shuffle the list of questions for random order
      qaList.shuffle();

      if (mounted) {
        // Navigate to the quiz screen, passing the parsed list and selected quiz mode
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              qaList: qaList,
              isMultipleChoice: isMultipleChoice,
              title: filename.replaceAll('.txt', ''),
            ),
          ),
        );
      }
    } catch (e) {
      // Show an error snackbar if the file cannot be loaded for some reason
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading quiz file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Basic UI for file and mode selection
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzle - Select Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select a quiz topic:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loadQuiz('Elements.txt'),
              child: const Text('Elements', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _loadQuiz('StateCapitals.txt'),
              child: const Text(
                'State Capitals',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 40),
            // Switch to toggle between multiple choice and fill-in-the-blank modes for extra credit
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Fill in Blank', style: TextStyle(fontSize: 18)),
                Switch(
                  value: isMultipleChoice,
                  onChanged: (val) {
                    setState(() {
                      isMultipleChoice = val;
                    });
                  },
                ),
                const Text('Multiple Choice', style: TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// The main screen where the quiz happens (presents questions, gets answers, gives feedback)
class QuizScreen extends StatefulWidget {
  final List<QuestionAnswer> qaList;
  final bool isMultipleChoice;
  final String title;

  const QuizScreen({
    super.key,
    required this.qaList,
    required this.isMultipleChoice,
    required this.title,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex =
      0; // Tracks which question in the list we are currently on
  int _score = 0; // Cumulative number of correct answers
  int _totalAnswered = 0; // Total questions answered so far

  bool _hasAnswered =
      false; // Boolean flag to track whether the user has submitted an answer to the current question
  String _feedbackMessage =
      ''; // Message to show whether the user was right or wrong
  Color _feedbackColor =
      Colors.black; // Color formatting of the feedback message text

  // Controller for reading text input in fill-in-the-blank mode
  final TextEditingController _textController = TextEditingController();

  // The currently selected radio button option (only used in multiple choice mode)
  String? _selectedOption;

  // The list of 4 options for the current multiple choice question
  List<String> _currentOptions = [];

  @override
  void initState() {
    super.initState();
    _setupQuestion();
  }

  // Prepares the options and resets state fields when moving to a new question
  void _setupQuestion() {
    if (widget.qaList.isEmpty) return;

    // Reset state for new question
    _hasAnswered = false;
    _feedbackMessage = '';
    _selectedOption = null;
    _textController.clear();

    // If multiple choice mode, generate the distractor options
    if (widget.isMultipleChoice) {
      _currentOptions = _generateMultipleChoiceOptions();
    }
  }

  // Generates 4 options for a multiple choice question: the 1 correct answer and 3 random distractors
  List<String> _generateMultipleChoiceOptions() {
    final currentAnswer = widget.qaList[_currentIndex].answer;
    // Set to avoid duplicate options
    final Set<String> options = {currentAnswer};
    final random = Random();

    // Randomly pick unique distractors from other questions
    while (options.length < 4 && options.length < widget.qaList.length) {
      int randIndex = random.nextInt(widget.qaList.length);
      options.add(widget.qaList[randIndex].answer);
    }

    final optionsList = options.toList();
    // Shuffle the options so the correct answer isn't always predictably at index 0
    optionsList.shuffle();
    return optionsList;
  }

  // Validates the user's answer and calculates the score update
  void _checkAnswer() {
    // Prevent checking multiple times if already answered
    if (_hasAnswered) return;

    String userAnswer = '';

    if (widget.isMultipleChoice) {
      if (_selectedOption == null) {
        // User hasn't selected anything yet, remind them
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an option first!')),
        );
        return;
      }
      userAnswer = _selectedOption!;
    } else {
      userAnswer = _textController.text.trim();
      if (userAnswer.isEmpty) {
        // User hasn't typed anything yet, remind them
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an answer first!')),
        );
        return;
      }
    }

    // Retrieve what the correct answer should be
    final correctAnswer = widget.qaList[_currentIndex].answer;

    setState(() {
      _hasAnswered = true;
      _totalAnswered++;

      // Check if user answer matches the correct answer (using .toLowerCase() makes it case-insensitive which is nice for fill in the blank)
      if (userAnswer.toLowerCase() == correctAnswer.toLowerCase()) {
        _score++;
        _feedbackMessage = 'Correct!';
        _feedbackColor = Colors.green;
      } else {
        // Give feedback specifying the correct answer
        _feedbackMessage = 'Wrong! The right answer is: $correctAnswer';
        _feedbackColor = Colors.red;
      }
    });
  }

  // Moves to the next question, or indicates completion if at the end of the quiz
  void _nextQuestion() {
    setState(() {
      if (_currentIndex < widget.qaList.length - 1) {
        _currentIndex++;
        _setupQuestion();
      } else {
        // We reached the end of the question list, show the final score message
        _feedbackMessage =
            'Quiz Complete! Final Score: $_score / $_totalAnswered';
        _feedbackColor = Colors.blue;
        _hasAnswered = true; // Lock UI since quiz is over
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.qaList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final currentQuestion = widget.qaList[_currentIndex].question;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top UI row showing progression (e.g., Question 1 of 50) and current Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${widget.qaList.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Score: $_score / $_totalAnswered',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // The Question text being asked
            Text(
              currentQuestion,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Multiple Choice vs Fill in the blank dynamic UI rendering
            if (widget.isMultipleChoice)
              // Dynamically build radio buttons mapped for each of the multiple choice options
              ..._currentOptions.map(
                (option) => RadioListTile<String>(
                  title: Text(option, style: const TextStyle(fontSize: 18)),
                  value: option,
                  groupValue: _selectedOption,
                  onChanged: _hasAnswered
                      ? null // Lock changes to the radio buttons after user clicks submit
                      : (value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                ),
              )
            else
              // Only render a text field for fill-in-the-blank mode
              TextField(
                controller: _textController,
                enabled:
                    !_hasAnswered, // Disable typing directly after submission
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Your Answer',
                ),
                onSubmitted: (_) =>
                    _checkAnswer(), // Allow pressing "enter" to submit nicely
              ),

            const SizedBox(height: 30),

            // Displays the correct/wrong feedback text below the inputs if they clicked check
            if (_hasAnswered)
              Text(
                _feedbackMessage,
                style: TextStyle(
                  fontSize: 20,
                  color: _feedbackColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

            const Spacer(),

            // Row containing the primary action buttons: Check Answer & Next Question
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  // Disable Check Answer button if they already answered to prevent multi-clicking
                  onPressed: _hasAnswered ? null : _checkAnswer,
                  child: const Text(
                    'Check Answer',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  // Disable Next Question button if they haven't answered current question yet
                  // Also disable if we are at the end of the quiz
                  onPressed:
                      (!_hasAnswered ||
                          _currentIndex == widget.qaList.length - 1)
                      ? null
                      : _nextQuestion,
                  child: const Text(
                    'Next Question',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
