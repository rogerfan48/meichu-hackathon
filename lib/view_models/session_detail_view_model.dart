import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/card_model.dart';
import '../models/session_model.dart';
import '../repositories/card_repository.dart';
import '../repositories/session_repository.dart';

enum SessionDetailPageState { loading, idle, error }

class SessionDetailViewModel extends ChangeNotifier {
  final String userId;
  final String sessionId;
  final SessionRepository sessionRepository;
  final CardRepository cardRepository;

  StreamSubscription? _sessionSub;
  StreamSubscription? _cardsSub;

  SessionDetailPageState _state = SessionDetailPageState.loading;
  SessionDetailPageState get state => _state;

  Session? _session;
  Session? get session => _session;

  List<StudyCard> _cards = [];
  List<StudyCard> get cards => _cards;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SessionDetailViewModel({
    required this.userId,
    required this.sessionId,
    required this.sessionRepository,
    required this.cardRepository,
  }) {
    _listenToData();
  }

  void _listenToData() {
    _state = SessionDetailPageState.loading;
    notifyListeners();

    _sessionSub?.cancel();
    _sessionSub = sessionRepository.watchSession(userId, sessionId).listen((sessionData) {
      _session = sessionData;
      if (_state == SessionDetailPageState.loading && _cards.isNotEmpty) {
        _state = SessionDetailPageState.idle;
      }
      notifyListeners();
    }, onError: _handleError);

    _cardsSub?.cancel();
    _cardsSub = cardRepository.watchCardsForSession(userId, sessionId).listen((cardData) {
      _cards = cardData;
      if (_state == SessionDetailPageState.loading && _session != null) {
        _state = SessionDetailPageState.idle;
      }
      notifyListeners();
    }, onError: _handleError);
  }

  void _handleError(e) {
    _errorMessage = "Error loading session details: $e";
    _state = SessionDetailPageState.error;
    notifyListeners();
  }

  // TODO: Add methods for "add file" and "regenerate summary"
  Future<void> addFileToSession() async {
    print("Functionality to add file is not yet implemented.");
  }

  Future<void> regenerateSummary() async {
    print("Functionality to regenerate summary is not yet implemented.");
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _cardsSub?.cancel();
    super.dispose();
  }
}