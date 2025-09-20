import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_paths.dart';

class UserRepository {
  UserRepository(this._firestore);
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firestore.doc(FirestorePaths.userDoc(uid));

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromFirestore(snap.data()!, uid);
    });
  }

  Future<void> createUser(User user) async {
    final userProfile = UserProfile(
      uid: user.uid,
      userName: user.displayName ?? 'New User',
      photoURL: user.photoURL,
    );
    await _userRef(user.uid).set(userProfile.toJson());
  }

  Future<void> updateUserProfileFromAuth(String uid, String userName, String? photoURL) async {
    await _userRef(uid).update({
      'userName': userName,
      if (photoURL != null) 'photoURL': photoURL,
    });
  }
  
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) async {
    return await _userRef(uid).get();
  }

  Future<void> updateDefaultSpeechRate(String uid, double rate) async {
    await _userRef(uid).update({'defaultSpeechRate': rate});
  }
}