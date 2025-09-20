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

// 更新後的回答結果枚舉
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
  
  int get currentGameCardIndex => _currentGameCardIndex;
  int get totalGameCards => _gameDeck.length;

  CardsPageViewModel({required this.cardRepository, required this.sessionRepository, required this.userId}) {
    _listenToData();
  }

  // --- 核心修改：新的 SRS 演算法 ---

  /// 根據熟練度等級獲取下一次複習的間隔時間 (更符合 SRS 的指數增長模型)
  Duration _getReviewInterval(int masteryLevel) {
    if (masteryLevel <= 1) return const Duration(minutes: 5); 
    final days = pow(2.5, masteryLevel - 2).round();
    return Duration(days: days);
  }

  /// 判斷一張卡片是否到期需要複習
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
  
  /// 開始遊戲，包含最多10張卡片的邏輯
  void startGame() {
    List<StudyCard> dueCards = _allCards.where(_isCardDue).toList();

    if (_selectedTagsForGame.isNotEmpty) {
      dueCards = dueCards.where((card) {
        return card.tags.any((tag) => _selectedTagsForGame.contains(tag));
      }).toList();
    }

    if (dueCards.isEmpty) return;

    dueCards.shuffle();
    
    // ** 關鍵修改：最多隻取10張卡片進行練習 **
    _gameDeck = dueCards.take(10).toList(); 

    _currentGameCardIndex = 0;
    _gameState = GameState.active;
    notifyListeners();
  }

  /// 處理用戶的回答，更新卡片熟練度，並確保等級在 1-5 之間
  void processAnswer(StudyCard card, ReviewOutcome outcome) {
    if (_gameState != GameState.active) return;

    int currentLevel = card.masteryLevel;
    int nextLevel = currentLevel;

    // ** 關鍵修改：新的熟練度計算規則 **
    switch (outcome) {
      case ReviewOutcome.again: // 忘記
        nextLevel = 1;
        break;
      case ReviewOutcome.hard: // 困難
        nextLevel = currentLevel - 1;
        break;
      case ReviewOutcome.good: // 普通
        nextLevel = currentLevel + 1;
        break;
      case ReviewOutcome.easy: // 熟悉
        nextLevel = currentLevel + 3;
        break;
    }
    
    // ** 關鍵修改：確保熟練度等級被限制在 1 到 5 之間 **
    // (新卡片等級為0，一旦被複習，最低也會變成1)
    nextLevel = nextLevel.clamp(1, 5); 
    
    cardRepository.updateCardReviewStatus(userId, card.id, nextLevel);

    // 延遲一小段時間再翻到下一張卡，讓用戶有時間看到回饋
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_gameState != GameState.active) return; // 避免在 dispose 後還執行

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
  
  void toggleTagForGame(String tag) {
    if (_selectedTagsForGame.contains(tag)) _selectedTagsForGame.remove(tag);
    else _selectedTagsForGame.add(tag);
    notifyListeners();
  }
}