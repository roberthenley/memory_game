import 'package:flutter/material.dart';

import 'game_board_widget.dart';
import 'models/game_model.dart';

/// Game page widget.
///
/// Stateless. Provides scaffolding for the game board view widget.
class GamePage extends StatelessWidget {
  final GameModel initialGameModel;

  GamePage({this.initialGameModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memory')),
      body: SafeArea(
        child: GameBoardWidget(initialGameModel: initialGameModel),
      ),
    );
  }
}
