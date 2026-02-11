// lab9_davi.dart
// Grocery List App using BLoC
// Based on file_stuff_bloc.dart

import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:path_provider/path_provider.dart";

// State to hold the list of groceries
class GroceryState {
  List<String> groceries;
  bool loaded;

  GroceryState(this.groceries, this.loaded);
}

// Cubit to manage the grocery list state
class GroceryCubit extends Cubit<GroceryState> {
  GroceryCubit() : super(GroceryState([], false));

  // Add an item to the list
  void add(String item) {
    if (item.trim().isEmpty) return;
    List<String> newList = List.from(state.groceries)..add(item);
    emit(GroceryState(newList, true));
  }

  // Remove an item from the list
  void remove(int index) {
    List<String> newList = List.from(state.groceries)..removeAt(index);
    emit(GroceryState(newList, true));
  }

  // Update the entire list (used for loading)
  void setList(List<String> items) {
    emit(GroceryState(items, true));
  }
}

void main() {
  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Grocery List - Davi",
      home: BlocProvider<GroceryCubit>(
        create: (context) => GroceryCubit(),
        child: const GroceryView(),
      ),
    );
  }
}

class GroceryView extends StatefulWidget {
  const GroceryView({super.key});

  @override
  State<GroceryView> createState() => _GroceryViewState();
}

class _GroceryViewState extends State<GroceryView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-load reference implementation logic:
    // The instructions say "If you stop and re-run... it should have the saved list."
    // We can trigger load here, or rely on a Load button like the reference.
    // Given "simple as possible" and matching reference, we'll execute a load
    // shortly after startup or just let the user click Load.
    // However, to strictly meet "should have the saved list" on re-run,
    // auto-loading is better. I'll add a post-frame callback to load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroceries(context.read<GroceryCubit>());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grocery List")),
      body: BlocBuilder<GroceryCubit, GroceryState>(
        builder: (context, state) {
          return Column(
            children: [
              // List of groceries
              Expanded(
                child: ListView.builder(
                  itemCount: state.groceries.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(state.groceries[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context.read<GroceryCubit>().remove(index);
                        },
                      ),
                    );
                  },
                ),
              ),

              // Divider
              const Divider(thickness: 2),

              // Input area
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Enter grocery item",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<GroceryCubit>().add(_controller.text);
                        _controller.clear();
                      },
                      child: const Text("Add"),
                    ),
                  ],
                ),
              ),

              // Action buttons (Save/Load)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _saveGroceries(state.groceries);
                      },
                      child: const Text("Save"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _loadGroceries(context.read<GroceryCubit>());
                      },
                      child: const Text("Load"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/groceries.txt";
  }

  Future<void> _saveGroceries(List<String> groceries) async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      // Join with a delimiter that is unlikely to be in a grocery item.
      // Newline is good for readability and simplicity.
      String data = groceries.join("\n");
      await file.writeAsString(data);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("List saved!")));
      }
    } catch (e) {
      print("Error saving: $e");
    }
  }

  Future<void> _loadGroceries(GroceryCubit cubit) async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      if (await file.exists()) {
        String contents = await file.readAsString();
        // Split by newline and filter out empty strings
        List<String> items = contents
            .split("\n")
            .where((s) => s.isNotEmpty)
            .toList();
        cubit.setList(items);
        if (mounted) {
          // Optional: feedback
          print("List loaded");
        }
      }
    } catch (e) {
      print("Error loading: $e");
    }
  }
}
