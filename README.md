# memory_game

The game of Memory, implemented in Flutter

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
- Accessibility test/fix: keyboard access
- Game state machine unit tests
- Widget tests for CardView widget, ScoreDisplayView, and GameBoardView
- Flutter driver tests

## Potential refactorings / design decisions TBD
- Make game state machine a BLoC?
- Adopt Provider to distribute state?
- Make Card widget stateful?
- Use bdd_widget_tests package for widget testing in Gherkin?
- Performance: will rebuilds on card model state transition that don't effect visibility cost too much?

## Additional features TBD
- Fix GamePage and CardView so they scale properly to the display without scrolling
- Adjustable play difficulty (by adjusting game time and face-up display time)
- Adjustable card layout / card count
- Golden tests?
- Animate card flipping (consider leveraging flip_card package)
- Internationalization
- Persistent application state
- Transition to Null Safety

