// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BannerModel {

 String get bannerId; String get imageUrl; BannerLinkType get linkType; String get linkValue; int get order; bool get isActive; DateTime get startAt; DateTime get endAt; DateTime get createdAt;
/// Create a copy of BannerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BannerModelCopyWith<BannerModel> get copyWith => _$BannerModelCopyWithImpl<BannerModel>(this as BannerModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BannerModel&&(identical(other.bannerId, bannerId) || other.bannerId == bannerId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.linkType, linkType) || other.linkType == linkType)&&(identical(other.linkValue, linkValue) || other.linkValue == linkValue)&&(identical(other.order, order) || other.order == order)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,bannerId,imageUrl,linkType,linkValue,order,isActive,startAt,endAt,createdAt);

@override
String toString() {
  return 'BannerModel(bannerId: $bannerId, imageUrl: $imageUrl, linkType: $linkType, linkValue: $linkValue, order: $order, isActive: $isActive, startAt: $startAt, endAt: $endAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BannerModelCopyWith<$Res>  {
  factory $BannerModelCopyWith(BannerModel value, $Res Function(BannerModel) _then) = _$BannerModelCopyWithImpl;
@useResult
$Res call({
 String bannerId, String imageUrl, BannerLinkType linkType, String linkValue, int order, bool isActive, DateTime startAt, DateTime endAt, DateTime createdAt
});




}
/// @nodoc
class _$BannerModelCopyWithImpl<$Res>
    implements $BannerModelCopyWith<$Res> {
  _$BannerModelCopyWithImpl(this._self, this._then);

  final BannerModel _self;
  final $Res Function(BannerModel) _then;

/// Create a copy of BannerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bannerId = null,Object? imageUrl = null,Object? linkType = null,Object? linkValue = null,Object? order = null,Object? isActive = null,Object? startAt = null,Object? endAt = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
bannerId: null == bannerId ? _self.bannerId : bannerId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,linkType: null == linkType ? _self.linkType : linkType // ignore: cast_nullable_to_non_nullable
as BannerLinkType,linkValue: null == linkValue ? _self.linkValue : linkValue // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BannerModel].
extension BannerModelPatterns on BannerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BannerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BannerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BannerModel value)  $default,){
final _that = this;
switch (_that) {
case _BannerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BannerModel value)?  $default,){
final _that = this;
switch (_that) {
case _BannerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bannerId,  String imageUrl,  BannerLinkType linkType,  String linkValue,  int order,  bool isActive,  DateTime startAt,  DateTime endAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BannerModel() when $default != null:
return $default(_that.bannerId,_that.imageUrl,_that.linkType,_that.linkValue,_that.order,_that.isActive,_that.startAt,_that.endAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bannerId,  String imageUrl,  BannerLinkType linkType,  String linkValue,  int order,  bool isActive,  DateTime startAt,  DateTime endAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BannerModel():
return $default(_that.bannerId,_that.imageUrl,_that.linkType,_that.linkValue,_that.order,_that.isActive,_that.startAt,_that.endAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bannerId,  String imageUrl,  BannerLinkType linkType,  String linkValue,  int order,  bool isActive,  DateTime startAt,  DateTime endAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BannerModel() when $default != null:
return $default(_that.bannerId,_that.imageUrl,_that.linkType,_that.linkValue,_that.order,_that.isActive,_that.startAt,_that.endAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _BannerModel extends BannerModel {
  const _BannerModel({required this.bannerId, required this.imageUrl, required this.linkType, required this.linkValue, required this.order, required this.isActive, required this.startAt, required this.endAt, required this.createdAt}): super._();
  

@override final  String bannerId;
@override final  String imageUrl;
@override final  BannerLinkType linkType;
@override final  String linkValue;
@override final  int order;
@override final  bool isActive;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override final  DateTime createdAt;

/// Create a copy of BannerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BannerModelCopyWith<_BannerModel> get copyWith => __$BannerModelCopyWithImpl<_BannerModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BannerModel&&(identical(other.bannerId, bannerId) || other.bannerId == bannerId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.linkType, linkType) || other.linkType == linkType)&&(identical(other.linkValue, linkValue) || other.linkValue == linkValue)&&(identical(other.order, order) || other.order == order)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,bannerId,imageUrl,linkType,linkValue,order,isActive,startAt,endAt,createdAt);

@override
String toString() {
  return 'BannerModel(bannerId: $bannerId, imageUrl: $imageUrl, linkType: $linkType, linkValue: $linkValue, order: $order, isActive: $isActive, startAt: $startAt, endAt: $endAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BannerModelCopyWith<$Res> implements $BannerModelCopyWith<$Res> {
  factory _$BannerModelCopyWith(_BannerModel value, $Res Function(_BannerModel) _then) = __$BannerModelCopyWithImpl;
@override @useResult
$Res call({
 String bannerId, String imageUrl, BannerLinkType linkType, String linkValue, int order, bool isActive, DateTime startAt, DateTime endAt, DateTime createdAt
});




}
/// @nodoc
class __$BannerModelCopyWithImpl<$Res>
    implements _$BannerModelCopyWith<$Res> {
  __$BannerModelCopyWithImpl(this._self, this._then);

  final _BannerModel _self;
  final $Res Function(_BannerModel) _then;

/// Create a copy of BannerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bannerId = null,Object? imageUrl = null,Object? linkType = null,Object? linkValue = null,Object? order = null,Object? isActive = null,Object? startAt = null,Object? endAt = null,Object? createdAt = null,}) {
  return _then(_BannerModel(
bannerId: null == bannerId ? _self.bannerId : bannerId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,linkType: null == linkType ? _self.linkType : linkType // ignore: cast_nullable_to_non_nullable
as BannerLinkType,linkValue: null == linkValue ? _self.linkValue : linkValue // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
