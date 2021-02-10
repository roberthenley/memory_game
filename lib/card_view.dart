import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'models/card_assets.dart';
import 'models/card_model.dart';

class CardView extends StatelessWidget {
  const CardView({
    Key key,
    @required this.cardModel,
  }) : super(key: key);

  final CardModel cardModel;

  // Card back image path is 'assets/svg/question-mark-round-line.svg'
  static final SvgPicture faceDownCard = SvgPicture.asset(
    'assets/svg/question-mark-round-line.svg',
    semanticsLabel: 'Card Back',
  );

  @override
  Widget build(BuildContext context) {
    // TODO: Bordering for isMatched state.
    // TODO: onClick handling; will need a callback function from GamePage.
    return Card(
      margin: EdgeInsets.all(8.0),
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
    );
  }
}
