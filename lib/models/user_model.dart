import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String userName;
  final String? photoURL; // Added photoURL
  final double defaultSpeechRate;

  const UserProfile({
    required this.uid,
    required this.userName,
    this.photoURL,
    this.defaultSpeechRate = 1.0,
  });

  UserProfile copyWith({
    String? uid,
    String? userName,
    String? photoURL,
    double? defaultSpeechRate,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      photoURL: photoURL ?? this.photoURL,
      defaultSpeechRate: defaultSpeechRate ?? this.defaultSpeechRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userName': userName,
      'photoURL': photoURL,
      'defaultSpeechRate': defaultSpeechRate,
    };
  }

  factory UserProfile.fromFirestore(Map<String, dynamic> json, String uid) {
    return UserProfile(
      uid: json['uid'] as String? ?? uid,
      userName: json['userName'] as String? ?? 'No Name',
      photoURL: json['photoURL'] as String?,
      defaultSpeechRate: (json['defaultSpeechRate'] as num?)?.toDouble() ?? 1.0,
    );
  }
}