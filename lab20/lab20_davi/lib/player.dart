// player.dart
// Barrett Koster 2025

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "said_state.dart";
import "game_state.dart";
import "yak_state.dart";

/*
  A Player gets called for each of the ServerBase and the ClientBase.
  We establish the game state, usually different depending on 
  whether you are the starting player or not.  
  This establishes the Game and Said BLoC layers. 
*/
class Player extends StatelessWidget
{ final bool iStart;
  Player( this.iStart, {super.key} );

  @override
  Widget build( BuildContext context )
  { 
    return BlocProvider<GameCubit>
    ( create: (context) => GameCubit( iStart ),
      child: BlocBuilder<GameCubit,GameState>
      ( builder: (context,state) => 
        BlocProvider<SaidCubit>
        ( create: (context) => SaidCubit(),
          child: BlocBuilder<SaidCubit,SaidState>
          ( builder: (context,state) => Scaffold
            ( appBar: AppBar(title: Text("player")),
              body: Player2(),
            ),
          ),
        ),
      ),
    );
  }
}

// this layer initializes the communication.
// By this point, the socets exist in the YakState, but
// they have not yet been told to listen for messages.
class Player2 extends StatelessWidget
{ Widget build( BuildContext context )
  { YakCubit yc = BlocProvider.of<YakCubit>(context);
    YakState ys = yc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);

    if ( ys.socket != null && !ys.listened )
    { sc.listen(context);
      yc.updateListen();
    } 
    return Player3();
  }
}

// This is the actual presentation of the game.

class Player3 extends StatelessWidget
{ Player3( {super.key} );

  Widget build( BuildContext context )
  { SaidCubit sc = BlocProvider.of<SaidCubit>(context);
    SaidState ss = sc.state;
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    YakCubit yc = BlocProvider.of<YakCubit>(context);
    
    TextEditingController tec = TextEditingController();

    return SingleChildScrollView(
      child: Column
      ( children:
        [ Row(children: [ Sq(0), Sq(1), Sq(2)]),
          Row(children: [ Sq(3), Sq(4), Sq(5)]),
          Row(children: [ Sq(6), Sq(7), Sq(8)]),
          if (gs.winner != "") Text("Winner: ${gs.winner}", style: TextStyle(fontSize: 24)),
          if (gs.resignedBy == "opponent") Text("Opponent Resigned", style: TextStyle(fontSize: 24, color: Colors.red)),
          if (gs.resignedBy == "me") Text("You Resigned", style: TextStyle(fontSize: 24, color: Colors.blue)),
          ElevatedButton(
            onPressed: () {
              gc.resignLocally();
              yc.say("resign");
            },
            child: Text("Resign")
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(
                  controller: tec,
                  decoration: InputDecoration(hintText: "Enter chat message"),
                  onSubmitted: (val) {
                    if (val.isNotEmpty) {
                      sc.update("Me: $val");
                      yc.say("chat Opponent: $val");
                      tec.clear();
                    }
                  }
                )),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String val = tec.text;
                    if (val.isNotEmpty) {
                      sc.update("Me: $val");
                      yc.say("chat Opponent: $val");
                      tec.clear();
                    }
                  }
                )
              ]
            )
          ),
          ...ss.messages.map((m) => Text(m)).toList(),
        ]
      )
    );

  }
}

// the squares of the board are just buttons.  You press one 
// to play it.  We should have control here over whether it
// is your turn or not (but this is not added yet).
class Sq extends StatelessWidget
{ final int sn;
  Sq(this.sn,{super.key});

  Widget build( BuildContext context )
  { GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    // String mark = gs.iStart?"x":"o";

    YakCubit yc = BlocProvider.of<YakCubit>(context);
    
    return ElevatedButton
    ( onPressed: ()
      { 
        if (gs.board[sn] == GameCubit.d && gs.myTurn && gs.winner == "" && gs.resignedBy == "") {
          gc.play(sn);
          yc.say("sq $sn");
        }
      },
      child: Text(gs.board[sn]),
    );

  }
}