import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import '../repositories/session_repository.dart';

class SessionsViewModel extends ChangeNotifier {
  SessionsViewModel({required this.sessionRepository, required this.userId, required FirebaseFirestore firestore})
      : _firestore = firestore {
    _subscription = _firestore.doc('apps/hackathon/users/$userId').snapshots().listen(_onUserDoc);
  }

  final SessionRepository sessionRepository;
  final String userId;
  final FirebaseFirestore _firestore;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  bool _loading = true;
  bool get loading => _loading;

  void _onUserDoc(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data() ?? {};
    final map = (data['sessions'] as Map<String, dynamic>? ?? {});
    _sessions = map.entries
        .map((e) => Session.fromFirestore(Map<String, dynamic>.from(e.value), e.key))
        .toList()
      ..sort((a, b) => a.sessionName.compareTo(b.sessionName));
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
