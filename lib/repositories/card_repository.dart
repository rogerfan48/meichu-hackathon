import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card_model.dart';
import 'firestore_paths.dart';

class CardRepository {
  CardRepository(this._firestore);
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) => _firestore.doc(FirestorePaths.userDoc(uid));

  // Generate a new card ID using Firestore's client-side auto ID utility.
  String newCardId() => _firestore.collection('_').doc().id;

  Stream<List<StudyCard>> watchAllCards(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      final data = snap.data() ?? {};
      final cardsMap = (data['cards'] as Map<String, dynamic>? ?? {});
      return cardsMap.entries
          .map((e) => StudyCard.fromFirestore(Map<String, dynamic>.from(e.value), e.key))
          .toList();
    });
  }

  // Watch only cards belonging to a specific session (client-side filter on single doc pattern)
  Stream<List<StudyCard>> watchCardsForSession(String uid, String sessionId) {
    return watchAllCards(uid).map((all) => all.where((c) => c.sessionID == sessionId).toList());
  }

  Future<void> upsertCard(String uid, StudyCard card) async {
    await _userRef(uid).set({
      FirestorePaths.cardField(card.id): {
        'sessionID': card.sessionID,
        'tags': card.tags,
        'imgURL': card.imgURL,
        'text': card.text,
        'goodCount': card.goodCount,
        'badCount': card.badCount,
      }
    }, SetOptions(merge: true));
  }

  // Increment feedback counts for a card
  Future<void> incrementFeedback(String uid, String cardId, {int goodDelta = 0, int badDelta = 0}) async {
    final updates = <String, dynamic>{};
    if (goodDelta != 0) {
      updates['${FirestorePaths.cardField(cardId)}.goodCount'] = FieldValue.increment(goodDelta);
    }
    if (badDelta != 0) {
      updates['${FirestorePaths.cardField(cardId)}.badCount'] = FieldValue.increment(badDelta);
    }
    if (updates.isNotEmpty) {
      await _userRef(uid).update(updates);
    }
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
