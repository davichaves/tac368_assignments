// yak_state.dart
import "dart:io";
import "package:flutter_bloc/flutter_bloc.dart";

class YakState {
  Socket? socket;
  bool listened = false;

  YakState(this.socket, this.listened);
}

class YakCubit extends Cubit<YakState> {
  YakCubit(String ip) : super(YakState(null, false)) {
    connectClient(ip);
  }

  Future<void> connectClient(String ip) async {
    print("YakCubit connectClient running ... ");
    await Future.delayed(const Duration(seconds: 2));
    final serv = await Socket.connect(ip, 9203);
    print('Connected to: ${serv.remoteAddress.address}:${serv.remotePort}');
    updateSocket(serv);
  }

  YakCubit.server(ServerSocket? ss) : super(YakState(null, false)) {
    if (ss != null) {
      connectServer(ss);
    }
  }

  Future<void> connectServer(ServerSocket ss) async {
    print("Listening for client to call on port 9203 ....");
    ss.listen((client) {
      print("Client connected");
      updateSocket(client);
    });
  }

  updateSocket(Socket s) {
    emit(YakState(s, false));
  }

  updateListen() {
    emit(YakState(state.socket, true));
  }

  void say(String msg) {
    if (state.socket != null) {
      state.socket!.write(msg);
    }
  }
}
