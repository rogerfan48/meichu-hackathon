import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import 'firestore_paths.dart';

class SessionRepository {
  SessionRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _sessionsCollection(String uid) =>
      _firestore.collection(FirestorePaths.sessionsCollection(uid));

  CollectionReference<Map<String, dynamic>> _fileResourcesCollection(String uid, String sessionId) =>
      _firestore.collection(FirestorePaths.fileResourcesCollection(uid, sessionId));

  CollectionReference<Map<String, dynamic>> _imgExplanationsCollection(String uid, String sessionId) =>
      _firestore.collection(FirestorePaths.imgExplanationsCollection(uid, sessionId));

  Stream<Session?> watchSession(String uid, String sessionId) {
    return _sessionsCollection(uid).doc(sessionId).snapshots().map((snap) {
      if (!snap.exists) return null;
      // 注意：fileResources 和 imgExplanations 現在是空的，因為它們是 subcollections
      // 如果需要這些資料，應該使用 watchFileResources 和 watchImgExplanations
      return Session.fromFirestore(snap.data()!, snap.id);
    });
  }

  Stream<List<Session>> watchAllSessions(String uid) {
    return _sessionsCollection(uid).snapshots().map((snapshot) {
      var sessions = snapshot.docs
          .map((doc) => Session.fromFirestore(doc.data(), doc.id))
          .toList();
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

  Future<void> updateSessionName(String uid, String sessionId, String newName) async {
    await _sessionsCollection(uid).doc(sessionId).update({'sessionName': newName});
  }

  Future<void> addFileResource(String uid, String sessionId, FileResource fr) async {
    await _fileResourcesCollection(uid, sessionId).doc(fr.id).set(fr.toJson());
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

  // 獲取 fileResources subcollection
  Stream<List<FileResource>> watchFileResources(String uid, String sessionId) {
    return _fileResourcesCollection(uid, sessionId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FileResource.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // 獲取 imgExplanations subcollection  
  Stream<List<ImgExplanation>> watchImgExplanations(String uid, String sessionId) {
    return _imgExplanationsCollection(uid, sessionId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ImgExplanation.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // 添加 imgExplanation 到 subcollection
  Future<void> addImgExplanation(String uid, String sessionId, ImgExplanation imgExplanation) async {
    await _imgExplanationsCollection(uid, sessionId).doc(imgExplanation.id).set(imgExplanation.toJson());
  }
}