// game_state.dart
// Barrett Koster 2025

import "package:flutter_bloc/flutter_bloc.dart";

// This is where you put whatever the game is about.

class GameState
{
  bool iStart;
  bool myTurn;
  List<String> board;
  String winner;
  String resignedBy;

  GameState( this.iStart, this.myTurn, this.board, this.winner, this.resignedBy );
}

class GameCubit extends Cubit<GameState>
{
  static final String d = ".";
  GameCubit( bool myt ): super( GameState( myt, myt, [d,d,d,d,d,d,d,d,d], "", "" )); 

  String checkWin(List<String> b) {
    for(int i=0;i<9;i+=3) if(b[i]!=d && b[i]==b[i+1] && b[i]==b[i+2]) return b[i];
    for(int i=0;i<3;i++) if(b[i]!=d && b[i]==b[i+3] && b[i]==b[i+6]) return b[i];
    if(b[0]!=d && b[0]==b[4] && b[0]==b[8]) return b[0];
    if(b[2]!=d && b[2]==b[4] && b[2]==b[6]) return b[2];
    if(!b.contains(d)) return "draw";
    return "";
  }

  update( int where, String what )
  {
    state.board[where] = what;
    state.myTurn = !state.myTurn;
    String win = checkWin(state.board);
    emit( GameState(state.iStart,state.myTurn,state.board, win, state.resignedBy) ) ;
  }

  // Someone played x or o in this square.  (numbered from
  // upper left 0,1,2, next row 3,4,5 ... 
  // Update the board and emit.
  play( int where )
  { String mark = state.myTurn==state.iStart? "x":"o";
    state.board[where] = mark;
    state.myTurn = !state.myTurn;
    String win = checkWin(state.board);
    emit( GameState(state.iStart,state.myTurn,state.board, win, state.resignedBy) ) ;
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
    else if ( parts[0] == "resign" )
    {
      emit( GameState(state.iStart, state.myTurn, state.board, state.winner, "opponent") );
    }

  }

  void resignLocally() {
    emit( GameState(state.iStart, state.myTurn, state.board, state.winner, "me") );
  }
}