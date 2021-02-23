import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'models/card_faces.dart';
import 'models/card_model.dart';

/// Card view widget.
///
/// Stateless. Takes a CardModel and a callback for card selection handling.
/// Encodes the card back picture at the class level so it is reused.
class CardView extends StatelessWidget {
  const CardView({
    Key key,
    @required this.cardModel,
    @required this.selectionCallback,
  }) : super(key: key);

  final CardModel cardModel;
  final Function selectionCallback;

  // Card back image path is 'assets/svg/question-mark-round-line.svg'
  static final SvgPicture faceDownCard = SvgPicture.asset(
    'assets/svg/question-mark-round-line.svg',
  );

  @override
  Widget build(BuildContext context) {
    String cardName = CardFaces.getCardName(cardModel.cardFaceAssetPath) +
        (cardModel.isMatched ? ' matched' : '');
    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      label: cardModel.isFaceUp ? cardName : 'Card Back',
      child: InkWell(
        child: Card(
          margin: EdgeInsets.all(8.0),
          shape: cardModel.isMatched
              ? RoundedRectangleBorder(
                  side: new BorderSide(color: Colors.blue, width: 4.0),
                  borderRadius: BorderRadius.circular(4.0),
                )
              : new RoundedRectangleBorder(
                  side: new BorderSide(color: Colors.white, width: 4.0),
                  borderRadius: BorderRadius.circular(4.0),
                ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: cardModel.isFaceUp
                ? SvgPicture.asset(
                    cardModel.cardFaceAssetPath,
                  )
                : faceDownCard,
          ),
        ),
        onTap: () {
          if (cardModel.isSelectable) {
            selectionCallback(cardModel);
          }
        },
      ),
    );
  }
}
