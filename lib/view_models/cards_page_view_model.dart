import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../repositories/card_repository.dart';
import '../repositories/session_repository.dart';
import '../models/card_model.dart';
import '../models/session_model.dart';


enum CardsPageState { loading, idle, error }
enum GameState { setup, active, finished }

enum ReviewOutcome { again, hard, good, easy }

class CardsPageViewModel extends ChangeNotifier {
  final CardRepository cardRepository;
  final SessionRepository sessionRepository;
  final String userId;

  StreamSubscription<List<StudyCard>>? _cardsSubscription;
  StreamSubscription<List<Session>>? _sessionsSubscription;

  CardsPageState _pageState = CardsPageState.loading;
  CardsPageState get pageState => _pageState;

  GameState _gameState = GameState.setup;
  GameState get gameState => _gameState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<StudyCard> _allCards = [];
  List<StudyCard> get allCards => _allCards;

  List<Session> _allSessions = [];
  List<Session> get allSessions => _allSessions;

  Set<String> _availableTags = {};
  Set<String> get availableTags => UnmodifiableSetView(_availableTags);

  Set<String> _selectedTagsForGame = {};
  Set<String> get selectedTagsForGame => UnmodifiableSetView(_selectedTagsForGame);
  
  List<StudyCard> _gameDeck = [];
  int _currentGameCardIndex = 0;
  StudyCard? get currentGameCard => _gameDeck.isNotEmpty && _currentGameCardIndex < _gameDeck.length ? _gameDeck[_currentGameCardIndex] : null;

  int _dueCardCount = 0;
  int get dueCardCount => _dueCardCount;
  
  // ** 關鍵修正：重新加入 getter 以提供遊戲進度 **
  int get currentGameCardIndex => _currentGameCardIndex;
  int get totalGameCards => _gameDeck.length;

  CardsPageViewModel({required this.cardRepository, required this.sessionRepository, required this.userId}) {
    _listenToData();
  }

  Duration _getReviewInterval(int masteryLevel) {
    switch (masteryLevel) {
      case 0: return const Duration(minutes: 1);
      case 1: return const Duration(minutes: 10);
      case 2: return const Duration(days: 1);
      case 3: return const Duration(days: 4);
      case 4: return const Duration(days: 10);
      case 5: return const Duration(days: 30);
      default: return const Duration(days: 60);
    }
  }

  bool _isCardDue(StudyCard card) {
    if (card.lastReviewedAt == null) return true;
    final interval = _getReviewInterval(card.masteryLevel);
    final dueDate = card.lastReviewedAt!.toDate().add(interval);
    return DateTime.now().isAfter(dueDate);
  }

  void _updateDueCardCount() {
    _dueCardCount = _allCards.where(_isCardDue).length;
  }
  
  void _listenToData() {
    _pageState = CardsPageState.loading;
    notifyListeners();

    _cardsSubscription?.cancel();
    _cardsSubscription = cardRepository.watchAllCards(userId).listen(
      (cards) {
        _allCards = cards;
        _updateAvailableTags();
        _updateDueCardCount();
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
  
  void startGame() {
    List<StudyCard> dueCards = _allCards.where(_isCardDue).toList();

    if (_selectedTagsForGame.isNotEmpty) {
      dueCards = dueCards.where((card) {
        return card.tags.any((tag) => _selectedTagsForGame.contains(tag));
      }).toList();
    }

    if (dueCards.isEmpty) return;

    _gameDeck = dueCards..shuffle();
    _currentGameCardIndex = 0;
    _gameState = GameState.active;
    notifyListeners();
  }

  void processAnswer(StudyCard card, ReviewOutcome outcome) {
    if (_gameState != GameState.active) return;

    int currentLevel = card.masteryLevel;
    int nextLevel = currentLevel;

    switch (outcome) {
      case ReviewOutcome.again: nextLevel = 1; break;
      case ReviewOutcome.hard: nextLevel = (currentLevel <= 2) ? currentLevel + 1 : currentLevel; break;
      case ReviewOutcome.good: nextLevel = currentLevel + 1; break;
      case ReviewOutcome.easy: nextLevel = currentLevel + 2; break;
    }
    
    cardRepository.updateCardReviewStatus(userId, card.id, nextLevel);

    if (_currentGameCardIndex < _gameDeck.length - 1) {
      _currentGameCardIndex++;
    } else {
      _gameState = GameState.finished;
    }
    notifyListeners();
  }
  
  void endGame() {
    _gameState = GameState.setup;
    _selectedTagsForGame.clear();
    _gameDeck.clear();
    _updateDueCardCount();
    notifyListeners();
  }

  @override
  void dispose() {
    _cardsSubscription?.cancel();
    _sessionsSubscription?.cancel();
    super.dispose();
  }

  void _handleError(e) {
    _errorMessage = "無法讀取資料: $e";
    _pageState = CardsPageState.error;
    notifyListeners();
  }

  void _checkIfLoadingComplete() {
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
final initialReviewDate = Timestamp.fromDate(DateTime(2000, 1, 1));

    final newCard = StudyCard(
      id: id,
      sessionID: sessionId,
      text: text,
      tags: tags,
      lastReviewedAt: initialReviewDate, // 設定初始複習時間
      masteryLevel: 0, // 初始熟練度為 0
    );
    await cardRepository.upsertCard(userId, newCard);
    await sessionRepository.addCardLink(userId, sessionId, id);
  }

  Future<void> updateCard(StudyCard card) async {
    await cardRepository.upsertCard(userId, card);
  }
  
  Future<void> deleteCard(StudyCard card) async {
    await cardRepository.deleteCard(userId, card.id, sessionId: card.sessionID);
  }

  Future<void> generateImageForCard(StudyCard card) async {
    if (kDebugMode) print("AI 生圖功能尚未實作");
  }
  
  void toggleTagForGame(String tag) {
    if (_selectedTagsForGame.contains(tag)) _selectedTagsForGame.remove(tag);
    else _selectedTagsForGame.add(tag);
    notifyListeners();
  }
}