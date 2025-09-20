import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card_model.dart';
import 'firestore_paths.dart';

class CardRepository {
  CardRepository(this._firestore);
  final FirebaseFirestore _firestore;

  // Helper to get a reference to the 'cards' collection for a user
  CollectionReference<Map<String, dynamic>> _cardsCollection(String uid) =>
      _firestore.collection(FirestorePaths.cardsCollection(uid));

  // Generate a new card ID client-side.
  String newCardId() => _firestore.collection('_').doc().id;

  // Watch the entire 'cards' subcollection for a user
  Stream<List<StudyCard>> watchAllCards(String uid) {
    return _cardsCollection(uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StudyCard.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Watch cards belonging to a specific session using a Firestore query
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

  // Create or update a card document in the subcollection
  Future<void> upsertCard(String uid, StudyCard card) async {
    await _cardsCollection(uid).doc(card.id).set(card.toJson());
  }

  // Increment feedback counts on a specific card document
  Future<void> incrementFeedback(String uid, String cardId, {int goodDelta = 0, int badDelta = 0}) async {
    final updates = <String, dynamic>{};
    if (goodDelta != 0) {
      updates['goodCount'] = FieldValue.increment(goodDelta);
    }
    if (badDelta != 0) {
      updates['badCount'] = FieldValue.increment(badDelta);
    }
    if (updates.isNotEmpty) {
      await _firestore.doc(FirestorePaths.cardDoc(uid, cardId)).update(updates);
    }
  }

  // Delete a card document from the subcollection
  Future<void> deleteCard(String uid, String cardId, {required String sessionId}) async {
    // We also need to remove the cardId from the session's cardIDs array.
    // This is a transaction to ensure both operations succeed or fail together.
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