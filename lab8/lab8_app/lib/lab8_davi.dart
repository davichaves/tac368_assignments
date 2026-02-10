import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// State
class GridState {
  final int width;
  final int height;

  GridState({required this.width, required this.height});

  GridState copyWith({int? width, int? height}) {
    return GridState(width: width ?? this.width, height: height ?? this.height);
  }
}

// Cubit
class GridCubit extends Cubit<GridState> {
  GridCubit() : super(GridState(width: 4, height: 3));

  void incrementWidth() {
    emit(state.copyWith(width: state.width + 1));
  }

  void decrementWidth() {
    if (state.width > 1) {
      emit(state.copyWith(width: state.width - 1));
    }
  }

  void incrementHeight() {
    emit(state.copyWith(height: state.height + 1));
  }

  void decrementHeight() {
    if (state.height > 1) {
      emit(state.copyWith(height: state.height - 1));
    }
  }
}

void main() {
  runApp(const Lab8Davi());
}

class Lab8Davi extends StatelessWidget {
  const Lab8Davi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 8 Davi',
      home: BlocProvider(
        create: (context) => GridCubit(),
        child: const SizedGridView(),
      ),
    );
  }
}

class SizedGridView extends StatelessWidget {
  const SizedGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sized Grid Davi')),
      body: BlocBuilder<GridCubit, GridState>(
        builder: (context, state) {
          return Column(
            children: [
              // Controls
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text("Width"),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  context.read<GridCubit>().decrementWidth(),
                              icon: const Icon(Icons.remove),
                            ),
                            Text("${state.width}"),
                            IconButton(
                              onPressed: () =>
                                  context.read<GridCubit>().incrementWidth(),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        const Text("Height"),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  context.read<GridCubit>().decrementHeight(),
                              icon: const Icon(Icons.remove),
                            ),
                            Text("${state.height}"),
                            IconButton(
                              onPressed: () =>
                                  context.read<GridCubit>().incrementHeight(),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Grid
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(state.height, (y) {
                          return Row(
                            children: List.generate(state.width, (x) {
                              return const Boxy(40, 40);
                            }),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Boxy extends StatelessWidget {
  final double width;
  final double height;

  const Boxy(this.width, this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(border: Border.all()),
        child: const Center(child: Text("x")),
      ),
    );
  }
}
