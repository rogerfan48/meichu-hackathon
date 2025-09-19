// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  id: json['id'] as String,
  sessionName: json['sessionName'] as String,
  fileResources:
      (json['fileResources'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, FileResource.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  summary: json['summary'] as String?,
  imgExplanations:
      (json['imgExplanations'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ImgExplanation.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  cardIDs:
      (json['cardIDs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  status: json['status'] as String? ?? 'idle',
);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'id': instance.id,
  'sessionName': instance.sessionName,
  'fileResources': instance.fileResources,
  'summary': instance.summary,
  'imgExplanations': instance.imgExplanations,
  'cardIDs': instance.cardIDs,
  'status': instance.status,
};

_FileResource _$FileResourceFromJson(Map<String, dynamic> json) =>
    _FileResource(
      id: json['id'] as String,
      fileURL: json['fileURL'] as String,
      fileSummary: json['fileSummary'] as String?,
    );

Map<String, dynamic> _$FileResourceToJson(_FileResource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileURL': instance.fileURL,
      'fileSummary': instance.fileSummary,
    };

_ImgExplanation _$ImgExplanationFromJson(Map<String, dynamic> json) =>
    _ImgExplanation(
      id: json['id'] as String,
      imgURL: json['imgURL'] as String,
      explanation: json['explanation'] as String?,
    );

Map<String, dynamic> _$ImgExplanationToJson(_ImgExplanation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imgURL': instance.imgURL,
      'explanation': instance.explanation,
    };
