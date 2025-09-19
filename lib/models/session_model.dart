import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
abstract class Session with _$Session {
  const factory Session({
    required String id,
    required String sessionName,
    @Default({}) Map<String, FileResource> fileResources,
    String? summary,
    @Default({}) Map<String, ImgExplanation> imgExplanations,
    @Default(<String>[]) List<String> cardIDs,
    @Default('idle') String status,
  }) = _Session;

  // Standard JSON serialization (needed for toJson/fromJson via Freezed)
  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

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
}

@freezed
abstract class FileResource with _$FileResource {
  const factory FileResource({
    required String id,
    required String fileURL,
    String? fileSummary,
  }) = _FileResource;

  factory FileResource.fromJson(Map<String, dynamic> json) => _$FileResourceFromJson(json);

  factory FileResource.fromFirestore(Map<String, dynamic> json, String id) =>
      FileResource.fromJson({...json, 'id': id});
}

@freezed
abstract class ImgExplanation with _$ImgExplanation {
  const factory ImgExplanation({
    required String id,
    required String imgURL,
    String? explanation,
  }) = _ImgExplanation;

  factory ImgExplanation.fromJson(Map<String, dynamic> json) => _$ImgExplanationFromJson(json);

  factory ImgExplanation.fromFirestore(Map<String, dynamic> json, String id) =>
      ImgExplanation.fromJson({...json, 'id': id});
}
