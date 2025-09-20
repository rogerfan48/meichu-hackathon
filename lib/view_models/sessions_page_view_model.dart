import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/session_repository.dart';
import '../models/session_model.dart';

enum SessionsPageState { loading, idle, error }

class SessionsPageViewModel extends ChangeNotifier {
  final SessionRepository sessionRepository;
  final String userId;
  StreamSubscription<List<Session>>? _sub;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;
  
  SessionsPageState _state = SessionsPageState.loading;
  SessionsPageState get state => _state;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SessionsPageViewModel({required this.sessionRepository, required this.userId}) {
    _listenToSessions();
  }

  void _listenToSessions() {
    _state = SessionsPageState.loading;
    notifyListeners();
    
    _sub?.cancel();
    _sub = sessionRepository.watchAllSessions(userId).listen(
      (sessions) {
        _sessions = sessions; // The query is already ordered
        _state = SessionsPageState.idle;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = "無法讀取 Sessions: $e";
        _state = SessionsPageState.error;
        notifyListeners();
      }
    );
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await sessionRepository.deleteSession(userId, sessionId);
    } catch (e) {
      if (kDebugMode) {
        print("刪除 Session 失敗: $e");
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}