import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/game_logic/game_machine_state.dart';
import '../../domain/models/game_model.dart';
import '../../orchestration/game_cubit.dart';
import '../../orchestration/game_state.dart';
import 'card_widget.dart';
import 'score_display_widget.dart';
import 'timer_display_widget.dart';

class GameBoardWidget extends StatelessWidget {
  GameBoardWidget({@required this.timedGame});
  final bool timedGame;

  @override
  Widget build(BuildContext context) {
    GameCubit gameCubit = BlocProvider.of<GameCubit>(context);
    GameState state = gameCubit.state;

    _showGameEnd(context, state.gameModel);

    return Column(
      children: [
        SizedBox(height: 10),
        ScoreDisplayWidget(
          score: state.gameModel.cardMatchCount,
          total: state.gameModel.numberOfUniqueCards,
        ),
        if (timedGame) TimerDisplayWidget(timeRemaining: state.timeRemaining),
        Expanded(
          child: GridView.count(
            crossAxisCount: state.gameModel.layoutWidth,
            padding: EdgeInsets.all(8.0),
            children: List.generate(
              state.gameModel.numberOfCards,
              (index) {
                return CardWidget(
                  key: Key('Card $index'),
                  cardModel: state.gameModel.cards[index],
                );
              },
            ),
            shrinkWrap: false,
          ),
        ),
      ],
    );
  }

  /// Show game end notification: win or lose.
  ///
  /// Called when game timer ends.
  /// Presently displays a snackbar with the option to return to the HomePage.
  /// TODO: Replace end game UI with an alert dialog or on-screen message.
  void _showGameEnd(BuildContext context, GameModel gameModel) {
    if (gameModel.state == GameMachineState.wonGame ||
        gameModel.state == GameMachineState.lostGame) {
      Future.delayed(Duration(seconds: 0), () {
        final String message = gameModel.state == GameMachineState.wonGame
            ? 'You won!'
            : 'Game over.';
        final scaffold = Scaffold.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: Duration(days: 365),
            action: SnackBarAction(
                label: 'HOME',
                onPressed: () {
                  scaffold.hideCurrentSnackBar();
                  Navigator.pop(context);
                }),
          ),
        );
      });
    }
  }
}
