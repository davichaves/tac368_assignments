// said_state.dart
// Barrett Koster 2025

import "dart:io";
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "yak_state.dart";
import "game_state.dart";

// Use this class to pass messages between two programs.
// It has access to the YakCubit so to listen for
// messages.  And it has access to the GameCubit
// so that it can send messages to it (to update the
// state of the game.

class SaidState
{
   List<String> messages;

   SaidState( this.messages );
}

class SaidCubit extends Cubit<SaidState>
{
  SaidCubit() : super( SaidState(["and so it begins ...."] ) );

  // void update( String more ) { emit(SaidState( "${state.said}$more\n" ) ); } 
  void update( String s ) { 
    List<String> newMessages = List.from(state.messages)..add(s);
    emit( SaidState(newMessages) ); 
  }

  void listen( BuildContext bc )
  { YakCubit yc = BlocProvider.of<YakCubit>(bc);
    YakState ys = yc.state;

    GameCubit gc = BlocProvider.of<GameCubit>(bc);
    // GameState gs = gc.state;
    
    ys.socket!.listen
    ( (Uint8List data) async
      { final message = String.fromCharCodes(data);
        if (message.startsWith("chat ")) {
          update(message.substring(5));
        } else {
          gc.handle(message);
        }
      },
          // handle errors
      onError: (error)
      { print(error);
        ys.socket!.close();
      },
    );
  }
}
