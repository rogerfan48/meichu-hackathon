import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id;
  final String sessionName;
  final Timestamp? createdAt;
  final Map<String, FileResource> fileResources;
  final String? summary;
  final Map<String, ImgExplanation> imgExplanations;
  final List<String> cardIDs;
  final String status;

  const Session({
    required this.id,
    required this.sessionName,
    this.createdAt,
    this.fileResources = const {},
    this.summary,
    this.imgExplanations = const {},
    this.cardIDs = const <String>[],
    this.status = 'idle',
  });

  Session copyWith({
    String? id,
    String? sessionName,
    Timestamp? createdAt,
    Map<String, FileResource>? fileResources,
    String? summary,
    Map<String, ImgExplanation>? imgExplanations,
    List<String>? cardIDs,
    String? status,
  }) {
    return Session(
      id: id ?? this.id,
      sessionName: sessionName ?? this.sessionName,
      createdAt: createdAt ?? this.createdAt,
      fileResources: fileResources ?? this.fileResources,
      summary: summary ?? this.summary,
      imgExplanations: imgExplanations ?? this.imgExplanations,
      cardIDs: cardIDs ?? this.cardIDs,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionName': sessionName,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      // fileResources 和 imgExplanations 現在是 subcollections，不存儲在主文檔中
      'summary': summary,
      'cardIDs': cardIDs,
      'status': status,
    };
  }

  factory Session.fromFirestore(Map<String, dynamic> json, String id) {
    return Session(
      id: id,
      sessionName: json['sessionName'] as String? ?? '',
      createdAt: json['createdAt'] as Timestamp?,
      // fileResources 和 imgExplanations 現在是 subcollections，將使用空 Map
      // 實際資料需要通過 SessionRepository 的 watchFileResources 和 watchImgExplanations 獲取
      fileResources: const {},
      summary: json['summary'] as String?,
      imgExplanations: const {},
      cardIDs: (json['cardIDs'] as List<dynamic>? ?? []).cast<String>(),
      status: json['status'] as String? ?? 'idle',
    );
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileURL': fileURL,
      'fileSummary': fileSummary,
    };
  }

  factory FileResource.fromFirestore(Map<String, dynamic> json, String id) {
    return FileResource(
      id: id,
      fileURL: json['fileURL'] as String,
      fileSummary: json['fileSummary'] as String?,
    );
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
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imgURL': imgURL,
      'explanation': explanation,
    };
  }

  factory ImgExplanation.fromFirestore(Map<String, dynamic> json, String id) {
    return ImgExplanation(
      id: id,
      imgURL: json['imgURL'] as String,
      explanation: json['explanation'] as String?,
    );
  }
}