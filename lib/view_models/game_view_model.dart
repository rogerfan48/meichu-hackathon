import 'package:flutter/foundation.dart';
import '../models/card_model.dart';

class GameCardPair {
  GameCardPair({required this.card, required this.imageSide});
  final StudyCard card;
  final String? imageSide; // could hold an image URL or null if text-only
}

class GameViewModel extends ChangeNotifier {
  GameViewModel();

  List<GameCardPair> _deck = [];
  List<GameCardPair> get deck => _deck;

  bool _inProgress = false;
  bool get inProgress => _inProgress;

  void startGame(List<StudyCard> source) {
    _inProgress = true;
    _deck = source
        .map((c) => GameCardPair(card: c, imageSide: c.imgURL))
        .toList();
    notifyListeners();
  }

  void endGame() {
    _inProgress = false;
    _deck = [];
    notifyListeners();
  }
}
