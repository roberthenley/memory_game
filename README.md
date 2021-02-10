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
- Create GamePage widget (stateful, holding game state)
- Implement routing from HomePage to GamePage
- Create Card widget - stateless simple version, no click handling
- Implement initial game state: card generation and display all cards face-up
- Implement timed transition to in-play game state: all cards face-down
- Implement card click handling: transition to 1-card up state
- Implement transition to 2-card up state and display matched-card indicators (if cards match)
- Implement timed transition to unmatched cards face-down state
- Implement transition to "won" state 
- Implement "won" state display and routing back to HomePage
- Implement game timer display and "lost" state
- Implement "lost" state display, then route back to HomePage
- Game state machine unit tests
- Card widget widget tests
- Flutter driver tests

## Potential refactorings / design decisions TBD
- Make game state machine a BLoC?
- Adopt Provider to distribute state?
- Make Card widget stateful?
- Use bdd_widget_tests package for widget testing in Gherkin?
- Performance: will rebuilds on card model state transition that don't effect visibility cost too much?

## Additional features 
- Adjustable play difficulty (by adjusting game time and face-up display time)
- Adjustable card layout / card count
- Animate card flipping (consider leveraging flip_card package)
- Internationalization
- Persistent application state
- Transition to Null Safety
- Accessibility -- to the extent possible; this is a visual game with a timed element

