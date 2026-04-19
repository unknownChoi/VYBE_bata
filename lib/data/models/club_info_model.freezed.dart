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

 String get operatingHours; String get parking; String get dressCode; String get ageLimit; List<String> get sns; DateTime get updatedAt;
/// Create a copy of ClubInfoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubInfoModelCopyWith<ClubInfoModel> get copyWith => _$ClubInfoModelCopyWithImpl<ClubInfoModel>(this as ClubInfoModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubInfoModel&&(identical(other.operatingHours, operatingHours) || other.operatingHours == operatingHours)&&(identical(other.parking, parking) || other.parking == parking)&&(identical(other.dressCode, dressCode) || other.dressCode == dressCode)&&(identical(other.ageLimit, ageLimit) || other.ageLimit == ageLimit)&&const DeepCollectionEquality().equals(other.sns, sns)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,operatingHours,parking,dressCode,ageLimit,const DeepCollectionEquality().hash(sns),updatedAt);

@override
String toString() {
  return 'ClubInfoModel(operatingHours: $operatingHours, parking: $parking, dressCode: $dressCode, ageLimit: $ageLimit, sns: $sns, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ClubInfoModelCopyWith<$Res>  {
  factory $ClubInfoModelCopyWith(ClubInfoModel value, $Res Function(ClubInfoModel) _then) = _$ClubInfoModelCopyWithImpl;
@useResult
$Res call({
 String operatingHours, String parking, String dressCode, String ageLimit, List<String> sns, DateTime updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? operatingHours = null,Object? parking = null,Object? dressCode = null,Object? ageLimit = null,Object? sns = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
operatingHours: null == operatingHours ? _self.operatingHours : operatingHours // ignore: cast_nullable_to_non_nullable
as String,parking: null == parking ? _self.parking : parking // ignore: cast_nullable_to_non_nullable
as String,dressCode: null == dressCode ? _self.dressCode : dressCode // ignore: cast_nullable_to_non_nullable
as String,ageLimit: null == ageLimit ? _self.ageLimit : ageLimit // ignore: cast_nullable_to_non_nullable
as String,sns: null == sns ? _self.sns : sns // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String operatingHours,  String parking,  String dressCode,  String ageLimit,  List<String> sns,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubInfoModel() when $default != null:
return $default(_that.operatingHours,_that.parking,_that.dressCode,_that.ageLimit,_that.sns,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String operatingHours,  String parking,  String dressCode,  String ageLimit,  List<String> sns,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ClubInfoModel():
return $default(_that.operatingHours,_that.parking,_that.dressCode,_that.ageLimit,_that.sns,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String operatingHours,  String parking,  String dressCode,  String ageLimit,  List<String> sns,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ClubInfoModel() when $default != null:
return $default(_that.operatingHours,_that.parking,_that.dressCode,_that.ageLimit,_that.sns,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ClubInfoModel extends ClubInfoModel {
  const _ClubInfoModel({required this.operatingHours, required this.parking, required this.dressCode, required this.ageLimit, required final  List<String> sns, required this.updatedAt}): _sns = sns,super._();
  

@override final  String operatingHours;
@override final  String parking;
@override final  String dressCode;
@override final  String ageLimit;
 final  List<String> _sns;
@override List<String> get sns {
  if (_sns is EqualUnmodifiableListView) return _sns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sns);
}

@override final  DateTime updatedAt;

/// Create a copy of ClubInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubInfoModelCopyWith<_ClubInfoModel> get copyWith => __$ClubInfoModelCopyWithImpl<_ClubInfoModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubInfoModel&&(identical(other.operatingHours, operatingHours) || other.operatingHours == operatingHours)&&(identical(other.parking, parking) || other.parking == parking)&&(identical(other.dressCode, dressCode) || other.dressCode == dressCode)&&(identical(other.ageLimit, ageLimit) || other.ageLimit == ageLimit)&&const DeepCollectionEquality().equals(other._sns, _sns)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,operatingHours,parking,dressCode,ageLimit,const DeepCollectionEquality().hash(_sns),updatedAt);

@override
String toString() {
  return 'ClubInfoModel(operatingHours: $operatingHours, parking: $parking, dressCode: $dressCode, ageLimit: $ageLimit, sns: $sns, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ClubInfoModelCopyWith<$Res> implements $ClubInfoModelCopyWith<$Res> {
  factory _$ClubInfoModelCopyWith(_ClubInfoModel value, $Res Function(_ClubInfoModel) _then) = __$ClubInfoModelCopyWithImpl;
@override @useResult
$Res call({
 String operatingHours, String parking, String dressCode, String ageLimit, List<String> sns, DateTime updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? operatingHours = null,Object? parking = null,Object? dressCode = null,Object? ageLimit = null,Object? sns = null,Object? updatedAt = null,}) {
  return _then(_ClubInfoModel(
operatingHours: null == operatingHours ? _self.operatingHours : operatingHours // ignore: cast_nullable_to_non_nullable
as String,parking: null == parking ? _self.parking : parking // ignore: cast_nullable_to_non_nullable
as String,dressCode: null == dressCode ? _self.dressCode : dressCode // ignore: cast_nullable_to_non_nullable
as String,ageLimit: null == ageLimit ? _self.ageLimit : ageLimit // ignore: cast_nullable_to_non_nullable
as String,sns: null == sns ? _self._sns : sns // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
