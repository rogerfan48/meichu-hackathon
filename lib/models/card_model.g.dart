// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudyCard _$StudyCardFromJson(Map<String, dynamic> json) => _StudyCard(
  id: json['id'] as String,
  sessionID: json['sessionID'] as String,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  imgURL: json['imgURL'] as String?,
  text: json['text'] as String,
);

Map<String, dynamic> _$StudyCardToJson(_StudyCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionID': instance.sessionID,
      'tags': instance.tags,
      'imgURL': instance.imgURL,
      'text': instance.text,
    };
