import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_paths.dart';

class UserRepository {
  UserRepository(this._firestore);
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) => _firestore.doc(FirestorePaths.userDoc(uid));

  Future<void> updateDefaultSpeechRate(String uid, double rate) async {
    await _userRef(uid).update({
      'profile.defaultSpeechRate': rate,
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> profileUpdates) async {
    final updates = <String, dynamic>{};
    profileUpdates.forEach((key, value) {
      updates['profile.$key'] = value;
    });
    await _userRef(uid).update(updates);
  }

  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      final data = snap.data() ?? {};
      return data['profile'] as Map<String, dynamic>?;
    });
  }
}