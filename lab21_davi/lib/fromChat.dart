// Barrett Koster   2026
// I got this from ChatGPT.

// I am adding to the macos/Runner/*.entitlements files ....
//     <key>com.apple.security.device.audio-input</key>
//    <true/>

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:record/record.dart'; // > flutter pub add record

void main()
{
  runApp(const MaterialApp(home: RecorderPage()));
}

class RecorderPage extends StatefulWidget {
  const RecorderPage({super.key});

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  String? _savedPath;
  String? _status;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() => _status = 'Microphone permission denied.');
      return;
    }

    final dir = Directory.systemTemp.path;
    final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    final path = '$dir/$fileName';

    try {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );
      setState(() {
        _isRecording = true;
        _status = 'Recording...';
        _savedPath = null;
      });
    } catch (e) {
      setState(() => _status = 'Failed to start: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _savedPath = path;
        _status = path == null ? 'Recording stopped.' : 'Saved to: $path';
      });
    } catch (e) {
      setState(() => _status = 'Failed to stop: $e');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _recorder.cancel();
      setState(() {
        _isRecording = false;
        _savedPath = null;
        _status = 'Recording canceled.';
      });
    } catch (e) {
      setState(() => _status = 'Failed to cancel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sound Recorder')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_status ?? 'Ready'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: const Text('Start recording'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: const Text('Stop recording'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isRecording ? _cancelRecording : null,
              child: const Text('Cancel'),
            ),
            const SizedBox(height: 24),
            if (_savedPath != null) ...[
              const Text('Last saved file:'),
              SelectableText(_savedPath!),
            ],
          ],
        ),
      ),
    );
  }
}