import 'package:flutter/material.dart';

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
        child: MaterialButton(
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            'New game',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () {
            // Route to GamePage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GamePage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
