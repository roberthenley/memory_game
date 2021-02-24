import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:memory_game/models/card_faces.dart';

import 'card_view.dart';
import 'game_logic/game_state_machine.dart';
import 'models/card_model.dart';
import 'models/game_model.dart';
import 'models/game_state.dart';

/// Game board view widget.
///
/// Stateful. Displays the game score, game timer, and a grid of CardView
/// widgets. Handles all user actions and game timers.
///
/// The grid layout dimensions respond to portrait and landscape mode.
///
/// Delegates the game score and timer displays to ScoreDisplayView and
/// TimerDisplayView (below). Passes _onCardSelected to each CardView.
///
/// Disables the overall game timer and suppresses the timer display if
/// accessibleNavigation is active.
class GameBoardView extends StatefulWidget {
  GameModel initialGameModel;

  GameBoardView({this.initialGameModel}) {
    if (initialGameModel == null) {
      initialGameModel = GameModel.newGame();
    }
  }

  @override
  _GameBoardViewState createState() => _GameBoardViewState();
}

class _GameBoardViewState extends State<GameBoardView> {
  GameModel _gameModel;
  Timer _timer;
  bool _gameStarted = false;
  int _timeRemaining;

  @override
  void initState() {
    super.initState();
    _gameModel = widget.initialGameModel;
    _timeRemaining = _gameModel.gameDurationSeconds;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // Announce game board layout for accessibility.
    if (MediaQuery.of(context).accessibleNavigation) {
      await _announceGameLayout(_gameModel.cards);
    }

    // Announce initial card layout for accessibility.
    // Wait, then display cards face-down and start the game.
    // Do this only once!
    if (!_gameStarted) {
      if (MediaQuery.of(context).accessibleNavigation) {
        await _announceCardLayout(_gameModel.cards);
      }

      Future.delayed(Duration(seconds: _gameModel.initialFaceUpSeconds), () {
        setState(
          () {
            _gameModel = GameStateMachine.setNextState(
              model: _gameModel,
              newState: GameState.noCardsSelected,
            );
            _gameStarted = true;
          },
        );

        // Do not use a game timer if accessible navigation, like a screen
        // reader, is in use.
        if (!MediaQuery.of(context).accessibleNavigation) {
          _startGameTimer();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        ScoreDisplayView(gameModel: _gameModel),
        if (!MediaQuery.of(context).accessibleNavigation)
          TimerDisplayView(timeRemaining: _timeRemaining),
        Expanded(
          child: GridView.count(
            crossAxisCount: _responsiveBoardWidth(),
            padding: EdgeInsets.all(8.0),
            children: List.generate(
              _gameModel.numberOfCards,
              (index) {
                return CardView(
                  cardModel: _gameModel.cards[index],
                  selectionCallback: _onCardSelected,
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

  /// Returns the displayed game board width, depending on screen orientation.
  int _responsiveBoardWidth() {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? _gameModel.layoutWidth
        : _gameModel.layoutHeight;
  }

  /// Returns the displayed game board height, depending on screen orientation.
  int _responsiveBoardHeight() {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? _gameModel.layoutHeight
        : _gameModel.layoutWidth;
  }

  /// Announces the game grid dimensions for accessibility when the app changes
  /// between portrait and landscape mode.
  Future<void> _announceGameLayout(List<CardModel> cards) async {
    if (!MediaQuery.of(context).accessibleNavigation) {
      return;
    }
    // Announce the game grid when it changes.
    String message =
        'A grid of cards with ${_responsiveBoardHeight()} rows and ${_responsiveBoardWidth()} columns.';
    // print('$message');
    await SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Announce the full face-up card layout for accessibility.
  Future<void> _announceCardLayout(List<CardModel> cards) async {
    if (!MediaQuery.of(context).accessibleNavigation) {
      return;
    }
    // Announce the game cards.
    final int boardWidth = _responsiveBoardWidth();
    List<String> messages = [' The game shows the following cards:'];
    messages.addAll(cards.asMap().map((int index, CardModel card) {
      final String rowId = index % boardWidth == 0
          ? ' row ${(index / boardWidth).floor() + 1}:'
          : '';
      return MapEntry(
        index,
        '$rowId ${CardFaces.getCardName(card.cardFaceAssetPath)},',
      );
    }).values);

    String announcement = messages.join('');
    // print('$announcement');
    await SemanticsService.announce(announcement, TextDirection.ltr);
  }

  /// Start the game timer and handle updates as it ticks down and completes.
  ///
  /// From https://stackoverflow.com/questions/54610121/flutter-countdown-timer.
  /// Is not called if accessible navigation is enabled, so don't depend on
  /// _timer ever being set or run.
  void _startGameTimer() {
    _timer = new Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) async {
        // print('time remaining: $_timeRemaining');
        if (_gameModel.state == GameState.wonGame) {
          // If game has been won, stop the timer.
          timer.cancel();
        } else if (_timeRemaining == 0) {
          // print('time expired; transitioning to lostGame state');
          setState(() {
            timer.cancel();
            _gameModel = GameStateMachine.setNextState(
              model: _gameModel,
              newState: GameState.lostGame,
            );
          });
          _showGameEnd();
        } else {
          setState(() {
            _timeRemaining--;
          });
        }
      },
    );
  }

  /// Callback for CardView widget when a face-down card is selected.
  ///
  /// Passes the card selected to the game state machine, then updates the
  /// GameBoardView's state and makes accessibility announcements accordingly.
  void _onCardSelected(CardModel card) async {
    if (!card.isSelectable) {
      return;
    }

    setState(() {
      _gameModel = GameStateMachine.nextStateFromCard(
          model: _gameModel, cardSelected: card);
    });

    if (_gameModel.state == GameState.oneCardSelected) {
      final String cardName = CardFaces.getCardName(card.cardFaceAssetPath);
      if (MediaQuery.of(context).accessibleNavigation) {
        final String announcement = 'Selected $cardName.';
        // print('$announcement');
        await SemanticsService.announce(announcement, TextDirection.ltr);
      }
    } else if (_gameModel.state == GameState.twoCardsSelectedNotMatching) {
      // Set delayed action to flip non-matching cards back over.
      Future.delayed(
          Duration(seconds: _gameModel.nonMatchingCardsFaceUpSeconds), () {
        setState(() {
          _gameModel = GameStateMachine.setNextState(
            model: _gameModel,
            newState: GameState.noCardsSelected,
          );
        });
      });

      if (MediaQuery.of(context).accessibleNavigation) {
        final Iterable<CardModel> selectedCards =
            _gameModel.getAllSelectedCards();
        assert(selectedCards.length == 2);
        final String firstCardName =
            CardFaces.getCardName(selectedCards.first.cardFaceAssetPath);
        final String secondCardName =
            CardFaces.getCardName(selectedCards.last.cardFaceAssetPath);
        final String announcement =
            'Selected $firstCardName and $secondCardName which do not match.';
        // print('$announcement');
        await SemanticsService.announce(announcement, TextDirection.ltr);
      }
    } else if (_gameModel.state == GameState.noCardsSelected &&
        MediaQuery.of(context).accessibleNavigation) {
      final String cardName = CardFaces.getCardName(card.cardFaceAssetPath);
      final String message =
          'Matched two $cardName cards. Score is now ${_gameModel.cardMatchCount} out of ${_gameModel.numberOfUniqueCards}.';
      // print('$message');
      await SemanticsService.announce(message, TextDirection.ltr);
    }

    if (_gameModel.state == GameState.wonGame) {
      _showGameEnd();
    }
  }

  /// Show game end notification: win or lose.
  ///
  /// Presently displays a snackbar with the option to return to the HomePage.
  /// Called from game timer (in _startGameTimer()) and _onCardSelected().
  void _showGameEnd() {
    if (_gameModel.state == GameState.wonGame ||
        _gameModel.state == GameState.lostGame) {
      // Temporary UI: Replace with an alert dialog or on-screen message.
      final String message =
          _gameModel.state == GameState.wonGame ? 'You won!' : 'Game over.';
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

class TimerDisplayView extends StatelessWidget {
  const TimerDisplayView({
    Key key,
    @required int timeRemaining,
  })  : _timeRemaining = timeRemaining,
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
        'Matched ${_gameModel.cardMatchCount} of ${_gameModel.numberOfUniqueCards} pairs',
        style: TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }
}
