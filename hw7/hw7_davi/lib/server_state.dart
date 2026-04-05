// server_state.dart
import "dart:io";
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerState {
  ServerSocket? server;
  ServerState(this.server);
}

class ServerCubit extends Cubit<ServerState> {
  ServerCubit() : super(ServerState(null)) {
    connect();
  }

  Future<void> connect() async {
    await Future.delayed(const Duration(seconds: 2));
    ServerSocket s = await ServerSocket.bind("0.0.0.0", 9203);
    print("Server socket created at ${s.address.address}:${s.port}");
    emit(ServerState(s));
  }
}
