import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import 'firestore_paths.dart';

class SessionRepository {
  SessionRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _sessionsCollection(String uid) =>
      _firestore.collection(FirestorePaths.sessionsCollection(uid));

  Stream<Session?> watchSession(String uid, String sessionId) {
    return _sessionsCollection(uid).doc(sessionId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Session.fromFirestore(snap.data()!, snap.id);
    });
  }

  Stream<List<Session>> watchAllSessions(String uid) {
    return _sessionsCollection(uid).snapshots().map((snapshot) {
      var sessions = snapshot.docs
          .map((doc) => Session.fromFirestore(doc.data(), doc.id))
          .toList();
      // 在客戶端進行排序，以 createdAt 欄位為準，如果為 null 則使用 id
      sessions.sort((a, b) {
        final dateA = a.createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(int.tryParse(a.id) ?? 0);
        final dateB = b.createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(int.tryParse(b.id) ?? 0);
        return dateB.compareTo(dateA);
      });
      return sessions;
    });
  }

  Future<void> upsertSession(String uid, Session session) async {
    await _sessionsCollection(uid).doc(session.id).set(session.toJson());
  }
  
  Future<void> deleteSession(String uid, String sessionId) async {
    await _sessionsCollection(uid).doc(sessionId).delete();
  }

  Future<void> addFileResource(String uid, String sessionId, FileResource fr) async {
    await _sessionsCollection(uid).doc(sessionId).update({
      'fileResources.${fr.id}': fr.toJson(),
    });
  }

  Future<void> addCardLink(String uid, String sessionId, String cardId) async {
    await _sessionsCollection(uid).doc(sessionId).update({
      'cardIDs': FieldValue.arrayUnion([cardId])
    });
  }

  Future<void> updateStatus(String uid, String sessionId, String status) async {
    await _sessionsCollection(uid).doc(sessionId).update({'status': status});
  }

  Future<void> updateSummary(String uid, String sessionId, String summary) async {
    await _sessionsCollection(uid).doc(sessionId).update({'summary': summary});
  }
}