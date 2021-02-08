import 'package:flutter/material.dart';

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
            // TODO: Route to GamePage
          },
        ),
      ),
    );
  }
}
