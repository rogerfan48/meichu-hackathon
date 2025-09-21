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
  StreamSubscription? _fileResourcesSub;
  StreamSubscription? _imgExplanationsSub;

  SessionDetailPageState _state = SessionDetailPageState.loading;
  SessionDetailPageState get state => _state;

  Session? _session;
  Session? get session {
    if (_session == null) return null;
    // 返回包含載入的 fileResources 和 imgExplanations 的 session
    return _session!.copyWith(
      fileResources: _fileResources,
      imgExplanations: _imgExplanations,
    );
  }

  List<StudyCard> _cards = [];
  List<StudyCard> get cards => _cards;

  Map<String, FileResource> _fileResources = {};
  Map<String, ImgExplanation> _imgExplanations = {};

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
      _checkIfDataLoaded();
    }, onError: _handleError);

    _cardsSub?.cancel();
    _cardsSub = cardRepository.watchCardsForSession(userId, sessionId).listen((cardData) {
      _cards = cardData;
      _checkIfDataLoaded();
    }, onError: _handleError);

    _fileResourcesSub?.cancel();
    _fileResourcesSub = sessionRepository.watchFileResources(userId, sessionId).listen((fileResources) {
      _fileResources = {for (var fr in fileResources) fr.id: fr};
      _checkIfDataLoaded();
    }, onError: _handleError);

    _imgExplanationsSub?.cancel();
    _imgExplanationsSub = sessionRepository.watchImgExplanations(userId, sessionId).listen((imgExplanations) {
      _imgExplanations = {for (var img in imgExplanations) img.id: img};
      _checkIfDataLoaded();
    }, onError: _handleError);
  }

  void _checkIfDataLoaded() {
    if (_state == SessionDetailPageState.loading && _session != null) {
      _state = SessionDetailPageState.idle;
    }
    notifyListeners();
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
    _fileResourcesSub?.cancel();
    _imgExplanationsSub?.cancel();
    super.dispose();
  }
}