// Barrett Koster 2025

// This is the core of sound record and playback
// capability.

// This requires access to files on your computer, so
// those of your with file trouble ... sorry.

// This uses and AudioPlayer and an AudioRecorder from just_audio


// import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

class SoundState
{
  AudioPlayer player;
  AudioRecorder recorder;
  bool isRecording;
  double currentPosition = 0;
  double totalDuration = 0;

  String? filePath;

  // constructor.  We use this one when we emit() to change the
  // boold and double variables, NOT the recorder and player.
  SoundState
  ( { required this.player, 
      required this.recorder,
      required this.isRecording,
      required this.filePath,
    }
  );

  // constructor that creates the needed recorder and player.
  // Call this one to get started.
  SoundState.init() 
  : player=AudioPlayer(),
    recorder = AudioRecorder(),
    isRecording = false ;

  void dispose()
  { player.dispose();
    recorder.dispose();
  }
}

class SoundCubit extends Cubit<SoundState>
{
  SoundCubit() :super( SoundState.init() );

  Future<void> startRecording() async
  { 
    final bool hasPermish = await state.recorder.hasPermission();
    if (!hasPermish)
    { print("no permission to record");
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final filename = "bob.m4a";

    // no, do not set it until it works, will be set after
    // recording.  
    // state.filePath = "${dir.path}/$filename";

    final path = "${dir.path}/$filename";

    // magic numbers much?
    const config = RecordConfig
    ( encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      bitRate: 128000,
    );

    await state.recorder.start(config,path: path);
    emit( SoundState
          ( player:state.player, 
            recorder: state.recorder,
            isRecording: true,
            filePath: state.filePath,
          ) );
  }

  void stopRecording() async
  {
    final path = await state.recorder.stop();
    print("sound file path = $path");
    emit( SoundState
          ( player:state.player, 
            recorder: state.recorder,
            isRecording: false,
            filePath: path,
          ) );
  }

  Future<void> playRecording() async
  {
    if (state.filePath != null )
    {
      await state.player.setFilePath( state.filePath! );
      // we can get the duration here if we want
      state.player.play();
      // we can set the playback start point to something
      // other than zero if we want.
    }
  }

  Future<void> stopPlaying() async
  {
    await state.player.stop();
  }

}