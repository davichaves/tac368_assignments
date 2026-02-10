import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

void main() {
  runApp(const LightsOutApp());
}

class LightsOutApp extends StatelessWidget {
  const LightsOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lights Out - Davi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => LightsOutCubit(),
        child: const LightsOutView(),
      ),
    );
  }
}

class LightsOutState extends Equatable {
  final List<bool> lights;
  final String status;
  final int size;

  const LightsOutState({
    required this.lights,
    required this.status,
    required this.size,
  });

  LightsOutState copyWith({List<bool>? lights, String? status, int? size}) {
    return LightsOutState(
      lights: lights ?? this.lights,
      status: status ?? this.status,
      size: size ?? this.size,
    );
  }

  @override
  List<Object> get props => [lights, status, size];
}

class LightsOutCubit extends Cubit<LightsOutState> {
  LightsOutCubit()
    : super(const LightsOutState(lights: [], status: 'Playing', size: 9)) {
    _initializeLights();
  }

  void _initializeLights() {
    final random = Random();
    final List<bool> newLights = List.generate(
      state.size,
      (_) => random.nextBool(),
    );
    emit(state.copyWith(lights: newLights, status: 'Playing'));
    _checkWinCondition();
  }

  void toggleLight(int index) {
    if (state.status == 'Won') return;

    final List<bool> newLights = List.from(state.lights);

    // Toggle the clicked light
    newLights[index] = !newLights[index];

    // Toggle the left neighbor if it exists
    if (index > 0) {
      newLights[index - 1] = !newLights[index - 1];
    }

    // Toggle the right neighbor if it exists
    if (index < newLights.length - 1) {
      newLights[index + 1] = !newLights[index + 1];
    }

    emit(state.copyWith(lights: newLights));
    _checkWinCondition();
  }

  void _checkWinCondition() {
    if (state.lights.every((isOn) => !isOn)) {
      emit(state.copyWith(status: 'Won'));
    } else {
      emit(state.copyWith(status: 'Playing'));
    }
  }

  void increaseSize() {
    emit(state.copyWith(size: state.size + 1));
    _initializeLights();
  }

  void decreaseSize() {
    if (state.size > 1) {
      emit(state.copyWith(size: state.size - 1));
      _initializeLights();
    }
  }

  void reset() {
    _initializeLights();
  }
}

class LightsOutView extends StatelessWidget {
  const LightsOutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lights Out - Davi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<LightsOutCubit, LightsOutState>(
              builder: (context, state) {
                if (state.status == 'Won') {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'You Won!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(color: Colors.green),
                    ),
                  );
                }
                return Container();
              },
            ),
            BlocBuilder<LightsOutCubit, LightsOutState>(
              builder: (context, state) {
                return Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(state.lights.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        context.read<LightsOutCubit>().toggleLight(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: state.lights[index]
                              ? Colors.yellow
                              : Colors.black54,
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 20),
            BlocBuilder<LightsOutCubit, LightsOutState>(
              builder: (context, state) {
                return Text(
                  'Number of lights: ${state.size}',
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<LightsOutCubit>().decreaseSize();
                  },
                  child: const Text('Decrease'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<LightsOutCubit>().increaseSize();
                  },
                  child: const Text('Increase'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<LightsOutCubit>().reset();
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
