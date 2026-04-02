import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sound_state.dart';

// Davi Chaves
// Simple Soundboard
// TAC368

void main() {
  runApp(const SimpleSoundboardApp());
}

class SimpleSoundboardApp extends StatelessWidget {
  const SimpleSoundboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Soundboard - Davi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider<SoundCubit>(
        create: (context) => SoundCubit(),
        child: const SoundboardHome(),
      ),
    );
  }
}

class SoundboardHome extends StatelessWidget {
  const SoundboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Soundboard - Davi')),
      body: BlocBuilder<SoundCubit, SoundState>(
        builder: (context, state) {
          SoundCubit sc = BlocProvider.of<SoundCubit>(context);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  state.isRecording
                      ? 'Recording...'
                      : (state.filePath != null
                            ? 'Ready to play!'
                            : 'Ready to record'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Record Controls
                ElevatedButton.icon(
                  onPressed: state.isRecording
                      ? null
                      : () => sc.startRecording(),
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Recording'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: state.isRecording
                      ? () => sc.stopRecording()
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Recording'),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                // Playback Controls
                const Text(
                  'Playback Rules:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: state.filePath != null && !state.isRecording
                      ? () async {
                          await sc.state.player.setFilePath(state.filePath!);
                          await sc.state.player.setSpeed(1.0);
                          await sc.state.player.setVolume(1.0);
                          sc.state.player.play();
                        }
                      : null,
                  child: const Text('Play Normal'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: state.filePath != null && !state.isRecording
                      ? () async {
                          await sc.state.player.setFilePath(state.filePath!);
                          await sc.state.player.setSpeed(2.0); // Fast speed
                          await sc.state.player.setVolume(1.0);
                          sc.state.player.play();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                  ),
                  child: const Text(
                    'Play Fast (Speed x2)',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: state.filePath != null && !state.isRecording
                      ? () async {
                          await sc.state.player.setFilePath(state.filePath!);
                          await sc.state.player.setSpeed(0.5); // Slow speed
                          await sc.state.player.setVolume(1.0);
                          sc.state.player.play();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text(
                    'Play Slow (Speed x0.5)',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: state.filePath != null && !state.isRecording
                      ? () async {
                          await sc.state.player.setFilePath(state.filePath!);
                          await sc.state.player.setSpeed(1.0);
                          await sc.state.player.setVolume(0.2); // Quiet
                          sc.state.player.play();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                  ),
                  child: const Text(
                    'Play Quiet (Volume x0.2)',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: () => sc.stopPlaying(),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Stop Playback'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
