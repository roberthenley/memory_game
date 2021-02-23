import 'package:flutter/material.dart';

import 'game_board_view.dart';

/// Game page widget.
///
/// Stateless. Provides scaffolding for the game board view widget.
class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memory')),
      body: SafeArea(
        child: GameBoardView(),
      ),
    );
  }
}
