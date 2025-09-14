import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie/models/review_model.dart';

enum VoteType { agree, disagree }

class ReviewRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _reviewCollection;
  final timeout = const Duration(seconds: 10);

  ReviewRepository()
    : _reviewCollection = FirebaseFirestore.instance.collection('apps/foodie/reviews');

  Stream<Map<String, ReviewModel>> streamReviewMap() {
    return _db.collection('apps/foodie/reviews').snapshots().map((snapshot) {
      return Map.fromEntries(
        snapshot.docs.map(
          (doc) =>
              MapEntry(doc.id, ReviewModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)),
        ),
      );
    });
  }

  Future<void> toggleVote({
    required String reviewId,
    required String userId,
    required VoteType voteType,
    required bool isCurrentlyVoted,
  }) {
    String fieldToUpdate = voteType == VoteType.agree ? 'agreedBy' : 'disagreedBy';

    if (isCurrentlyVoted) {
      return _reviewCollection.doc(reviewId).update({
        fieldToUpdate: FieldValue.arrayRemove([userId]),
      });
    } else {
      String fieldToRemoveFrom = voteType == VoteType.agree ? 'disagreedBy' : 'agreedBy';

      return _reviewCollection.doc(reviewId).update({
        fieldToUpdate: FieldValue.arrayUnion([userId]),
        fieldToRemoveFrom: FieldValue.arrayRemove([userId]),
      });
    }
  }

  Future<DocumentReference> addReview(ReviewModel review) {
    return _reviewCollection.add(review.toMap());
  }

  Future<void> deleteReview(String reviewId) {
    return _reviewCollection.doc(reviewId).delete();
  }

  Future<void> updateReviewContent({required String reviewId, required String newContent}) {
    return _reviewCollection.doc(reviewId).update({'content': newContent});
  }

  Future<void> removeImageUrl({required String reviewId, required String imageUrl}) {
    return _reviewCollection.doc(reviewId).update({
      'reviewImgURLs': FieldValue.arrayRemove([imageUrl]),
    });
  }
}
