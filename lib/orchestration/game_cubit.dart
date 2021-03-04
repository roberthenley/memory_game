import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:memory_game/domain/game_logic/game_machine_state.dart';
import 'package:memory_game/domain/game_logic/game_state_machine.dart';
import 'package:memory_game/domain/models/card_model.dart';
import 'package:memory_game/domain/models/game_model.dart';
import 'package:meta/meta.dart';

import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit({
    @required GameModel initialGameModel,
    @required bool timedGame,
  }) : super(
          GameState(
            gameModel: initialGameModel ?? GameModel.newGame(),
            timeRemaining: initialGameModel.gameDurationSeconds,
            timedGame: timedGame,
          ),
        ) {
    if (state.gameModel.initialFaceUpSeconds > 0) {
      Future.delayed(Duration(seconds: state.gameModel.initialFaceUpSeconds),
          () {
        _startGame();
      });
    } else {
      _startGame();
    }
  }

  void _startGame() => emit(state.copyWith(
        gameModel: GameStateMachine.setNextState(
          model: state.gameModel,
          newState: GameMachineState.noCardsSelected,
        ),
        gameStarted: true,
        timer: Timer.periodic(
          const Duration(seconds: 1),
          (Timer timer) async {
            // print('time remaining: $_timeRemaining');
            if (state.gameModel.state == GameMachineState.wonGame) {
              // If game has been won, stop the timer.
              timer.cancel();
            } else if (state.timeRemaining == 0) {
              // print('time expired; transitioning to lostGame state');
              timer.cancel();
              _newGameMachineState(GameMachineState.lostGame);
            } else {
              _timerTickDown();
            }
          },
        ),
      ));

  void _newGameMachineState(GameMachineState newGameState) => emit(
        state.copyWith(
          gameModel: GameStateMachine.setNextState(
            model: state.gameModel,
            newState: newGameState,
          ),
        ),
      );

  void cardSelected(CardModel card) {
    GameState nextState = state.copyWith(
      gameModel: GameStateMachine.nextStateFromCard(
        model: state.gameModel,
        cardSelected: card,
      ),
    );
    if (nextState.gameModel.state ==
        GameMachineState.twoCardsSelectedNotMatching) {
      // Set delayed action to flip non-matching cards back over.
      var delaySeconds = nextState.gameModel.nonMatchingCardsFaceUpSeconds;
      try {
        Future.delayed(Duration(seconds: delaySeconds), () {
          // Verify game state machine still has 2 non-matching cards face up.
          // (The user could have selected a new card, preempting this delayed
          // action.)
          if (state.gameModel.state ==
              GameMachineState.twoCardsSelectedNotMatching) {
            emit(state.copyWith(
              gameModel: GameStateMachine.setNextState(
                model: nextState.gameModel,
                newState: GameMachineState.noCardsSelected,
              ),
            ));
          }
        });
      } catch (e, s) {
        print(s);
      }
    }
    emit(nextState);
  }

  void _timerTickDown() => emit(
        state.copyWith(timeRemaining: state.timeRemaining - 1),
      );

  @override
  Future<void> close() {
    state.timer?.cancel();
    return super.close();
  }
}
