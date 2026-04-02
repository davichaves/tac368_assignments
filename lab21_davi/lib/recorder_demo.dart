// Barrett Koster 2025
// 
// using record and just_audio:
// > flutter pub add record
// > flutter pub add just_audio

// You also need to add to macos/Runner/*.entitlements:
//    <key>com.apple.security.device.audio-input</key>
//    <true/>


// Run this file to do the demo.  All of the interesting stuff
// is in sound_state.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sound_state.dart';

void main()
{ runApp(const SayWhat());
}

class SayWhat extends StatelessWidget
{ const SayWhat({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context)
  { const title = "flutter sound demo, uses record and just_audio";
    return MaterialApp
    ( title: title,
      home: BlocProvider<SoundCubit>
      ( create: (context) => SoundCubit(),
        child: BlocBuilder<SoundCubit,SoundState>
        ( builder: (context,state)
          { return SayWhat1(title:title);
          },
        )
      )
    );
  }
}

class SayWhat1 extends StatelessWidget
{ final String title;
  const SayWhat1({super.key, required this.title});

  @override
  Widget build(BuildContext context)
  { SoundCubit sc = BlocProvider.of<SoundCubit>(context);

    return Scaffold
    ( appBar: AppBar(title: Text(title)),
      body: Column
      ( children: 
        [
          ElevatedButton
          ( onPressed: (){ sc.startRecording(); },
            child: Text("record"),
          ),
          ElevatedButton
          ( onPressed: (){ sc.stopRecording(); },
            child: Text("stop rec"),
          ),
          ElevatedButton
          ( onPressed: (){ sc.playRecording(); },
            child: Text("play"),
          ),
          ElevatedButton
          ( onPressed: (){ sc.stopPlaying(); },
            child: Text("stop play"),
          ),
        ],
      ),
    );
  }


}
