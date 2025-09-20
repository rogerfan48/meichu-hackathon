import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import 'firestore_paths.dart';

class SessionRepository {
  SessionRepository(this._firestore);
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) => _firestore.doc(FirestorePaths.userDoc(uid));

  Stream<Session> watchSession(String uid, String sessionId) {
    return _userRef(uid).snapshots().map((snap) {
      final data = snap.data() ?? {};
      final sessions = (data['sessions'] as Map<String, dynamic>? ?? {});
      final sessionJson = sessions[sessionId] as Map<String, dynamic>? ?? {};
      return Session.fromFirestore(sessionJson, sessionId);
    });
  }

  Future<void> upsertSession(String uid, Session session) async {
    await _userRef(uid).set({
      FirestorePaths.sessionField(session.id): {
        'sessionName': session.sessionName,
        'fileResources': session.fileResources.map((k, v) => MapEntry(k, {
              'fileURL': v.fileURL,
              'fileSummary': v.fileSummary,
            })),
        'summary': session.summary,
        'imgExplanations': session.imgExplanations.map((k, v) => MapEntry(k, {
              'imgURL': v.imgURL,
              'explanation': v.explanation,
            })),
        'cardIDs': session.cardIDs,
        'status': session.status,
      }
    }, SetOptions(merge: true));
  }

  Future<void> appendImageExplanation(String uid, String sessionId, ImgExplanation img) async {
    await _userRef(uid).update({
      '${FirestorePaths.sessionImgExplanations(sessionId)}.${img.id}': {
        'imgURL': img.imgURL,
        'explanation': img.explanation,
      }
    });
  }

  Future<void> addFileResource(String uid, String sessionId, FileResource fr) async {
    await _userRef(uid).update({
      '${FirestorePaths.sessionFileResources(sessionId)}.${fr.id}': {
        'fileURL': fr.fileURL,
        'fileSummary': fr.fileSummary,
      }
    });
  }

  Future<void> addCardLink(String uid, String sessionId, String cardId) async {
    await _userRef(uid).update({
      FirestorePaths.sessionCardIDs(sessionId): FieldValue.arrayUnion([cardId])
    });
  }

  Future<void> updateStatus(String uid, String sessionId, String status) async {
    await _userRef(uid).update({
      '${FirestorePaths.sessionField(sessionId)}.status': status,
    });
  }

  Future<void> updateSummary(String uid, String sessionId, String summary) async {
    await _userRef(uid).update({
      '${FirestorePaths.sessionField(sessionId)}.summary': summary,
    });
  }
}
