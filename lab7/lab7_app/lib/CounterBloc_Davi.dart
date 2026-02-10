import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Event: Represents an action that can happen (e.g., button press)
abstract class CounterEvent {}

class IncrementCounter extends CounterEvent {}

// Bloc: Manages the state (int) based on events (CounterEvent)
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<IncrementCounter>((event, emit) {
      emit(state + 1);
    });
  }
}

void main() {
  runApp(const Lab7App());
}

class Lab7App extends StatelessWidget {
  const Lab7App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 7 Davi Chaves',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        // BlocProvider makes the CounterBloc available to the widget tree
        create: (context) => CounterBloc(),
        child: const MyHomePage(title: 'Lab 7 Davi Chaves'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            // BlocBuilder listens for state changes and rebuilds the UI
            BlocBuilder<CounterBloc, int>(
              builder: (context, count) {
                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Use context.read to add an event to the Bloc without listening
          context.read<CounterBloc>().add(IncrementCounter());
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
