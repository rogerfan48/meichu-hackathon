class FirestorePaths {
  // Path to the user document
  static String userDoc(String uid) => 'apps/lexiaid/users/$uid';

  // Path to the 'sessions' subcollection for a specific user
  static String sessionsCollection(String uid) => '${userDoc(uid)}/sessions';

  // Path to a specific session document within the subcollection
  static String sessionDoc(String uid, String sessionId) => '${sessionsCollection(uid)}/$sessionId';

  // Path to the 'cards' subcollection for a specific user
  static String cardsCollection(String uid) => '${userDoc(uid)}/cards';

  // Path to a specific card document within the subcollection
  static String cardDoc(String uid, String cardId) => '${cardsCollection(uid)}/$cardId';
}