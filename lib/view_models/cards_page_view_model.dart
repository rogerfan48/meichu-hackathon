import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/card_repository.dart';
import '../repositories/session_repository.dart';
import '../models/card_model.dart';
import '../models/session_model.dart'; // Import Session model
import 'dart:collection';

enum CardsPageState { loading, idle, error }
enum GameState { setup, active, finished }

class CardsPageViewModel extends ChangeNotifier {
  final CardRepository cardRepository;
  final SessionRepository sessionRepository;
  final String userId;

  StreamSubscription<List<StudyCard>>? _cardsSubscription;
  StreamSubscription<List<Session>>? _sessionsSubscription; // Add subscription for sessions

  CardsPageState _pageState = CardsPageState.loading;
  CardsPageState get pageState => _pageState;

  GameState _gameState = GameState.setup;
  GameState get gameState => _gameState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<StudyCard> _allCards = [];
  List<StudyCard> get allCards => _allCards;

  List<Session> _allSessions = []; // Add list to hold sessions
  List<Session> get allSessions => _allSessions;

  Set<String> _availableTags = {};
  Set<String> get availableTags => UnmodifiableSetView(_availableTags);

  Set<String> _selectedTagsForGame = {};
  Set<String> get selectedTagsForGame => UnmodifiableSetView(_selectedTagsForGame);
  
  List<StudyCard> _gameDeck = [];
  int _currentGameCardIndex = 0;
  StudyCard? get currentGameCard => _gameDeck.isNotEmpty && _currentGameCardIndex < _gameDeck.length ? _gameDeck[_currentGameCardIndex] : null;

  int _gameScore = 0;
  int get gameScore => _gameScore;
  int get totalGameCards => _gameDeck.length;

  CardsPageViewModel({required this.cardRepository, required this.sessionRepository, required this.userId}) {
    _listenToData();
  }

  void _listenToData() {
    _pageState = CardsPageState.loading;
    notifyListeners();

    _cardsSubscription?.cancel();
    _cardsSubscription = cardRepository.watchAllCards(userId).listen(
      (cards) {
        _allCards = cards;
        _updateAvailableTags();
        _checkIfLoadingComplete();
      },
      onError: _handleError
    );

    _sessionsSubscription?.cancel();
    _sessionsSubscription = sessionRepository.watchAllSessions(userId).listen(
      (sessions) {
        _allSessions = sessions;
        _checkIfLoadingComplete();
      },
      onError: _handleError
    );
  }

  void _handleError(e) {
    _errorMessage = "無法讀取資料: $e";
    _pageState = CardsPageState.error;
    notifyListeners();
  }

  void _checkIfLoadingComplete() {
    // Only transition to idle when both cards and sessions have loaded.
    if (_pageState == CardsPageState.loading) {
      _pageState = CardsPageState.idle;
      notifyListeners();
    }
  }
  
  void _updateAvailableTags() {
    final allTags = <String>{};
    for (var card in _allCards) {
      allTags.addAll(card.tags);
    }
    _availableTags = allTags;
  }

  Future<void> createCard({required String sessionId, required String text, required List<String> tags}) async {
    final id = cardRepository.newCardId();
    final card = StudyCard(id: id, sessionID: sessionId, text: text, tags: tags);
    await cardRepository.upsertCard(userId, card);
    await sessionRepository.addCardLink(userId, sessionId, id);
  }

  Future<void> updateCard(StudyCard card) async {
    await cardRepository.upsertCard(userId, card);
  }
  
  Future<void> deleteCard(StudyCard card) async {
    await cardRepository.deleteCard(userId, card.id, sessionId: card.sessionID);
  }

  // Other methods (startGame, etc.) remain the same...
  Future<void> generateImageForCard(StudyCard card) async {
    if (kDebugMode) print("AI 生圖功能尚未實作");
  }
  
  void toggleTagForGame(String tag) {
    if (_selectedTagsForGame.contains(tag)) _selectedTagsForGame.remove(tag);
    else _selectedTagsForGame.add(tag);
    notifyListeners();
  }

  void startGame() {
    if (_allCards.isEmpty) return;
    if (_selectedTagsForGame.isEmpty) _gameDeck = List.from(_allCards);
    else _gameDeck = _allCards.where((c) => c.tags.any((t) => _selectedTagsForGame.contains(t))).toList();
    if (_gameDeck.isEmpty) return;
    _gameDeck.shuffle();
    _currentGameCardIndex = 0;
    _gameScore = 0;
    _gameState = GameState.active;
    notifyListeners();
  }

  void recordAnswer(StudyCard card, bool wasCorrect) {
    if (_gameState != GameState.active) return;
    if (wasCorrect) {
      _gameScore++;
      cardRepository.incrementFeedback(userId, card.id, goodDelta: 1);
    } else {
      cardRepository.incrementFeedback(userId, card.id, badDelta: 1);
    }
    if (_currentGameCardIndex < _gameDeck.length - 1) _currentGameCardIndex++;
    else _gameState = GameState.finished;
    notifyListeners();
  }
  
  void endGame() {
    _gameState = GameState.setup;
    _selectedTagsForGame.clear();
    _gameDeck.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _cardsSubscription?.cancel();
    _sessionsSubscription?.cancel();
    super.dispose();
  }
}