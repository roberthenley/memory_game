import 'dart:async';

import 'package:memory_game/domain/models/game_model.dart';
import 'package:meta/meta.dart';

class GameState {
  GameState({
    @required this.gameModel,
    this.timedGame,
    this.gameStarted,
    @required this.timeRemaining,
    this.timer,
  });
  GameModel gameModel;
  bool timedGame = false;
  Timer timer;
  bool gameStarted = false;
  int timeRemaining;

  GameState copyWith({
    GameModel gameModel,
    bool gameStarted,
    int timeRemaining,
    Timer timer,
    bool timedGame,
  }) =>
      GameState(
        gameModel: gameModel ?? this.gameModel,
        gameStarted: gameStarted ?? this.gameStarted,
        timeRemaining: timeRemaining ?? this.timeRemaining,
        timer: timer ?? this.timer,
        timedGame: timedGame ?? this.timedGame,
      );
}
