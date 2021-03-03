import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/game_model.dart';
import '../../orchestration/game_cubit.dart';
import '../../orchestration/game_state.dart';
import '../widgets/stateless_game_board_widget.dart';

/// Game page widget.
///
/// Stateless. Provides scaffolding for the game board view widget.
class GamePage extends StatelessWidget {
  final GameModel initialGameModel;

  GamePage({this.initialGameModel});

  @override
  Widget build(BuildContext context) {
    bool timedGame = !MediaQuery.of(context).accessibleNavigation;
    return BlocProvider<GameCubit>(
      create: (_) => GameCubit(
        initialGameModel: initialGameModel,
        timedGame: timedGame,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('Memory')),
        body: SafeArea(
          // child: BlocBuilder<GameCubit, GameState>(
          child: BlocConsumer<GameCubit, GameState>(
            listener: (listenerContext, state) {
              _announce(state.gameModel.announcement);
            },
            listenWhen: (_, newState) => _hasAnnouncement(newState),
            builder: (builderContext, state) => StatelessGameBoardWidget(
              timedGame: timedGame,
            ),
          ),
        ),
      ),
    );
  }

  /// Determine if the game state has an announcement.
  static bool _hasAnnouncement(GameState state) {
    bool hasAnnouncement = state.gameModel.announcement?.isNotEmpty ?? false;
    // print('GamePage _hasAnnouncement: $hasAnnouncement');
    return hasAnnouncement;
  }

  /// Announce messages for accessibility.
  void _announce(String message) async {
    // if (message?.isNotEmpty ?? false) {
    //   print('GamePage announcing: $message');
    //   await SemanticsService.announce(message, TextDirection.ltr);
    // }
  }
}
