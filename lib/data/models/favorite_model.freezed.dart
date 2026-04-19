// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoriteModel {

 String get favoriteId; String get userId; String get clubId; DateTime get createdAt;
/// Create a copy of FavoriteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteModelCopyWith<FavoriteModel> get copyWith => _$FavoriteModelCopyWithImpl<FavoriteModel>(this as FavoriteModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteModel&&(identical(other.favoriteId, favoriteId) || other.favoriteId == favoriteId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,favoriteId,userId,clubId,createdAt);

@override
String toString() {
  return 'FavoriteModel(favoriteId: $favoriteId, userId: $userId, clubId: $clubId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FavoriteModelCopyWith<$Res>  {
  factory $FavoriteModelCopyWith(FavoriteModel value, $Res Function(FavoriteModel) _then) = _$FavoriteModelCopyWithImpl;
@useResult
$Res call({
 String favoriteId, String userId, String clubId, DateTime createdAt
});




}
/// @nodoc
class _$FavoriteModelCopyWithImpl<$Res>
    implements $FavoriteModelCopyWith<$Res> {
  _$FavoriteModelCopyWithImpl(this._self, this._then);

  final FavoriteModel _self;
  final $Res Function(FavoriteModel) _then;

/// Create a copy of FavoriteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? favoriteId = null,Object? userId = null,Object? clubId = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
favoriteId: null == favoriteId ? _self.favoriteId : favoriteId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteModel].
extension FavoriteModelPatterns on FavoriteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteModel value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteModel value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String favoriteId,  String userId,  String clubId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteModel() when $default != null:
return $default(_that.favoriteId,_that.userId,_that.clubId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String favoriteId,  String userId,  String clubId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FavoriteModel():
return $default(_that.favoriteId,_that.userId,_that.clubId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String favoriteId,  String userId,  String clubId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteModel() when $default != null:
return $default(_that.favoriteId,_that.userId,_that.clubId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _FavoriteModel extends FavoriteModel {
  const _FavoriteModel({required this.favoriteId, required this.userId, required this.clubId, required this.createdAt}): super._();
  

@override final  String favoriteId;
@override final  String userId;
@override final  String clubId;
@override final  DateTime createdAt;

/// Create a copy of FavoriteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteModelCopyWith<_FavoriteModel> get copyWith => __$FavoriteModelCopyWithImpl<_FavoriteModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteModel&&(identical(other.favoriteId, favoriteId) || other.favoriteId == favoriteId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,favoriteId,userId,clubId,createdAt);

@override
String toString() {
  return 'FavoriteModel(favoriteId: $favoriteId, userId: $userId, clubId: $clubId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FavoriteModelCopyWith<$Res> implements $FavoriteModelCopyWith<$Res> {
  factory _$FavoriteModelCopyWith(_FavoriteModel value, $Res Function(_FavoriteModel) _then) = __$FavoriteModelCopyWithImpl;
@override @useResult
$Res call({
 String favoriteId, String userId, String clubId, DateTime createdAt
});




}
/// @nodoc
class __$FavoriteModelCopyWithImpl<$Res>
    implements _$FavoriteModelCopyWith<$Res> {
  __$FavoriteModelCopyWithImpl(this._self, this._then);

  final _FavoriteModel _self;
  final $Res Function(_FavoriteModel) _then;

/// Create a copy of FavoriteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? favoriteId = null,Object? userId = null,Object? clubId = null,Object? createdAt = null,}) {
  return _then(_FavoriteModel(
favoriteId: null == favoriteId ? _self.favoriteId : favoriteId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
