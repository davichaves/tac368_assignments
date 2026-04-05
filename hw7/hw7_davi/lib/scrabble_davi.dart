import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "server_state.dart";
import "yak_state.dart";
import "player.dart";

void main() {
  runApp(ServerOrClient());
}

class ServerOrClient extends StatelessWidget {
  ServerOrClient({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController tec = TextEditingController();
    tec.text = "localhost";

    return MaterialApp(
      title: "Scrabble Clone",
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Scrabble - Choose Role")),
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ServerBase()),
                    );
                  },
                  child: Text("Host (Server)"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ClientBase(tec.text),
                      ),
                    );
                  },
                  child: Text("Join (Client)"),
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: TextField(
                    controller: tec,
                    decoration: InputDecoration(labelText: "IP Address"),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ServerBase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ServerCubit>(
      create: (context) => ServerCubit(),
      child: BlocBuilder<ServerCubit, ServerState>(
        builder: (context, state) {
          ServerCubit sc = BlocProvider.of<ServerCubit>(context);
          ServerState ss = sc.state;
          return ss.server == null
              ? Scaffold(body: Center(child: Text("Loading Server...")))
              : BlocProvider<YakCubit>(
                  create: (context) => YakCubit.server(ss.server),
                  child: BlocBuilder<YakCubit, YakState>(
                    builder: (context, state) {
                      YakCubit yc = BlocProvider.of<YakCubit>(context);
                      YakState ys = yc.state;
                      return ys.socket == null
                          ? Scaffold(body: Center(child: Text("Waiting for client to call on 9203...")))
                          : Player(true);
                    },
                  ),
                );
        },
      ),
    );
  }
}

class ClientBase extends StatelessWidget {
  final String ip;
  ClientBase(this.ip, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<YakCubit>(
      create: (context) => YakCubit(ip),
      child: BlocBuilder<YakCubit, YakState>(
        builder: (context, state) {
          YakCubit yc = BlocProvider.of<YakCubit>(context);
          YakState ys = yc.state;
          return ys.socket == null
             ? Scaffold(body: Center(child: Text("Connecting to $ip...")))
             : Player(false);
        },
      ),
    );
  }
}
