// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoModel {

 String get photoId; String get clubId; String get userId; String get url; PhotoCategory get category; DateTime get createdAt;
/// Create a copy of PhotoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoModelCopyWith<PhotoModel> get copyWith => _$PhotoModelCopyWithImpl<PhotoModel>(this as PhotoModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoModel&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.url, url) || other.url == url)&&(identical(other.category, category) || other.category == category)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,photoId,clubId,userId,url,category,createdAt);

@override
String toString() {
  return 'PhotoModel(photoId: $photoId, clubId: $clubId, userId: $userId, url: $url, category: $category, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PhotoModelCopyWith<$Res>  {
  factory $PhotoModelCopyWith(PhotoModel value, $Res Function(PhotoModel) _then) = _$PhotoModelCopyWithImpl;
@useResult
$Res call({
 String photoId, String clubId, String userId, String url, PhotoCategory category, DateTime createdAt
});




}
/// @nodoc
class _$PhotoModelCopyWithImpl<$Res>
    implements $PhotoModelCopyWith<$Res> {
  _$PhotoModelCopyWithImpl(this._self, this._then);

  final PhotoModel _self;
  final $Res Function(PhotoModel) _then;

/// Create a copy of PhotoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? photoId = null,Object? clubId = null,Object? userId = null,Object? url = null,Object? category = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
photoId: null == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as PhotoCategory,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoModel].
extension PhotoModelPatterns on PhotoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoModel value)  $default,){
final _that = this;
switch (_that) {
case _PhotoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoModel value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String photoId,  String clubId,  String userId,  String url,  PhotoCategory category,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoModel() when $default != null:
return $default(_that.photoId,_that.clubId,_that.userId,_that.url,_that.category,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String photoId,  String clubId,  String userId,  String url,  PhotoCategory category,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PhotoModel():
return $default(_that.photoId,_that.clubId,_that.userId,_that.url,_that.category,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String photoId,  String clubId,  String userId,  String url,  PhotoCategory category,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PhotoModel() when $default != null:
return $default(_that.photoId,_that.clubId,_that.userId,_that.url,_that.category,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoModel extends PhotoModel {
  const _PhotoModel({required this.photoId, required this.clubId, required this.userId, required this.url, required this.category, required this.createdAt}): super._();
  

@override final  String photoId;
@override final  String clubId;
@override final  String userId;
@override final  String url;
@override final  PhotoCategory category;
@override final  DateTime createdAt;

/// Create a copy of PhotoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoModelCopyWith<_PhotoModel> get copyWith => __$PhotoModelCopyWithImpl<_PhotoModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoModel&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.url, url) || other.url == url)&&(identical(other.category, category) || other.category == category)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,photoId,clubId,userId,url,category,createdAt);

@override
String toString() {
  return 'PhotoModel(photoId: $photoId, clubId: $clubId, userId: $userId, url: $url, category: $category, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PhotoModelCopyWith<$Res> implements $PhotoModelCopyWith<$Res> {
  factory _$PhotoModelCopyWith(_PhotoModel value, $Res Function(_PhotoModel) _then) = __$PhotoModelCopyWithImpl;
@override @useResult
$Res call({
 String photoId, String clubId, String userId, String url, PhotoCategory category, DateTime createdAt
});




}
/// @nodoc
class __$PhotoModelCopyWithImpl<$Res>
    implements _$PhotoModelCopyWith<$Res> {
  __$PhotoModelCopyWithImpl(this._self, this._then);

  final _PhotoModel _self;
  final $Res Function(_PhotoModel) _then;

/// Create a copy of PhotoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? photoId = null,Object? clubId = null,Object? userId = null,Object? url = null,Object? category = null,Object? createdAt = null,}) {
  return _then(_PhotoModel(
photoId: null == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as PhotoCategory,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
