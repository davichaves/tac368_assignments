import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "said_state.dart";
import "game_state.dart";
import "yak_state.dart";

class Player extends StatelessWidget {
  final bool isServer;
  Player(this.isServer, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubit>(
      create: (context) => GameCubit(isServer),
      child: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) => BlocProvider<SaidCubit>(
          create: (context) => SaidCubit(),
          child: BlocBuilder<SaidCubit, SaidState>(
            builder: (context, state) => Player2(),
          ),
        ),
      ),
    );
  }
}

class Player2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    YakCubit yc = BlocProvider.of<YakCubit>(context);
    YakState ys = yc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);
    GameCubit gc = BlocProvider.of<GameCubit>(context);

    if (ys.socket != null && !ys.listened) {
      sc.listen(context);
      yc.updateListen();

      // If I am the server, initialize the game's shared bag.
      if (gc.state.isServer) {
        gc.initServerBag(yc);
      }
    }
    return Player3();
  }
}

class Player3 extends StatelessWidget {
  Player3({super.key});

  @override
  Widget build(BuildContext context) {
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    YakCubit yc = BlocProvider.of<YakCubit>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "P1(You): ${gs.myScore} | P2: ${gs.oppScore} - ${gs.myTurn ? 'YOUR TURN' : 'WAITING'}",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: GridView.builder(
                padding: const EdgeInsets.all(4.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 15,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 225,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      gc.placeTile(index, yc);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: gs.board[index].isEmpty
                            ? Colors.grey[200]
                            : Colors.blue[100],
                      ),
                      child: Center(
                        child: Text(
                          gs.board[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(gs.rack.length, (i) {
                bool isSelected = (i == gs.selectedRackIndex);
                return GestureDetector(
                  onTap: () {
                    gc.selectRack(i);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.black,
                        width: isSelected ? 3 : 1,
                      ),
                      color: Colors.orange[200],
                    ),
                    child: Center(
                      child: Text(
                        gs.rack[i],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: gs.myTurn ? () => gc.passTurn(yc) : null,
                  child: Text("Pass"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: gs.myTurn ? () => gc.endTurn(yc) : null,
                  child: Text("End Turn"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
