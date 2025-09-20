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

  factory StudyCard.fromJson(Map<String, dynamic> json) {
    return StudyCard(
      id: json['id'] as String,
      sessionID: json['sessionID'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
      imgURL: json['imgURL'] as String?,
      text: json['text'] as String,
      goodCount: json['goodCount'] as int? ?? 0,
      badCount: json['badCount'] as int? ?? 0,
    );
  }

  factory StudyCard.fromFirestore(Map<String, dynamic> json, String id) =>
      StudyCard.fromJson({...json, 'id': id});

  // Equality and hash code
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyCard &&
        other.id == id &&
        other.sessionID == sessionID &&
        _listEquals(other.tags, tags) &&
        other.imgURL == imgURL &&
        other.text == text &&
        other.goodCount == goodCount &&
        other.badCount == badCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionID,
      Object.hashAll(tags),
      imgURL,
      text,
      goodCount,
      badCount,
    );
  }

  // toString
  @override
  String toString() {
    return 'StudyCard(id: $id, sessionID: $sessionID, tags: $tags, imgURL: $imgURL, text: $text, goodCount: $goodCount, badCount: $badCount)';
  }

  // Helper method for list equality
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
