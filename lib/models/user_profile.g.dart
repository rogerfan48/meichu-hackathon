// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  uid: json['uid'] as String,
  userName: json['userName'] as String,
  defaultSpeechRate: (json['defaultSpeechRate'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'userName': instance.userName,
      'defaultSpeechRate': instance.defaultSpeechRate,
    };
