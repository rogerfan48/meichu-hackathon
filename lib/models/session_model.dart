class Session {
  final String id;
  final String sessionName;
  final Map<String, FileResource> fileResources;
  final String? summary;
  final Map<String, ImgExplanation> imgExplanations;
  final List<String> cardIDs;
  final String status;

  const Session({
    required this.id,
    required this.sessionName,
    this.fileResources = const {},
    this.summary,
    this.imgExplanations = const {},
    this.cardIDs = const <String>[],
    this.status = 'idle',
  });

  // Copy with method
  Session copyWith({
    String? id,
    String? sessionName,
    Map<String, FileResource>? fileResources,
    String? summary,
    Map<String, ImgExplanation>? imgExplanations,
    List<String>? cardIDs,
    String? status,
  }) {
    return Session(
      id: id ?? this.id,
      sessionName: sessionName ?? this.sessionName,
      fileResources: fileResources ?? this.fileResources,
      summary: summary ?? this.summary,
      imgExplanations: imgExplanations ?? this.imgExplanations,
      cardIDs: cardIDs ?? this.cardIDs,
      status: status ?? this.status,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionName': sessionName,
      'fileResources': fileResources.map((k, v) => MapEntry(k, v.toJson())),
      'summary': summary,
      'imgExplanations': imgExplanations.map((k, v) => MapEntry(k, v.toJson())),
      'cardIDs': cardIDs,
      'status': status,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      sessionName: json['sessionName'] as String,
      fileResources: (json['fileResources'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, FileResource.fromJson(v as Map<String, dynamic>))) ??
          const {},
      summary: json['summary'] as String?,
      imgExplanations: (json['imgExplanations'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, ImgExplanation.fromJson(v as Map<String, dynamic>))) ??
          const {},
      cardIDs: (json['cardIDs'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
      status: json['status'] as String? ?? 'idle',
    );
  }

  // Firestore adapter that injects the document id and converts nested maps
  factory Session.fromFirestore(Map<String, dynamic> json, String id) {
    final fr = (json['fileResources'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, FileResource.fromFirestore(Map<String, dynamic>.from(v), k)));
    final imgExps = (json['imgExplanations'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, ImgExplanation.fromFirestore(Map<String, dynamic>.from(v), k)));
    return Session(
      id: id,
      sessionName: json['sessionName'] as String? ?? '',
      fileResources: fr,
      summary: json['summary'] as String?,
      imgExplanations: imgExps,
      cardIDs: (json['cardIDs'] as List<dynamic>? ?? []).cast<String>(),
      status: json['status'] as String? ?? 'idle',
    );
  }

  // Equality and hash code
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session &&
        other.id == id &&
        other.sessionName == sessionName &&
        _mapEquals(other.fileResources, fileResources) &&
        other.summary == summary &&
        _mapEquals(other.imgExplanations, imgExplanations) &&
        _listEquals(other.cardIDs, cardIDs) &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionName,
      Object.hashAll(fileResources.entries.map((e) => Object.hash(e.key, e.value))),
      summary,
      Object.hashAll(imgExplanations.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(cardIDs),
      status,
    );
  }

  @override
  String toString() {
    return 'Session(id: $id, sessionName: $sessionName, fileResources: $fileResources, summary: $summary, imgExplanations: $imgExplanations, cardIDs: $cardIDs, status: $status)';
  }

  // Helper methods for collection equality
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

class FileResource {
  final String id;
  final String fileURL;
  final String? fileSummary;

  const FileResource({
    required this.id,
    required this.fileURL,
    this.fileSummary,
  });

  // Copy with method
  FileResource copyWith({
    String? id,
    String? fileURL,
    String? fileSummary,
  }) {
    return FileResource(
      id: id ?? this.id,
      fileURL: fileURL ?? this.fileURL,
      fileSummary: fileSummary ?? this.fileSummary,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileURL': fileURL,
      'fileSummary': fileSummary,
    };
  }

  factory FileResource.fromJson(Map<String, dynamic> json) {
    return FileResource(
      id: json['id'] as String,
      fileURL: json['fileURL'] as String,
      fileSummary: json['fileSummary'] as String?,
    );
  }

  factory FileResource.fromFirestore(Map<String, dynamic> json, String id) =>
      FileResource.fromJson({...json, 'id': id});

  // Equality and hash code
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileResource &&
        other.id == id &&
        other.fileURL == fileURL &&
        other.fileSummary == fileSummary;
  }

  @override
  int get hashCode {
    return Object.hash(id, fileURL, fileSummary);
  }

  @override
  String toString() {
    return 'FileResource(id: $id, fileURL: $fileURL, fileSummary: $fileSummary)';
  }
}

class ImgExplanation {
  final String id;
  final String imgURL;
  final String? explanation;

  const ImgExplanation({
    required this.id,
    required this.imgURL,
    this.explanation,
  });

  // Copy with method
  ImgExplanation copyWith({
    String? id,
    String? imgURL,
    String? explanation,
  }) {
    return ImgExplanation(
      id: id ?? this.id,
      imgURL: imgURL ?? this.imgURL,
      explanation: explanation ?? this.explanation,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imgURL': imgURL,
      'explanation': explanation,
    };
  }

  factory ImgExplanation.fromJson(Map<String, dynamic> json) {
    return ImgExplanation(
      id: json['id'] as String,
      imgURL: json['imgURL'] as String,
      explanation: json['explanation'] as String?,
    );
  }

  factory ImgExplanation.fromFirestore(Map<String, dynamic> json, String id) =>
      ImgExplanation.fromJson({...json, 'id': id});

  // Equality and hash code
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImgExplanation &&
        other.id == id &&
        other.imgURL == imgURL &&
        other.explanation == explanation;
  }

  @override
  int get hashCode {
    return Object.hash(id, imgURL, explanation);
  }

  @override
  String toString() {
    return 'ImgExplanation(id: $id, imgURL: $imgURL, explanation: $explanation)';
  }
}
