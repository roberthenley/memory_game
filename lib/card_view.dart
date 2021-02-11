import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'models/card_assets.dart';
import 'models/card_model.dart';

class CardView extends StatelessWidget {
  const CardView({
    Key key,
    @required this.cardModel,
    @required this.callback,
  }) : super(key: key);

  final CardModel cardModel;
  final Function callback;

  // Card back image path is 'assets/svg/question-mark-round-line.svg'
  static final SvgPicture faceDownCard = SvgPicture.asset(
    'assets/svg/question-mark-round-line.svg',
    semanticsLabel: 'Card Back',
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                  semanticsLabel: CardAssets.getCardName(
                    cardModel.cardFaceAssetPath,
                  ),
                )
              : faceDownCard,
        ),
      ),
      onTap: () {
        if (cardModel.isSelectable) {
          callback(cardModel);
        }
      },
    );
  }
}
