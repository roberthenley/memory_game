import 'package:flutter/material.dart';

import '../../domain/models/game_model.dart';
import 'game_page.dart';

/// Home page widget.
///
/// Stateless. Allows you to start a new game.
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NewGameButton(width: 2, height: 2),
            NewGameButton(width: 2, height: 3),
            NewGameButton(width: 3, height: 4),
          ],
        ),
      ),
    );
  }
}

class NewGameButton extends StatelessWidget {
  const NewGameButton({
    Key key,
    @required this.width,
    @required this.height,
  }) : super(key: key);

  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 18),
      child: MaterialButton(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Text(
          'New game ($width x $height)',
          semanticsLabel: 'New game - $width wide by $height high',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {
          // Route to GamePage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GamePage(
                initialGameModel: GameModel.newGame(
                  layoutWidth: width,
                  layoutHeight: height,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
