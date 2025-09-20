import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/card_repository.dart';
import '../repositories/session_repository.dart';
import '../models/card_model.dart';

class CardsPageViewModel extends ChangeNotifier {
  CardsPageViewModel({required this.cardRepository, required this.sessionRepository, required this.userId});

  final CardRepository cardRepository;
  final SessionRepository sessionRepository;
  final String userId;

  List<StudyCard> _cards = [];
  List<StudyCard> get cards => _cards;
  bool _loading = false;
  bool get loading => _loading;
  StreamSubscription<List<StudyCard>>? _sub;

  void loadAll() {
    _loading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = cardRepository.watchAllCards(userId).listen((list) {
      _cards = list;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> createCard({required String sessionId, required String text, List<String> tags = const []}) async {
    final id = cardRepository.newCardId();
    final card = StudyCard(id: id, sessionID: sessionId, text: text, tags: tags);
    await cardRepository.upsertCard(userId, card);
    await sessionRepository.addCardLink(userId, sessionId, id);
  }

  Future<void> updateCard(StudyCard card) async => cardRepository.upsertCard(userId, card);
  
  Future<void> deleteCard(StudyCard card) async => cardRepository.deleteCard(userId, card.id);

  /// Increment good count for a card
  Future<void> incrementGood(StudyCard card) async {
    await cardRepository.incrementFeedback(userId, card.id, goodDelta: 1);
  }

  /// Increment bad count for a card
  Future<void> incrementBad(StudyCard card) async {
    await cardRepository.incrementFeedback(userId, card.id, badDelta: 1);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
