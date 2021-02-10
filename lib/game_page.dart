import 'package:flutter/material.dart';

import 'card_view.dart';
import 'game_logic/game_state_machine.dart';
import 'models/game_model.dart';
import 'models/game_settings.dart';
import 'models/game_state.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GameModel _gameModel;

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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memory')),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            ScoreDisplay(gameModel: _gameModel),
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
                    return CardView(cardModel: _gameModel.cards[index]);
                  },
                ),
                shrinkWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({
    Key key,
    @required GameModel gameModel,
  })  : _gameModel = gameModel,
        super(key: key);

  final GameModel _gameModel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Matched ${_gameModel.cardMatchCount} of ${GameSettings.numberOfCards} cards',
        style: TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }
}
