import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MadLibApp());
}

class MadLibApp extends StatelessWidget {
  const MadLibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mad Libs - Davi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MadLibHomePage(title: 'Mad Libs - Davi'),
    );
  }
}

class MadLibHomePage extends StatefulWidget {
  const MadLibHomePage({super.key, required this.title});

  final String title;

  @override
  State<MadLibHomePage> createState() => _MadLibHomePageState();
}

class _MadLibHomePageState extends State<MadLibHomePage> {
  // Store the list of controllers for dynamic inputs
  final List<TextEditingController> _controllers = [];
  // Store the labels (e.g., place, animal) for the inputs
  final List<String> _labels = [];
  // Store the segments of the story to reconstruct it
  // This will store strings for static parts and special markers for dynamic parts
  final List<String> _storySegments = [];
  // Indices mapping: which controller corresponds to which placeholder in the segments
  // If segment is "$", the corresponding value in this list points to the controller index
  final List<int?> _segmentToControllerIndex = [];

  bool _isLoaded = false;
  String _story = '';
  bool _showStory = false;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    try {
      // Load the story from assets
      final String fileContent = await rootBundle.loadString(
        'assets/story.txt',
      );
      _parseStory(fileContent);
      setState(() {
        _isLoaded = true;
      });
    } catch (e) {
      debugPrint("Error loading story: $e");
    }
  }

  void _parseStory(String content) {
    _controllers.clear();
    _labels.clear();
    _storySegments.clear();
    _segmentToControllerIndex.clear();

    // Split by spaces to process words
    final words = content.split(' ');

    // We need to rebuild the segments carefully.
    // The requirement says:
    // $ type -> input
    // % index -> re-use input at index

    // However, splitting by space might separate punctuation.
    // For simplicity given the examples, we'll iterate through words.
    // A more robust parser would handle punctuation better, but let's stick to the prompt's simplicity.

    int currentControllerIndex = 0;

    for (int i = 0; i < words.length; i++) {
      String word = words[i];

      if (word == r'$') {
        // Next word is the type (label)
        if (i + 1 < words.length) {
          String type = words[i + 1];
          // Clean punctuation from type if simple split included it (though example shows clean spaces)
          // But let's assume the format is strictly "$ type" separated by spaces.

          // We found a placeholder
          _labels.add(type);
          _controllers.add(TextEditingController());

          _storySegments.add(r'$'); // Marker for "insert value here"
          _segmentToControllerIndex.add(currentControllerIndex);

          currentControllerIndex++;
          i++; // Skip the type word as we processed it
        }
      } else if (word == r'%') {
        // Next word is the index
        if (i + 1 < words.length) {
          String indexStr = words[i + 1];
          // It might have punctuation attached? The example says "% 1" or "% 1."
          // Let's try to parse integer.

          // Remove potential trailing punctuation for parsing
          String cleanIndexStr = indexStr.replaceAll(RegExp(r'[^0-9]'), '');
          int? index = int.tryParse(cleanIndexStr);

          if (index != null) {
            _storySegments.add(r'$'); // Treat as insertion point
            _segmentToControllerIndex.add(index);

            // If there was punctuation, we might have lost it.
            // But the prompt example "get the % 1" suggests it ends the sentence.
            // If "1." was the word, we want to keep the "."
            // Let's attach the non-digit part back if any?
            String punctuation = indexStr.replaceAll(RegExp(r'[0-9]'), '');
            if (punctuation.isNotEmpty) {
              _storySegments.add(punctuation);
              _segmentToControllerIndex.add(null);
            }

            i++; // Skip the index word
          } else {
            _storySegments.add(word);
            _segmentToControllerIndex.add(null);
          }
        }
      } else {
        // Regular word
        _storySegments.add(word);
        _segmentToControllerIndex.add(null);
      }
    }
  }

  void _generateStory() {
    StringBuffer sb = StringBuffer();

    for (int i = 0; i < _storySegments.length; i++) {
      String segment = _storySegments[i];
      int? controllerIndex = _segmentToControllerIndex[i];

      if (segment == r'$' && controllerIndex != null) {
        // It's a placeholder, get value from controller
        if (controllerIndex < _controllers.length) {
          sb.write(_controllers[controllerIndex].text);
        }
      } else {
        // It's a regular word or punctuation
        sb.write(segment);
      }

      // Add space if it's not the last element and next element is not punctuation (ideally)
      // Simple approach: Add space after every element, unless it matches specific punctuation rules.
      // But for this simple mad lib, let's just add space, but that might look gapsy with punctuation.
      // Let's try to be slightly smarter: don't add space if next char is punctuation.
      if (i < _storySegments.length - 1) {
        // Check if next segment is likely punctuation attached to previous?
        // In our parsing, we treated words as chunks.
        // If we allow "space separated" assumption from input file, simply re-joining with space is safest
        // matching the input format.
        sb.write(' ');
      }
    }

    setState(() {
      _showStory = true;
      _story = sb.toString();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Fill in the blanks below:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Dynamically generate text fields
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controllers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return TextField(
                  controller: _controllers[index],
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: _labels[index],
                    hintText: 'Enter a ${_labels[index]}',
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateStory,
              child: const Text('Show Story'),
            ),
            const SizedBox(height: 30),
            if (_showStory)
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _story,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
