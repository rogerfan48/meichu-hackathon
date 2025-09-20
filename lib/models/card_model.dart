import 'package:cloud_firestore/cloud_firestore.dart';

class StudyCard {
  final String id;
  final String sessionID;
  final List<String> tags;
  final String? imgURL;
  final String text;
  final int masteryLevel;
  final Timestamp? lastReviewedAt;

  const StudyCard({
    required this.id,
    required this.sessionID,
    this.tags = const <String>[],
    this.imgURL,
    required this.text,
    this.masteryLevel = 0,
    this.lastReviewedAt,
  });

  StudyCard copyWith({
    String? id,
    String? sessionID,
    List<String>? tags,
    String? imgURL,
    String? text,
    int? masteryLevel,
    Timestamp? lastReviewedAt,
  }) {
    return StudyCard(
      id: id ?? this.id,
      sessionID: sessionID ?? this.sessionID,
      tags: tags ?? this.tags,
      imgURL: imgURL ?? this.imgURL,
      text: text ?? this.text,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionID': sessionID,
      'tags': tags,
      'imgURL': imgURL,
      'text': text,
      'masteryLevel': masteryLevel,
      'lastReviewedAt': lastReviewedAt,
    };
  }

  factory StudyCard.fromJson(Map<String, dynamic> json) {
    return StudyCard(
      id: json['id'] as String? ?? '',
      sessionID: json['sessionID'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
      imgURL: json['imgURL'] as String?,
      text: json['text'] as String? ?? '[No Text]',
      masteryLevel: json['masteryLevel'] as int? ?? 0,
      lastReviewedAt: json['lastReviewedAt'] as Timestamp?,
    );
  }

  factory StudyCard.fromFirestore(Map<String, dynamic> json, String id) =>
      StudyCard.fromJson({...json, 'id': id});
}