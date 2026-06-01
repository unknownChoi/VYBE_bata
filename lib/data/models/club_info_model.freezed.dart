// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_info_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClubInfoModel {

 List<Map<String, dynamic>> get nearbySubways; String get openChatUrl; List<String> get cautions; DateTime get updatedAt;
/// Create a copy of ClubInfoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubInfoModelCopyWith<ClubInfoModel> get copyWith => _$ClubInfoModelCopyWithImpl<ClubInfoModel>(this as ClubInfoModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubInfoModel&&const DeepCollectionEquality().equals(other.nearbySubways, nearbySubways)&&(identical(other.openChatUrl, openChatUrl) || other.openChatUrl == openChatUrl)&&const DeepCollectionEquality().equals(other.cautions, cautions)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(nearbySubways),openChatUrl,const DeepCollectionEquality().hash(cautions),updatedAt);

@override
String toString() {
  return 'ClubInfoModel(nearbySubways: $nearbySubways, openChatUrl: $openChatUrl, cautions: $cautions, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ClubInfoModelCopyWith<$Res>  {
  factory $ClubInfoModelCopyWith(ClubInfoModel value, $Res Function(ClubInfoModel) _then) = _$ClubInfoModelCopyWithImpl;
@useResult
$Res call({
 List<Map<String, dynamic>> nearbySubways, String openChatUrl, List<String> cautions, DateTime updatedAt
});




}
/// @nodoc
class _$ClubInfoModelCopyWithImpl<$Res>
    implements $ClubInfoModelCopyWith<$Res> {
  _$ClubInfoModelCopyWithImpl(this._self, this._then);

  final ClubInfoModel _self;
  final $Res Function(ClubInfoModel) _then;

/// Create a copy of ClubInfoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nearbySubways = null,Object? openChatUrl = null,Object? cautions = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
nearbySubways: null == nearbySubways ? _self.nearbySubways : nearbySubways // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,openChatUrl: null == openChatUrl ? _self.openChatUrl : openChatUrl // ignore: cast_nullable_to_non_nullable
as String,cautions: null == cautions ? _self.cautions : cautions // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubInfoModel].
extension ClubInfoModelPatterns on ClubInfoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubInfoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubInfoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubInfoModel value)  $default,){
final _that = this;
switch (_that) {
case _ClubInfoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubInfoModel value)?  $default,){
final _that = this;
switch (_that) {
case _ClubInfoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Map<String, dynamic>> nearbySubways,  String openChatUrl,  List<String> cautions,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubInfoModel() when $default != null:
return $default(_that.nearbySubways,_that.openChatUrl,_that.cautions,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Map<String, dynamic>> nearbySubways,  String openChatUrl,  List<String> cautions,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ClubInfoModel():
return $default(_that.nearbySubways,_that.openChatUrl,_that.cautions,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Map<String, dynamic>> nearbySubways,  String openChatUrl,  List<String> cautions,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ClubInfoModel() when $default != null:
return $default(_that.nearbySubways,_that.openChatUrl,_that.cautions,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ClubInfoModel extends ClubInfoModel {
  const _ClubInfoModel({final  List<Map<String, dynamic>> nearbySubways = const [], this.openChatUrl = '', final  List<String> cautions = const [], required this.updatedAt}): _nearbySubways = nearbySubways,_cautions = cautions,super._();
  

 final  List<Map<String, dynamic>> _nearbySubways;
@override@JsonKey() List<Map<String, dynamic>> get nearbySubways {
  if (_nearbySubways is EqualUnmodifiableListView) return _nearbySubways;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nearbySubways);
}

@override@JsonKey() final  String openChatUrl;
 final  List<String> _cautions;
@override@JsonKey() List<String> get cautions {
  if (_cautions is EqualUnmodifiableListView) return _cautions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cautions);
}

@override final  DateTime updatedAt;

/// Create a copy of ClubInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubInfoModelCopyWith<_ClubInfoModel> get copyWith => __$ClubInfoModelCopyWithImpl<_ClubInfoModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubInfoModel&&const DeepCollectionEquality().equals(other._nearbySubways, _nearbySubways)&&(identical(other.openChatUrl, openChatUrl) || other.openChatUrl == openChatUrl)&&const DeepCollectionEquality().equals(other._cautions, _cautions)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_nearbySubways),openChatUrl,const DeepCollectionEquality().hash(_cautions),updatedAt);

@override
String toString() {
  return 'ClubInfoModel(nearbySubways: $nearbySubways, openChatUrl: $openChatUrl, cautions: $cautions, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ClubInfoModelCopyWith<$Res> implements $ClubInfoModelCopyWith<$Res> {
  factory _$ClubInfoModelCopyWith(_ClubInfoModel value, $Res Function(_ClubInfoModel) _then) = __$ClubInfoModelCopyWithImpl;
@override @useResult
$Res call({
 List<Map<String, dynamic>> nearbySubways, String openChatUrl, List<String> cautions, DateTime updatedAt
});




}
/// @nodoc
class __$ClubInfoModelCopyWithImpl<$Res>
    implements _$ClubInfoModelCopyWith<$Res> {
  __$ClubInfoModelCopyWithImpl(this._self, this._then);

  final _ClubInfoModel _self;
  final $Res Function(_ClubInfoModel) _then;

/// Create a copy of ClubInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nearbySubways = null,Object? openChatUrl = null,Object? cautions = null,Object? updatedAt = null,}) {
  return _then(_ClubInfoModel(
nearbySubways: null == nearbySubways ? _self._nearbySubways : nearbySubways // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,openChatUrl: null == openChatUrl ? _self.openChatUrl : openChatUrl // ignore: cast_nullable_to_non_nullable
as String,cautions: null == cautions ? _self._cautions : cautions // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
