class StudyCard {
  final String id;
  final String sessionID;
  final List<String> tags;
  final String? imgURL;
  final String text;
  final int goodCount;
  final int badCount;

  const StudyCard({
    required this.id,
    required this.sessionID,
    this.tags = const <String>[],
    this.imgURL,
    required this.text,
    this.goodCount = 0,
    this.badCount = 0,
  });

  // Copy with method for immutable updates
  StudyCard copyWith({
    String? id,
    String? sessionID,
    List<String>? tags,
    String? imgURL,
    String? text,
    int? goodCount,
    int? badCount,
  }) {
    return StudyCard(
      id: id ?? this.id,
      sessionID: sessionID ?? this.sessionID,
      tags: tags ?? this.tags,
      imgURL: imgURL ?? this.imgURL,
      text: text ?? this.text,
      goodCount: goodCount ?? this.goodCount,
      badCount: badCount ?? this.badCount,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionID': sessionID,
      'tags': tags,
      'imgURL': imgURL,
      'text': text,
      'goodCount': goodCount,
      'badCount': badCount,
    };
  }

  // fromJson is the core of the fix
  factory StudyCard.fromJson(Map<String, dynamic> json) {
    return StudyCard(
      id: json['id'] as String? ?? '',
      sessionID: json['sessionID'] as String? ?? '', 
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
      imgURL: json['imgURL'] as String?,
      text: json['text'] as String? ?? '[No Text]', 
      goodCount: json['goodCount'] as int? ?? 0,
      badCount: json['badCount'] as int? ?? 0,
    );
  }

  factory StudyCard.fromFirestore(Map<String, dynamic> json, String id) =>
      StudyCard.fromJson({...json, 'id': id});
}