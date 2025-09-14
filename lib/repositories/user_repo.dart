import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:foodie/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _userCollection;
  final timeout = const Duration(seconds: 10);

  UserRepository() : _userCollection = FirebaseFirestore.instance.collection('apps/foodie/users');

  Future<DocumentSnapshot> getUser(String uid) {
    return _userCollection.doc(uid).get();
  }

  Future<void> createUser(auth.User user) {
    final newAppUser = UserModel(
      userName: user.displayName ?? 'Foodie User',
      photoURL: user.photoURL,
      viewedRestaurantIDs: {},
      userReviewIDs: [],
    );

    return _userCollection.doc(user.uid).set({
      'userName': newAppUser.userName,
      'photoURL': newAppUser.photoURL,
      'viewedRestaurantIDs': newAppUser.viewedRestaurantIDs,
      'userReviewIDs': newAppUser.userReviewIDs,
    });
  }

  Future<void> updateUserProfile(String uid, String displayName, String? photoURL) {
    return _userCollection.doc(uid).update({
      'userName': displayName,
      'photoURL': photoURL,
    });
  }

  Future<void> updateUserViewedRestaurants(
    String uid,
    Map<String, List<String>> viewedRestaurantIDs,
  ) {
    return _userCollection
      .doc(uid)
      .update({'viewedRestaurantIDs': viewedRestaurantIDs});
  }

  Stream<Map<String, UserModel>> streamUserMap() {
    return _userCollection
      .snapshots()
      .map((snapshot) {
        return Map.fromEntries(
          snapshot.docs.map((doc) => MapEntry(
            doc.id,
            UserModel.fromMap(doc.data() as Map<String, dynamic>),
          )),
        );
      });
  }
}
