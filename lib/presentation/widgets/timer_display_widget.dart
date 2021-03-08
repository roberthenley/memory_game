import 'package:flutter/material.dart';

class TimerDisplayWidget extends StatelessWidget {
  const TimerDisplayWidget({
    Key? key,
    required int timeRemaining,
  })   : _timeRemaining = timeRemaining,
        super(key: key);

  final int _timeRemaining;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4),
        Center(
          child: Text(
            '$_timeRemaining seconds',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
