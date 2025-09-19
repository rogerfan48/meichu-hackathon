// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Session {

 String get id; String get sessionName; Map<String, FileResource> get fileResources; String? get summary; Map<String, ImgExplanation> get imgExplanations; List<String> get cardIDs; String get status;
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionCopyWith<Session> get copyWith => _$SessionCopyWithImpl<Session>(this as Session, _$identity);

  /// Serializes this Session to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Session&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionName, sessionName) || other.sessionName == sessionName)&&const DeepCollectionEquality().equals(other.fileResources, fileResources)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.imgExplanations, imgExplanations)&&const DeepCollectionEquality().equals(other.cardIDs, cardIDs)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionName,const DeepCollectionEquality().hash(fileResources),summary,const DeepCollectionEquality().hash(imgExplanations),const DeepCollectionEquality().hash(cardIDs),status);

@override
String toString() {
  return 'Session(id: $id, sessionName: $sessionName, fileResources: $fileResources, summary: $summary, imgExplanations: $imgExplanations, cardIDs: $cardIDs, status: $status)';
}


}

/// @nodoc
abstract mixin class $SessionCopyWith<$Res>  {
  factory $SessionCopyWith(Session value, $Res Function(Session) _then) = _$SessionCopyWithImpl;
@useResult
$Res call({
 String id, String sessionName, Map<String, FileResource> fileResources, String? summary, Map<String, ImgExplanation> imgExplanations, List<String> cardIDs, String status
});




}
/// @nodoc
class _$SessionCopyWithImpl<$Res>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._self, this._then);

  final Session _self;
  final $Res Function(Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionName = null,Object? fileResources = null,Object? summary = freezed,Object? imgExplanations = null,Object? cardIDs = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionName: null == sessionName ? _self.sessionName : sessionName // ignore: cast_nullable_to_non_nullable
as String,fileResources: null == fileResources ? _self.fileResources : fileResources // ignore: cast_nullable_to_non_nullable
as Map<String, FileResource>,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,imgExplanations: null == imgExplanations ? _self.imgExplanations : imgExplanations // ignore: cast_nullable_to_non_nullable
as Map<String, ImgExplanation>,cardIDs: null == cardIDs ? _self.cardIDs : cardIDs // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Session].
extension SessionPatterns on Session {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Session value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Session value)  $default,){
final _that = this;
switch (_that) {
case _Session():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Session value)?  $default,){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionName,  Map<String, FileResource> fileResources,  String? summary,  Map<String, ImgExplanation> imgExplanations,  List<String> cardIDs,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.id,_that.sessionName,_that.fileResources,_that.summary,_that.imgExplanations,_that.cardIDs,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionName,  Map<String, FileResource> fileResources,  String? summary,  Map<String, ImgExplanation> imgExplanations,  List<String> cardIDs,  String status)  $default,) {final _that = this;
switch (_that) {
case _Session():
return $default(_that.id,_that.sessionName,_that.fileResources,_that.summary,_that.imgExplanations,_that.cardIDs,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionName,  Map<String, FileResource> fileResources,  String? summary,  Map<String, ImgExplanation> imgExplanations,  List<String> cardIDs,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.id,_that.sessionName,_that.fileResources,_that.summary,_that.imgExplanations,_that.cardIDs,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Session implements Session {
  const _Session({required this.id, required this.sessionName, final  Map<String, FileResource> fileResources = const {}, this.summary, final  Map<String, ImgExplanation> imgExplanations = const {}, final  List<String> cardIDs = const <String>[], this.status = 'idle'}): _fileResources = fileResources,_imgExplanations = imgExplanations,_cardIDs = cardIDs;
  factory _Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

@override final  String id;
@override final  String sessionName;
 final  Map<String, FileResource> _fileResources;
@override@JsonKey() Map<String, FileResource> get fileResources {
  if (_fileResources is EqualUnmodifiableMapView) return _fileResources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fileResources);
}

@override final  String? summary;
 final  Map<String, ImgExplanation> _imgExplanations;
@override@JsonKey() Map<String, ImgExplanation> get imgExplanations {
  if (_imgExplanations is EqualUnmodifiableMapView) return _imgExplanations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_imgExplanations);
}

 final  List<String> _cardIDs;
@override@JsonKey() List<String> get cardIDs {
  if (_cardIDs is EqualUnmodifiableListView) return _cardIDs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cardIDs);
}

@override@JsonKey() final  String status;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionCopyWith<_Session> get copyWith => __$SessionCopyWithImpl<_Session>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Session&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionName, sessionName) || other.sessionName == sessionName)&&const DeepCollectionEquality().equals(other._fileResources, _fileResources)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._imgExplanations, _imgExplanations)&&const DeepCollectionEquality().equals(other._cardIDs, _cardIDs)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionName,const DeepCollectionEquality().hash(_fileResources),summary,const DeepCollectionEquality().hash(_imgExplanations),const DeepCollectionEquality().hash(_cardIDs),status);

