import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card_model.dart';
import 'firestore_paths.dart';

class CardRepository {
  CardRepository(this._firestore);
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) => _firestore.doc(FirestorePaths.userDoc(uid));

  Stream<List<StudyCard>> watchAllCards(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      final data = snap.data() ?? {};
      final cardsMap = (data['cards'] as Map<String, dynamic>? ?? {});
      return cardsMap.entries
          .map((e) => StudyCard.fromFirestore(Map<String, dynamic>.from(e.value), e.key))
          .toList();
    });
  }

  Future<void> upsertCard(String uid, StudyCard card) async {
    await _userRef(uid).set({
      FirestorePaths.cardField(card.id): {
        'sessionID': card.sessionID,
        'tags': card.tags,
        'imgURL': card.imgURL,
        'text': card.text,
      }
    }, SetOptions(merge: true));
  }

  Future<void> deleteCard(String uid, String cardId, {String? sessionId}) async {
    final updates = <String, dynamic>{
      FirestorePaths.cardField(cardId): FieldValue.delete(),
    };
    if (sessionId != null) {
      updates[FirestorePaths.sessionCardIDs(sessionId)] = FieldValue.arrayRemove([cardId]);
    }
    await _userRef(uid).update(updates);
  }
}
