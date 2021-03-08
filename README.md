# memory_game

The game of Memory, implemented in Flutter.

This is a bare-bones implementation of the game of Memory:
- The home page allows the player to start a new game with 2x2, 2x3, or 3x4 card layouts.
- The game page displays the given card layout.
- There are 20 different card images of which 2, 3, or 6 are randomly selected for each game.
- Two copies of each card are included in the layout in random order.
- The game displays all cards face-up for 5 seconds, then flips the cards face-down and starts a game timer scaled to the number of cards. 
- Selecting a card turns it face-up. 
- Matching pairs of cards are left face-up and highlighted with a border and a point is scored.
- Non-matching pairs of cards are flipped over after two seconds.
- Matching all cards within the time limit wins the game; otherwise, it is lost.

Screen reader support is included. When accessibility navigation is enabled, the game timer is disabled.

The code is able to handle other even-numbered rectangular layouts, up to 20 card pairs, but only 2x2, 2x3, and 3x4 layouts are home page options.

Run the integration tests with: 
```flutter drive --driver=test_driver/integration_test.dart --target=integration_test/memory_2x2_game_test.dart```

## Code structure
- domain/game_logic/game_machine_state.dart - enumerates the allowed game state machine states.
- domain/game_logic/game_state_machine.dart - state machine the controls game play: given the current game model and a player move or timer state change, produces a new game model.
- domain/models/card_faces.dart - contains card face asset paths and helper methods to pick a random selection of them for each game.
- domain/models/card_model.dart - immutably represents the state of a card.
- domain/models/default_game_settings.dart - contains default game values for layout and timer delays.
- domain/models/game_model.dart - immutably represents the state of a game.
- orchestration/game_cubit.dart - a Cubit subclass which orchestrates game interactions.
- orchestration/game_state.dart - the game orchestration state streamed from GameCubit, includes game domain model, timer, etc.
- main.dart - the main() method.
- presentation/memory_app.dart - the application container widget.
- presentation/pages/home_page.dart - the HomePage widget with a button to route to a GamePage for a new game.
- presentation/pages/game_page.dart - the GamePage widget which scaffolds a GameBoardWidget.
- presentation/widgets/game_board_widget.dart - a stateless widget that displays the game board from the GameCubit. Delegates to ScoreDisplayWidget, TimerDisplayWidget, and a GridView of CardWidgets.
- presentation/widgets/card_widget.dart - a stateless widget that displays a CardModel. Calls back to a method in GameBoardWidget to update game state on card selection.
- presentation/widgets/score_display_widget.dart - a stateless widget that displays the matched and total card pairs.
- presentation/widgets/timer_display_widget.dart - a stateless widget that displays the remaining game time.

## Basic game TO DO list
- DONE: Create skeleton app from starter project: HomePage and "New game" button
- DONE: Create card and game model classes
- DONE: Create game state machine class
- DONE: Add card image assets: SVG icons from <a href="https://uxwing.com/">uxwing</a>.
- DONE: Randomize which images are used in each game.
- DONE: Add flutter_svg package.
- DONE: Extract game settings to a single class; use a constant 2x3 game grid for now.
- DONE: Create GamePage widget (stateful, holding game state)
- DONE: Implement routing from HomePage to GamePage
- DONE: Create Card widget - stateless simple version, no click handling
- DONE: Implement initial game state: card generation and display all cards face-up
- DONE: Implement timed transition to in-play game state: all cards face-down
- DONE: Implement card click handling: transition to 1-card up state
- DONE: Implement transition to 2-card up state and set matched-card indicators (if cards match)
- DONE: Display matched card indicator (colored border) on card widgets
- DONE: Implement timed transition to unmatched cards face-down state
- DONE: Implement transition to "wonGame" state 
- DONE: Implement "wonGame" state display and routing back to HomePage
- DONE: Implement game timer, timer display, and "lostGame" state
- DONE: Implement "lostGame" state display and routing back to HomePage
- DONE: Think through game accessibility - non-trivial, since this is a visual game with a timed element
- DONE: Fix card face semantic labels; add state change announcements; disable game timer when screen reader in use
- DONE: Accessibility test/fix: TalkBack
- DONE: Accessibility test/fix: keyboard access
- DONE: Accessibility test/fix: text scale factor
- DONE: Accessibility Scanner testing
- DONE: Game state machine unit tests
- DONE: Refactor GameSettings singleton for testability
- DONE: Adjustable card layout / card count - improve HomePage, so it's not so bare-bones; refactor GamePage and GameBoardWidget for testability
- DONE: Refactor CardFaces singleton for testability (allow access to non-randomized card face list for testing)
- DONE: Widget tests for CardWidget
- DONE: Made GameModel _durationSeconds immutable
- DONE: Widget tests for ScoreDisplayWidget
- DONE: Widget tests for TimerDisplayWidget
- DONE: GameModel unit tests
- DONE: Widget tests for GameBoardWidget
- DONE: Integration tests using new integration_test package
- DONE: Refactor to BLoC pattern (using a Cubit)
- DONE: Add custom app icon
- DONE: Convert to Flutter 2 with null safety

## Additional features TBD
- Improve win/loss notification UI
- Adjustable play difficulty (by adjusting game time and face-up display time)
- Add Golden tests?
- Animate card flipping (consider leveraging the flip_card package)
- Internationalization
- Persistent application state
- Mute the white/black color contrast slightly
- Support Dark Mode
- Use bdd_widget_tests package for widget testing in Gherkin?
- Expand integration tests

## Known issues
- GameBoardWidget doesn't scale properly to the display without scrolling
- GameBoardWidget does not adjust responsively to portrait/landscape mode

