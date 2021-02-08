# memory_game

The game of Memory, implemented in Flutter

## Basic game TO DO list
- DONE: Create skeleton app from starter project: HomePage and "New game" button
- Create card and game model classes
- Add card image assets
- Create game state machine class skeleton
- Create GamePage widget (stateful, holding game state)
- Implement routing from HomePage to GamePage
- Create Card widget - stateless simple version, no click handling
- Implement initial game state: card generation and display all cards face-up
- Implement timed transition to in-play game state: all cards face-down
- Implement card click handling: transition to 1-card up state
- Implement transition to 2-card up state and display matched-card indicators (if cards match)
- Implement timed transition to unmatched cards face-down state
- Implement transition to "won" state
- Implement game timer and transition to "lost" state display, then route back to HomePage
- Implement game timer display
- Game state machine unit tests
- Card widget widget tests
- Flutter driver tests

## Potential refactorings / design decisions TBD
- Make game state machine a BLoC?
- Adopt Provider to distribute state?
- Make Card widget stateful?
- Performance: will rebuilds on card model state transition that don't effect visibility cost too much?

## Additional features 
- Adjustable play difficulty (by adjusting game time and face-up display time)
- Adjustable card layout
- Animate card flipping (consider leveraging flip_card package)
- Internationalization
- Persistent application state
- Accessibility -- to the extent possible; this is a visual game with a timed element

