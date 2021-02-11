import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:memory_game/models/card_assets.dart';

import 'card_view.dart';
import 'game_logic/game_state_machine.dart';
import 'models/card_model.dart';
import 'models/game_model.dart';
import 'models/game_settings.dart';
import 'models/game_state.dart';

class GameBoardView extends StatefulWidget {
  @override
  _GameBoardViewState createState() => _GameBoardViewState();
}

class _GameBoardViewState extends State<GameBoardView> {
  GameModel _gameModel;
  Timer _timer;
  int _timeRemaining = GameSettings.gameDurationSeconds;

  void startTimer() {
    _timer = new Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        // print('time remaining: $_timeRemaining');
        if (_gameModel.state == GameState.WON) {
          // If game has been won, stop the timer.
          timer.cancel();
        } else if (_timeRemaining == 0) {
          // print('time expired; transitioning to LOST state');
          setState(() {
            timer.cancel();
            _gameModel = GameStateMachine.setNextState(
              model: _gameModel,
              newState: GameState.LOST,
            );
          });
          showGameEnd();
        } else {
          setState(() {
            _timeRemaining--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _gameModel = GameModel.newGame();
    Future.delayed(Duration(seconds: GameSettings.initialFaceUpSeconds), () {
      setState(() {
        _gameModel = GameStateMachine.setNextState(
          model: _gameModel,
          newState: GameState.NO_CARDS_SELECTED,
        );
        startTimer();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        ScoreDisplayView(gameModel: _gameModel),
        SizedBox(height: 4),
        Center(
          child: Text(
            '$_timeRemaining seconds',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? GameSettings.layoutWidth
                    : GameSettings.layoutHeight,
            padding: EdgeInsets.all(8.0),
            children: List.generate(
              GameSettings.numberOfCards,
              (index) {
                return CardView(
                  cardModel: _gameModel.cards[index],
                  callback: _onCardSelected,
                );
              },
            ),
            shrinkWrap: false,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onCardSelected(CardModel card) {
    if (card.isSelectable) {
      setState(() {
        _gameModel = GameStateMachine.nextStateFromCard(
            model: _gameModel, cardSelected: card);
      });

      if (_gameModel.state == GameState.TWO_CARDS_SELECTED_NOT_MATCHING) {
        Future.delayed(
            Duration(seconds: GameSettings.nonMatchingCardsFaceUpSeconds), () {
          setState(() {
            _gameModel = GameStateMachine.setNextState(
              model: _gameModel,
              newState: GameState.NO_CARDS_SELECTED,
            );
          });
        });
        Iterable<CardModel> selectedCards = _gameModel.getAllSelectedCards();
        String announcement =
            'Selected ${selectedCards.first} and ${selectedCards.last} which do not match.';
        SemanticsService.announce(announcement, TextDirection.ltr);
      } else if (_gameModel.state == GameState.NO_CARDS_SELECTED) {
        String cardName = CardAssets.getCardName(card.cardFaceAssetPath);
        String message =
            'Matched two $cardName cards. Score is now ${_gameModel.cardMatchCount} out of ${GameSettings.numberOfUniqueCards}.';
        SemanticsService.announce(message, TextDirection.ltr);
      }

      if (_gameModel.state == GameState.WON) {
        showGameEnd();
      }
    }
  }

  void showGameEnd() {
    if (_gameModel.state == GameState.WON ||
        _gameModel.state == GameState.LOST) {
      // Temporary UI: Replace with an alert dialog or on-screen message.
      final String message =
          _gameModel.state == GameState.WON ? 'You won!' : 'Game over.';
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
    }
  }
}

class ScoreDisplayView extends StatelessWidget {
  const ScoreDisplayView({
    Key key,
    @required GameModel gameModel,
  })  : _gameModel = gameModel,
        super(key: key);

  final GameModel _gameModel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Matched ${_gameModel.cardMatchCount} of ${GameSettings.numberOfUniqueCards} pairs',
        style: TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }
}
