import 'card_model.dart';
import 'session_model.dart';

class UserProfile {
  final String uid;
  final String userName;
  final double defaultSpeechRate;
  final List<StudyCard> cards;
  final List<Session> sessions;

  const UserProfile({
    required this.uid,
    required this.userName,
    this.defaultSpeechRate = 1.0,
    this.cards = const <StudyCard>[],
    this.sessions = const <Session>[],
  });

  // Copy with method - pure data manipulation only
  UserProfile copyWith({
    String? uid,
    String? userName,
    double? defaultSpeechRate,
    List<StudyCard>? cards,
    List<Session>? sessions,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      defaultSpeechRate: defaultSpeechRate ?? this.defaultSpeechRate,
      cards: cards ?? this.cards,
      sessions: sessions ?? this.sessions,
    );
  }

  // JSON serialization - pure data transformation
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userName': userName,
      'defaultSpeechRate': defaultSpeechRate,
      'cards': cards.map((card) => card.toJson()).toList(),
      'sessions': sessions.map((session) => session.toJson()).toList(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      userName: json['userName'] as String,
      defaultSpeechRate: (json['defaultSpeechRate'] as num?)?.toDouble() ?? 1.0,
      cards: (json['cards'] as List<dynamic>?)
              ?.map((cardJson) => StudyCard.fromJson(cardJson as Map<String, dynamic>))
              .toList() ??
          const <StudyCard>[],
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((sessionJson) => Session.fromJson(sessionJson as Map<String, dynamic>))
              .toList() ??
          const <Session>[],
    );
  }

  // Firestore adapter for your database structure
  factory UserProfile.fromFirestore(Map<String, dynamic> json, String uid) {
    // Handle both nested maps (cards.{cardId}: {...}) and arrays
    final cardsData = json['cards'] as Map<String, dynamic>? ?? {};
    final sessionsData = json['sessions'] as Map<String, dynamic>? ?? {};
    
    final cards = cardsData.entries
        .map((entry) => StudyCard.fromFirestore(
            Map<String, dynamic>.from(entry.value), entry.key))
        .toList();
    
    final sessions = sessionsData.entries
        .map((entry) => Session.fromFirestore(
            Map<String, dynamic>.from(entry.value), entry.key))
        .toList();

    return UserProfile(
      uid: json['uid'] as String? ?? uid,
      userName: json['userName'] as String,
      defaultSpeechRate: (json['defaultSpeechRate'] as num?)?.toDouble() ?? 1.0,
      cards: cards,
      sessions: sessions,
    );
  }

  // Equality and hash code - standard data class methods
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.uid == uid &&
        other.userName == userName &&
        other.defaultSpeechRate == defaultSpeechRate &&
        _listEquals(other.cards, cards) &&
        _listEquals(other.sessions, sessions);
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      userName,
      defaultSpeechRate,
      Object.hashAll(cards),
      Object.hashAll(sessions),
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, userName: $userName, defaultSpeechRate: $defaultSpeechRate, cards: ${cards.length} cards, sessions: ${sessions.length} sessions)';
  }

  // Helper method for list equality - pure utility function
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
