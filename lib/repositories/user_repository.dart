import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/card_model.dart';
import '../models/session_model.dart';
import 'firestore_paths.dart';

class UserRepository {
  UserRepository(this._firestore);
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) => 
      _firestore.doc(FirestorePaths.userDoc(uid));

  // Profile management
  Future<void> updateDefaultSpeechRate(String uid, double rate) async {
    await _userRef(uid).update({
      'defaultSpeechRate': rate,
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> profileUpdates) async {
    await _userRef(uid).update(profileUpdates);
  }

  // Watch complete user profile with cards and sessions
  Stream<UserProfile?> watchCompleteUserProfile(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data() ?? {};
      return UserProfile.fromFirestore(data, uid);
    });
  }

  // Watch only user profile data (no cards/sessions)
  Stream<Map<String, dynamic>?> watchUserProfileData(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data() ?? {};
      return {
        'uid': data['uid'],
        'userName': data['userName'],
        'defaultSpeechRate': data['defaultSpeechRate'],
      };
    });
  }

  // Create user profile
  Future<void> createUserProfile(UserProfile profile) async {
    await _userRef(profile.uid).set({
      'uid': profile.uid,
      'userName': profile.userName,
      'defaultSpeechRate': profile.defaultSpeechRate,
      'cards': {}, // Initialize as empty map for nested card structure
      'sessions': {}, // Initialize as empty map for nested session structure
    });
  }

  // User management convenience methods
  Future<StudyCard?> getUserCard(String uid, String cardId) async {
    final snap = await _userRef(uid).get();
    if (!snap.exists) return null;
    
    final data = snap.data() ?? {};
    final cardsMap = data['cards'] as Map<String, dynamic>? ?? {};
    final cardData = cardsMap[cardId] as Map<String, dynamic>?;
    
    if (cardData == null) return null;
    return StudyCard.fromFirestore(cardData, cardId);
  }

  Future<Session?> getUserSession(String uid, String sessionId) async {
    final snap = await _userRef(uid).get();
    if (!snap.exists) return null;
    
    final data = snap.data() ?? {};
    final sessionsMap = data['sessions'] as Map<String, dynamic>? ?? {};
    final sessionData = sessionsMap[sessionId] as Map<String, dynamic>?;
    
    if (sessionData == null) return null;
    return Session.fromFirestore(sessionData, sessionId);
  }

  Future<List<StudyCard>> getAllUserCards(String uid) async {
    final snap = await _userRef(uid).get();
    if (!snap.exists) return [];
    
    final data = snap.data() ?? {};
    final cardsMap = data['cards'] as Map<String, dynamic>? ?? {};
    
    return cardsMap.entries
        .map((entry) => StudyCard.fromFirestore(
            Map<String, dynamic>.from(entry.value), entry.key))
        .toList();
  }

  Future<List<Session>> getAllUserSessions(String uid) async {
    final snap = await _userRef(uid).get();
    if (!snap.exists) return [];
    
    final data = snap.data() ?? {};
    final sessionsMap = data['sessions'] as Map<String, dynamic>? ?? {};
    
    return sessionsMap.entries
        .map((entry) => Session.fromFirestore(
            Map<String, dynamic>.from(entry.value), entry.key))
        .toList();
  }

  // Get user's cards for a specific session
  Future<List<StudyCard>> getUserCardsForSession(String uid, String sessionId) async {
    final cards = await getAllUserCards(uid);
    return cards.where((card) => card.sessionID == sessionId).toList();
  }

  // Check if user exists
  Future<bool> userExists(String uid) async {
    final doc = await _userRef(uid).get();
    return doc.exists;
  }

  // Delete user (for cleanup)
  Future<void> deleteUser(String uid) async {
    await _userRef(uid).delete();
  }
}