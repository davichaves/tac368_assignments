// said_state.dart
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "yak_state.dart";
import "game_state.dart";

class SaidState {
  String said;
  SaidState(this.said);
}

class SaidCubit extends Cubit<SaidState> {
  SaidCubit() : super(SaidState("Game Started..."));

  void update(String s) {
    emit(SaidState(s));
  }

  void listen(BuildContext bc) {
    YakCubit yc = BlocProvider.of<YakCubit>(bc);
    YakState ys = yc.state;
    GameCubit gc = BlocProvider.of<GameCubit>(bc);
    
    ys.socket!.listen(
      (Uint8List data) {
        final message = String.fromCharCodes(data);
        print("Received: $message");
        update(message);
        gc.handle(message);
      },
      onError: (error) {
        print(error);
        ys.socket!.close();
      },
      onDone: () {
        print("Socket closed");
      }
    );
  }
}
