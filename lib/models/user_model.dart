class UserProfile {
  final String uid;
  final String userName;
  final double defaultSpeechRate;

  const UserProfile({
    required this.uid,
    required this.userName,
    this.defaultSpeechRate = 1.0,
  });

  // Copy with method
  UserProfile copyWith({
    String? uid,
    String? userName,
    double? defaultSpeechRate,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      defaultSpeechRate: defaultSpeechRate ?? this.defaultSpeechRate,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userName': userName,
      'defaultSpeechRate': defaultSpeechRate,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      userName: json['userName'] as String,
      defaultSpeechRate: (json['defaultSpeechRate'] as num?)?.toDouble() ?? 1.0,
    );
  }

  // Equality and hash code
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.uid == uid &&
        other.userName == userName &&
        other.defaultSpeechRate == defaultSpeechRate;
  }

  @override
  int get hashCode {
    return Object.hash(uid, userName, defaultSpeechRate);
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, userName: $userName, defaultSpeechRate: $defaultSpeechRate)';
  }
}
