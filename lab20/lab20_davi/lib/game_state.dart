// game_state.dart
// Barrett Koster 2025

import "package:flutter_bloc/flutter_bloc.dart";

// This is where you put whatever the game is about.

class GameState
{
  bool iStart;
  bool myTurn;
  List<String> board;

  GameState( this.iStart, this.myTurn, this.board );
}

class GameCubit extends Cubit<GameState>
{
  static final String d = ".";
  GameCubit( bool myt ): super( GameState( myt, myt, [d,d,d,d,d,d,d,d,d] )); 

  update( int where, String what )
  {
    state.board[where] = what;
    state.myTurn = !state.myTurn;
    emit( GameState(state.iStart,state.myTurn,state.board) ) ;
  }

  // Someone played x or o in this square.  (numbered from
  // upper left 0,1,2, next row 3,4,5 ... 
  // Update the board and emit.
  play( int where )
  { String mark = state.myTurn==state.iStart? "x":"o";
    state.board[where] = mark;
    state.myTurn = !state.myTurn;
    emit( GameState(state.iStart,state.myTurn,state.board) ) ;
  }

  // incoming messages are sent here for the game to do
  // whatever with.  in this case, "sq NUM" messages ..
  // we send the number to be played.
  void handle( String msg )
  { List<String> parts = msg.split(" ");
    if ( parts[0] == "sq" )
    { int sqNum = int.parse(parts[1]);
      play(sqNum);
    }


  }
}