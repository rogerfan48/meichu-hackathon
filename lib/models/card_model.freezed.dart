// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudyCard {

 String get id; String get sessionID; List<String> get tags; String? get imgURL; String get text;
/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudyCardCopyWith<StudyCard> get copyWith => _$StudyCardCopyWithImpl<StudyCard>(this as StudyCard, _$identity);

  /// Serializes this StudyCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudyCard&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionID, sessionID) || other.sessionID == sessionID)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.imgURL, imgURL) || other.imgURL == imgURL)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionID,const DeepCollectionEquality().hash(tags),imgURL,text);

@override
String toString() {
  return 'StudyCard(id: $id, sessionID: $sessionID, tags: $tags, imgURL: $imgURL, text: $text)';
}


}

/// @nodoc
abstract mixin class $StudyCardCopyWith<$Res>  {
  factory $StudyCardCopyWith(StudyCard value, $Res Function(StudyCard) _then) = _$StudyCardCopyWithImpl;
@useResult
$Res call({
 String id, String sessionID, List<String> tags, String? imgURL, String text
});




}
/// @nodoc
class _$StudyCardCopyWithImpl<$Res>
    implements $StudyCardCopyWith<$Res> {
  _$StudyCardCopyWithImpl(this._self, this._then);

  final StudyCard _self;
  final $Res Function(StudyCard) _then;

/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionID = null,Object? tags = null,Object? imgURL = freezed,Object? text = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionID: null == sessionID ? _self.sessionID : sessionID // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,imgURL: freezed == imgURL ? _self.imgURL : imgURL // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StudyCard].
extension StudyCardPatterns on StudyCard {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudyCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudyCard value)  $default,){
final _that = this;
switch (_that) {
case _StudyCard():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudyCard value)?  $default,){
final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionID,  List<String> tags,  String? imgURL,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
return $default(_that.id,_that.sessionID,_that.tags,_that.imgURL,_that.text);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionID,  List<String> tags,  String? imgURL,  String text)  $default,) {final _that = this;
switch (_that) {
case _StudyCard():
return $default(_that.id,_that.sessionID,_that.tags,_that.imgURL,_that.text);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionID,  List<String> tags,  String? imgURL,  String text)?  $default,) {final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
return $default(_that.id,_that.sessionID,_that.tags,_that.imgURL,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudyCard implements StudyCard {
  const _StudyCard({required this.id, required this.sessionID, final  List<String> tags = const <String>[], this.imgURL, required this.text}): _tags = tags;
  factory _StudyCard.fromJson(Map<String, dynamic> json) => _$StudyCardFromJson(json);

@override final  String id;
@override final  String sessionID;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? imgURL;
@override final  String text;

/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudyCardCopyWith<_StudyCard> get copyWith => __$StudyCardCopyWithImpl<_StudyCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudyCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudyCard&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionID, sessionID) || other.sessionID == sessionID)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.imgURL, imgURL) || other.imgURL == imgURL)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionID,const DeepCollectionEquality().hash(_tags),imgURL,text);

@override
String toString() {
  return 'StudyCard(id: $id, sessionID: $sessionID, tags: $tags, imgURL: $imgURL, text: $text)';
}


}

/// @nodoc
abstract mixin class _$StudyCardCopyWith<$Res> implements $StudyCardCopyWith<$Res> {
  factory _$StudyCardCopyWith(_StudyCard value, $Res Function(_StudyCard) _then) = __$StudyCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionID, List<String> tags, String? imgURL, String text
});




}
/// @nodoc
class __$StudyCardCopyWithImpl<$Res>
    implements _$StudyCardCopyWith<$Res> {
  __$StudyCardCopyWithImpl(this._self, this._then);

  final _StudyCard _self;
  final $Res Function(_StudyCard) _then;

/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionID = null,Object? tags = null,Object? imgURL = freezed,Object? text = null,}) {
  return _then(_StudyCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionID: null == sessionID ? _self.sessionID : sessionID // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,imgURL: freezed == imgURL ? _self.imgURL : imgURL // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
