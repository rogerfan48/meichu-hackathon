import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/card_model.dart';
import '../models/session_model.dart';
import '../repositories/card_repository.dart';
import '../repositories/session_repository.dart';

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
  
  List<StudyCard> _gameDeck = [];
  int _currentGameCardIndex = 0;
  StudyCard? get currentGameCard => _gameDeck.isNotEmpty && _currentGameCardIndex < _gameDeck.length ? _gameDeck[_currentGameCardIndex] : null;

  int _dueCardCount = 0;
  int get dueCardCount => _dueCardCount;
  
  int get currentGameCardIndex => _currentGameCardIndex;
  int get totalGameCards => _gameDeck.length;

  CardsPageViewModel({required this.cardRepository, required this.sessionRepository, required this.userId}) {
    _listenToData();
  }

  Duration _getReviewInterval(int masteryLevel) {
    if (masteryLevel <= 1) return const Duration(minutes: 5); 
    final days = pow(2.5, masteryLevel - 2).round();
    return Duration(days: days);
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
  
  /// 開始遊戲，不再需要 tag 過濾
  void startGame() {
    List<StudyCard> dueCards = _allCards.where(_isCardDue).toList();

    if (dueCards.isEmpty) return;

    dueCards.shuffle();
    
    _gameDeck = dueCards.take(10).toList(); 

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
      case ReviewOutcome.hard: nextLevel = currentLevel - 1; break;
      case ReviewOutcome.good: nextLevel = currentLevel + 1; break;
      case ReviewOutcome.easy: nextLevel = currentLevel + 3; break;
    }
    
    nextLevel = nextLevel.clamp(1, 5); 
    
    cardRepository.updateCardReviewStatus(userId, card.id, nextLevel);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_gameState != GameState.active) return;

      if (_currentGameCardIndex < _gameDeck.length - 1) {
        _currentGameCardIndex++;
      } else {
        _gameState = GameState.finished;
      }
      notifyListeners();
    });
  }
  
  void endGame() {
    _gameState = GameState.setup;
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

  Future<void> createCard({required String sessionId, required String text}) async {
    final id = cardRepository.newCardId();
    final initialReviewDate = Timestamp.fromDate(DateTime(2000, 1, 1));
    final newCard = StudyCard(
      id: id,
      sessionID: sessionId,
      text: text,
      tags: [], // Tags is now always empty
      lastReviewedAt: initialReviewDate,
      masteryLevel: 0,
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
}