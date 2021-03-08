import 'dart:async';

import 'package:memory_game/domain/models/game_model.dart';

class GameState {
  GameState({
    required this.gameModel,
    this.timedGame = false,
    this.gameStarted = false,
    required this.timeRemaining,
    this.timer,
  });
  GameModel gameModel;
  bool timedGame;
  Timer? timer;
  bool gameStarted;
  int timeRemaining;

  GameState copyWith({
    GameModel? gameModel,
    bool? gameStarted,
    int? timeRemaining,
    Timer? timer,
    bool? timedGame,
  }) =>
      GameState(
        gameModel: gameModel ?? this.gameModel,
        gameStarted: gameStarted ?? this.gameStarted,
        timeRemaining: timeRemaining ?? this.timeRemaining,
        timer: timer ?? this.timer,
        timedGame: timedGame ?? this.timedGame,
      );
}
