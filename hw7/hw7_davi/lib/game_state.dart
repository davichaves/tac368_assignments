import "package:flutter_bloc/flutter_bloc.dart";
import "yak_state.dart";

class GameState {
  bool isServer;
  bool myTurn;
  List<String> board;
  List<String> bag;
  List<String> rack;
  int myScore;
  int oppScore;
  int selectedRackIndex;

  GameState({
    required this.isServer,
    required this.myTurn,
    required this.board,
    required this.bag,
    required this.rack,
    required this.myScore,
    required this.oppScore,
    required this.selectedRackIndex,
  });

  GameState copyWith({
    bool? myTurn,
    List<String>? board,
    List<String>? bag,
    List<String>? rack,
    int? myScore,
    int? oppScore,
    int? selectedRackIndex,
  }) {
    return GameState(
      isServer: this.isServer,
      myTurn: myTurn ?? this.myTurn,
      board: board ?? List.from(this.board),
      bag: bag ?? List.from(this.bag),
      rack: rack ?? List.from(this.rack),
      myScore: myScore ?? this.myScore,
      oppScore: oppScore ?? this.oppScore,
      selectedRackIndex: selectedRackIndex ?? this.selectedRackIndex,
    );
  }
}

class GameCubit extends Cubit<GameState> {
  // exact Scrabble distribution (98 letters without blanks)
  static const String distribution =
      "AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ";

  GameCubit(bool isServer)
      : super(GameState(
          isServer: isServer,
          myTurn: false,
          board: List.filled(225, ""),
          bag: [],
          rack: [],
          myScore: 0,
          oppScore: 0,
          selectedRackIndex: -1,
        ));

  void initServerBag(YakCubit yc) {
    if (!state.isServer) return;
    List<String> initialBag = distribution.split('');
    initialBag.shuffle();
    String bagStr = initialBag.join(',');
    
    // send syncbag
    yc.say("syncbag $bagStr");
    
    _applyInitBag(initialBag.toList());
  }

  void _applyInitBag(List<String> newBag) {
    List<String> rack = [];
    // Server gets first 7, client gets next 7.
    if (state.isServer) {
      for (int i = 0; i < 7; i++) {
        if (newBag.isNotEmpty) rack.add(newBag.removeAt(0));
      }
      for (int i = 0; i < 7; i++) {
        if (newBag.isNotEmpty) newBag.removeAt(0); // discard client's tiles
      }
    } else {
      for (int i = 0; i < 7; i++) {
        if (newBag.isNotEmpty) newBag.removeAt(0); // discard server's tiles
      }
      for (int i = 0; i < 7; i++) {
        if (newBag.isNotEmpty) rack.add(newBag.removeAt(0));
      }
    }
    emit(state.copyWith(bag: newBag, rack: rack, myTurn: state.isServer));
  }

  void selectRack(int index) {
    emit(state.copyWith(selectedRackIndex: index));
  }

  void placeTile(int boardIndex, YakCubit yc) {
    if (!state.myTurn || state.selectedRackIndex == -1) return;
    if (state.board[boardIndex].isNotEmpty) return;

    String letter = state.rack[state.selectedRackIndex];
    
    List<String> newBoard = List.from(state.board);
    newBoard[boardIndex] = letter;

    List<String> newRack = List.from(state.rack);
    newRack.removeAt(state.selectedRackIndex);

    emit(state.copyWith(
      board: newBoard,
      rack: newRack,
      selectedRackIndex: -1,
      myScore: state.myScore + 1 // scoring is simple: 1 point per letter
    ));

    yc.say("play $boardIndex $letter");
  }

  void remotePlay(int boardIndex, String letter) {
    List<String> newBoard = List.from(state.board);
    newBoard[boardIndex] = letter;
    emit(state.copyWith(board: newBoard, oppScore: state.oppScore + 1));
  }

  void endTurn(YakCubit yc) {
    if (!state.myTurn) return;
    
    int needed = 7 - state.rack.length;
    List<String> newBag = List.from(state.bag);
    List<String> newRack = List.from(state.rack);
    
    int drawn = 0;
    while (needed > 0 && newBag.isNotEmpty) {
      newRack.add(newBag.removeAt(0));
      needed--;
      drawn++;
    }

    emit(state.copyWith(myTurn: false, bag: newBag, rack: newRack));
    yc.say("endturn $drawn");
  }

  void remoteEndTurn(int drawn) {
    List<String> newBag = List.from(state.bag);
    for (int i = 0; i < drawn; i++) {
      if (newBag.isNotEmpty) newBag.removeAt(0);
    }
    emit(state.copyWith(myTurn: true, bag: newBag, selectedRackIndex: -1));
  }

  void passTurn(YakCubit yc) {
    if (!state.myTurn) return;
    emit(state.copyWith(myTurn: false, selectedRackIndex: -1));
    yc.say("pass");
  }

  void remotePass() {
    emit(state.copyWith(myTurn: true));
  }

  void handle(String msg) {
    // we'll just process the first command for simplicity, string.split on space
    List<String> parts = msg.trim().split(" ");
    if (parts.isEmpty) return;

    if (parts[0] == "syncbag" && parts.length > 1) {
      String csv = parts[1];
      _applyInitBag(csv.split(','));
    } else if (parts[0] == "play" && parts.length > 2) {
      int idx = int.parse(parts[1]);
      String letter = parts[2];
      remotePlay(idx, letter);
    } else if (parts[0] == "endturn" && parts.length > 1) {
      int drawn = int.parse(parts[1]);
      remoteEndTurn(drawn);
    } else if (parts[0] == "pass") {
      remotePass();
    }
  }
}
