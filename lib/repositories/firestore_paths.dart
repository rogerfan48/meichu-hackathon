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

  // Path to the 'fileResources' subcollection for a specific session
  static String fileResourcesCollection(String uid, String sessionId) => '${sessionDoc(uid, sessionId)}/fileResources';

  // Path to a specific fileResource document within the subcollection
  static String fileResourceDoc(String uid, String sessionId, String fileResourceId) => '${fileResourcesCollection(uid, sessionId)}/$fileResourceId';

  // Path to the 'imgExplanations' subcollection for a specific session
  static String imgExplanationsCollection(String uid, String sessionId) => '${sessionDoc(uid, sessionId)}/imgExplanations';

  // Path to a specific imgExplanation document within the subcollection
  static String imgExplanationDoc(String uid, String sessionId, String imgExplanationId) => '${imgExplanationsCollection(uid, sessionId)}/$imgExplanationId';
}