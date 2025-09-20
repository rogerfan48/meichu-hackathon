import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/session_repository.dart';
import '../models/session_model.dart';

class SessionsPageViewModel extends ChangeNotifier {
  SessionsPageViewModel({required this.sessionRepository, required this.userId, required FirebaseFirestore firestore})
      : _firestore = firestore {
    _sub = _firestore.doc('apps/hackathon/users/$userId').snapshots().listen(_onDoc);
  }

  final SessionRepository sessionRepository;
  final String userId;
  final FirebaseFirestore _firestore;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;
  bool _loading = true;
  bool get loading => _loading;

  void _onDoc(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data() ?? {};
    final raw = (data['sessions'] as Map<String, dynamic>? ?? {});
    _sessions = raw.entries
        .map((e) => Session.fromFirestore(Map<String, dynamic>.from(e.value), e.key))
        .toList()
      ..sort((a, b) => b.id.compareTo(a.id));
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    // Remove session map entry (Firestore supports field deletion via FieldValue.delete()).
    // For simplicity we fetch current doc, modify, and write back (since repository lacks direct delete helper).
    final docRef = FirebaseFirestore.instance.doc('apps/hackathon/users/$userId');
    final snap = await docRef.get();
    final data = snap.data() ?? {};
    final sessions = Map<String, dynamic>.from(data['sessions'] as Map<String, dynamic>? ?? {});
    sessions.remove(sessionId);
    await docRef.update({'sessions': sessions});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
