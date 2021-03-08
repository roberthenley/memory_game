import 'package:flutter/material.dart';

class ScoreDisplayWidget extends StatelessWidget {
  const ScoreDisplayWidget({
    Key? key,
    required int score,
    required int total,
  })   : _score = score,
        _total = total,
        super(key: key);

  final int _score;
  final int _total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Matched $_score of $_total pairs',
        style: TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }
}
