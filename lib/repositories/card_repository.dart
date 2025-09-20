import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card_model.dart';
import 'firestore_paths.dart';

class CardRepository {
  CardRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _cardsCollection(String uid) =>
      _firestore.collection(FirestorePaths.cardsCollection(uid));

  String newCardId() => _firestore.collection('_').doc().id;

  Stream<List<StudyCard>> watchAllCards(String uid) {
    return _cardsCollection(uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StudyCard.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<StudyCard>> watchCardsForSession(String uid, String sessionId) {
    return _cardsCollection(uid)
        .where('sessionID', isEqualTo: sessionId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StudyCard.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> upsertCard(String uid, StudyCard card) async {
    await _cardsCollection(uid).doc(card.id).set(card.toJson());
  }

  Future<void> updateCardReviewStatus(String uid, String cardId, int newMasteryLevel) async {
    await _firestore.doc(FirestorePaths.cardDoc(uid, cardId)).update({
      'masteryLevel': newMasteryLevel,
      'lastReviewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCard(String uid, String cardId, {required String sessionId}) async {
    final cardRef = _firestore.doc(FirestorePaths.cardDoc(uid, cardId));
    final sessionRef = _firestore.doc(FirestorePaths.sessionDoc(uid, sessionId));

    await _firestore.runTransaction((transaction) async {
      transaction.delete(cardRef);
      transaction.update(sessionRef, {
        'cardIDs': FieldValue.arrayRemove([cardId])
      });
    });
  }
}