@override
String toString() {
  return 'Session(id: $id, sessionName: $sessionName, fileResources: $fileResources, summary: $summary, imgExplanations: $imgExplanations, cardIDs: $cardIDs, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SessionCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$SessionCopyWith(_Session value, $Res Function(_Session) _then) = __$SessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionName, Map<String, FileResource> fileResources, String? summary, Map<String, ImgExplanation> imgExplanations, List<String> cardIDs, String status
});




}
/// @nodoc
class __$SessionCopyWithImpl<$Res>
    implements _$SessionCopyWith<$Res> {
  __$SessionCopyWithImpl(this._self, this._then);

  final _Session _self;
  final $Res Function(_Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionName = null,Object? fileResources = null,Object? summary = freezed,Object? imgExplanations = null,Object? cardIDs = null,Object? status = null,}) {
  return _then(_Session(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionName: null == sessionName ? _self.sessionName : sessionName // ignore: cast_nullable_to_non_nullable
as String,fileResources: null == fileResources ? _self._fileResources : fileResources // ignore: cast_nullable_to_non_nullable
as Map<String, FileResource>,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,imgExplanations: null == imgExplanations ? _self._imgExplanations : imgExplanations // ignore: cast_nullable_to_non_nullable
as Map<String, ImgExplanation>,cardIDs: null == cardIDs ? _self._cardIDs : cardIDs // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FileResource {

 String get id; String get fileURL; String? get fileSummary;
/// Create a copy of FileResource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileResourceCopyWith<FileResource> get copyWith => _$FileResourceCopyWithImpl<FileResource>(this as FileResource, _$identity);

  /// Serializes this FileResource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileResource&&(identical(other.id, id) || other.id == id)&&(identical(other.fileURL, fileURL) || other.fileURL == fileURL)&&(identical(other.fileSummary, fileSummary) || other.fileSummary == fileSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileURL,fileSummary);

@override
String toString() {
  return 'FileResource(id: $id, fileURL: $fileURL, fileSummary: $fileSummary)';
}


}

/// @nodoc
abstract mixin class $FileResourceCopyWith<$Res>  {
  factory $FileResourceCopyWith(FileResource value, $Res Function(FileResource) _then) = _$FileResourceCopyWithImpl;
@useResult
$Res call({
 String id, String fileURL, String? fileSummary
});




}
/// @nodoc
class _$FileResourceCopyWithImpl<$Res>
    implements $FileResourceCopyWith<$Res> {
  _$FileResourceCopyWithImpl(this._self, this._then);

  final FileResource _self;
  final $Res Function(FileResource) _then;

/// Create a copy of FileResource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fileURL = null,Object? fileSummary = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileURL: null == fileURL ? _self.fileURL : fileURL // ignore: cast_nullable_to_non_nullable
as String,fileSummary: freezed == fileSummary ? _self.fileSummary : fileSummary // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FileResource].
extension FileResourcePatterns on FileResource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileResource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileResource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileResource value)  $default,){
final _that = this;
switch (_that) {
case _FileResource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileResource value)?  $default,){
final _that = this;
switch (_that) {
case _FileResource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fileURL,  String? fileSummary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileResource() when $default != null:
return $default(_that.id,_that.fileURL,_that.fileSummary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fileURL,  String? fileSummary)  $default,) {final _that = this;
switch (_that) {
case _FileResource():
return $default(_that.id,_that.fileURL,_that.fileSummary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fileURL,  String? fileSummary)?  $default,) {final _that = this;
switch (_that) {
case _FileResource() when $default != null:
return $default(_that.id,_that.fileURL,_that.fileSummary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FileResource implements FileResource {
  const _FileResource({required this.id, required this.fileURL, this.fileSummary});
  factory _FileResource.fromJson(Map<String, dynamic> json) => _$FileResourceFromJson(json);

@override final  String id;
@override final  String fileURL;
@override final  String? fileSummary;

/// Create a copy of FileResource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileResourceCopyWith<_FileResource> get copyWith => __$FileResourceCopyWithImpl<_FileResource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FileResourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileResource&&(identical(other.id, id) || other.id == id)&&(identical(other.fileURL, fileURL) || other.fileURL == fileURL)&&(identical(other.fileSummary, fileSummary) || other.fileSummary == fileSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileURL,fileSummary);

@override
String toString() {
  return 'FileResource(id: $id, fileURL: $fileURL, fileSummary: $fileSummary)';
}


}

/// @nodoc
abstract mixin class _$FileResourceCopyWith<$Res> implements $FileResourceCopyWith<$Res> {
  factory _$FileResourceCopyWith(_FileResource value, $Res Function(_FileResource) _then) = __$FileResourceCopyWithImpl;
@override @useResult
$Res call({
 String id, String fileURL, String? fileSummary
});




}
/// @nodoc
class __$FileResourceCopyWithImpl<$Res>
    implements _$FileResourceCopyWith<$Res> {
  __$FileResourceCopyWithImpl(this._self, this._then);

  final _FileResource _self;
  final $Res Function(_FileResource) _then;

/// Create a copy of FileResource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fileURL = null,Object? fileSummary = freezed,}) {
  return _then(_FileResource(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileURL: null == fileURL ? _self.fileURL : fileURL // ignore: cast_nullable_to_non_nullable
as String,fileSummary: freezed == fileSummary ? _self.fileSummary : fileSummary // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ImgExplanation {

 String get id; String get imgURL; String? get explanation;
/// Create a copy of ImgExplanation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImgExplanationCopyWith<ImgExplanation> get copyWith => _$ImgExplanationCopyWithImpl<ImgExplanation>(this as ImgExplanation, _$identity);

  /// Serializes this ImgExplanation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImgExplanation&&(identical(other.id, id) || other.id == id)&&(identical(other.imgURL, imgURL) || other.imgURL == imgURL)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imgURL,explanation);

@override
String toString() {
  return 'ImgExplanation(id: $id, imgURL: $imgURL, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class $ImgExplanationCopyWith<$Res>  {
  factory $ImgExplanationCopyWith(ImgExplanation value, $Res Function(ImgExplanation) _then) = _$ImgExplanationCopyWithImpl;
@useResult
$Res call({
 String id, String imgURL, String? explanation
});




}
/// @nodoc
class _$ImgExplanationCopyWithImpl<$Res>
    implements $ImgExplanationCopyWith<$Res> {
  _$ImgExplanationCopyWithImpl(this._self, this._then);

  final ImgExplanation _self;
  final $Res Function(ImgExplanation) _then;

/// Create a copy of ImgExplanation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imgURL = null,Object? explanation = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imgURL: null == imgURL ? _self.imgURL : imgURL // ignore: cast_nullable_to_non_nullable
as String,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImgExplanation].
extension ImgExplanationPatterns on ImgExplanation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImgExplanation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImgExplanation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImgExplanation value)  $default,){
final _that = this;
switch (_that) {
case _ImgExplanation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImgExplanation value)?  $default,){
final _that = this;
switch (_that) {
case _ImgExplanation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String imgURL,  String? explanation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImgExplanation() when $default != null:
return $default(_that.id,_that.imgURL,_that.explanation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String imgURL,  String? explanation)  $default,) {final _that = this;
switch (_that) {
case _ImgExplanation():
return $default(_that.id,_that.imgURL,_that.explanation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String imgURL,  String? explanation)?  $default,) {final _that = this;
switch (_that) {
case _ImgExplanation() when $default != null:
return $default(_that.id,_that.imgURL,_that.explanation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImgExplanation implements ImgExplanation {
  const _ImgExplanation({required this.id, required this.imgURL, this.explanation});
  factory _ImgExplanation.fromJson(Map<String, dynamic> json) => _$ImgExplanationFromJson(json);

@override final  String id;
@override final  String imgURL;
@override final  String? explanation;

/// Create a copy of ImgExplanation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImgExplanationCopyWith<_ImgExplanation> get copyWith => __$ImgExplanationCopyWithImpl<_ImgExplanation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImgExplanationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImgExplanation&&(identical(other.id, id) || other.id == id)&&(identical(other.imgURL, imgURL) || other.imgURL == imgURL)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imgURL,explanation);

@override
String toString() {
  return 'ImgExplanation(id: $id, imgURL: $imgURL, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class _$ImgExplanationCopyWith<$Res> implements $ImgExplanationCopyWith<$Res> {
  factory _$ImgExplanationCopyWith(_ImgExplanation value, $Res Function(_ImgExplanation) _then) = __$ImgExplanationCopyWithImpl;
@override @useResult
$Res call({
 String id, String imgURL, String? explanation
});




}
/// @nodoc
class __$ImgExplanationCopyWithImpl<$Res>
    implements _$ImgExplanationCopyWith<$Res> {
  __$ImgExplanationCopyWithImpl(this._self, this._then);

  final _ImgExplanation _self;
  final $Res Function(_ImgExplanation) _then;

/// Create a copy of ImgExplanation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imgURL = null,Object? explanation = freezed,}) {
  return _then(_ImgExplanation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imgURL: null == imgURL ? _self.imgURL : imgURL // ignore: cast_nullable_to_non_nullable
as String,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
