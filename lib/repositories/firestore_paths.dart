class FirestorePaths {
  static String userDoc(String uid) => 'apps/hackathon/users/$uid';
  static String cards(String uid) => '${userDoc(uid)}/cards'; // map path usage helper
  static String sessions(String uid) => '${userDoc(uid)}/sessions';
  // Map-based field keys inside user document
  static String cardField(String cardId) => 'cards.$cardId';
  static String sessionField(String sessionId) => 'sessions.$sessionId';
  static String sessionCardIDs(String sessionId) => 'sessions.$sessionId.cardIDs';
  static String sessionFileResources(String sessionId) => 'sessions.$sessionId.fileResources';
  static String sessionImgExplanations(String sessionId) => 'sessions.$sessionId.imgExplanations';
}
