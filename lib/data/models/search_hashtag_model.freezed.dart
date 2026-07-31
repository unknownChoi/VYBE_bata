// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_hashtag_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchHashtagModel {

 String get tagId;/// 표시 라벨 ('힙합' → UI에선 '#힙합')
 String get label; HashtagLinkType get linkType;/// keyword: 검색어 / page: 'freeEntry'|'serviceDrinks'|'hipHop'|
/// 'hotPlaces'|'vybeRecommend'
 String get linkValue;/// 큐레이션 기본 순서
 int get order;/// 집계가 채우는 검색량 순위. null이면 [order]로 정렬.
 int? get popularityRank; bool get isActive;
/// Create a copy of SearchHashtagModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchHashtagModelCopyWith<SearchHashtagModel> get copyWith => _$SearchHashtagModelCopyWithImpl<SearchHashtagModel>(this as SearchHashtagModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchHashtagModel&&(identical(other.tagId, tagId) || other.tagId == tagId)&&(identical(other.label, label) || other.label == label)&&(identical(other.linkType, linkType) || other.linkType == linkType)&&(identical(other.linkValue, linkValue) || other.linkValue == linkValue)&&(identical(other.order, order) || other.order == order)&&(identical(other.popularityRank, popularityRank) || other.popularityRank == popularityRank)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,tagId,label,linkType,linkValue,order,popularityRank,isActive);

@override
String toString() {
  return 'SearchHashtagModel(tagId: $tagId, label: $label, linkType: $linkType, linkValue: $linkValue, order: $order, popularityRank: $popularityRank, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $SearchHashtagModelCopyWith<$Res>  {
  factory $SearchHashtagModelCopyWith(SearchHashtagModel value, $Res Function(SearchHashtagModel) _then) = _$SearchHashtagModelCopyWithImpl;
@useResult
$Res call({
 String tagId, String label, HashtagLinkType linkType, String linkValue, int order, int? popularityRank, bool isActive
});




}
/// @nodoc
class _$SearchHashtagModelCopyWithImpl<$Res>
    implements $SearchHashtagModelCopyWith<$Res> {
  _$SearchHashtagModelCopyWithImpl(this._self, this._then);

  final SearchHashtagModel _self;
  final $Res Function(SearchHashtagModel) _then;

/// Create a copy of SearchHashtagModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tagId = null,Object? label = null,Object? linkType = null,Object? linkValue = null,Object? order = null,Object? popularityRank = freezed,Object? isActive = null,}) {
  return _then(_self.copyWith(
tagId: null == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,linkType: null == linkType ? _self.linkType : linkType // ignore: cast_nullable_to_non_nullable
as HashtagLinkType,linkValue: null == linkValue ? _self.linkValue : linkValue // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,popularityRank: freezed == popularityRank ? _self.popularityRank : popularityRank // ignore: cast_nullable_to_non_nullable
as int?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchHashtagModel].
extension SearchHashtagModelPatterns on SearchHashtagModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchHashtagModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchHashtagModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchHashtagModel value)  $default,){
final _that = this;
switch (_that) {
case _SearchHashtagModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchHashtagModel value)?  $default,){
final _that = this;
switch (_that) {
case _SearchHashtagModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tagId,  String label,  HashtagLinkType linkType,  String linkValue,  int order,  int? popularityRank,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchHashtagModel() when $default != null:
return $default(_that.tagId,_that.label,_that.linkType,_that.linkValue,_that.order,_that.popularityRank,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tagId,  String label,  HashtagLinkType linkType,  String linkValue,  int order,  int? popularityRank,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _SearchHashtagModel():
return $default(_that.tagId,_that.label,_that.linkType,_that.linkValue,_that.order,_that.popularityRank,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tagId,  String label,  HashtagLinkType linkType,  String linkValue,  int order,  int? popularityRank,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _SearchHashtagModel() when $default != null:
return $default(_that.tagId,_that.label,_that.linkType,_that.linkValue,_that.order,_that.popularityRank,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc


class _SearchHashtagModel extends SearchHashtagModel {
  const _SearchHashtagModel({required this.tagId, required this.label, required this.linkType, required this.linkValue, required this.order, required this.popularityRank, required this.isActive}): super._();
  

@override final  String tagId;
/// 표시 라벨 ('힙합' → UI에선 '#힙합')
@override final  String label;
@override final  HashtagLinkType linkType;
/// keyword: 검색어 / page: 'freeEntry'|'serviceDrinks'|'hipHop'|
/// 'hotPlaces'|'vybeRecommend'
@override final  String linkValue;
/// 큐레이션 기본 순서
@override final  int order;
/// 집계가 채우는 검색량 순위. null이면 [order]로 정렬.
@override final  int? popularityRank;
@override final  bool isActive;

/// Create a copy of SearchHashtagModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchHashtagModelCopyWith<_SearchHashtagModel> get copyWith => __$SearchHashtagModelCopyWithImpl<_SearchHashtagModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchHashtagModel&&(identical(other.tagId, tagId) || other.tagId == tagId)&&(identical(other.label, label) || other.label == label)&&(identical(other.linkType, linkType) || other.linkType == linkType)&&(identical(other.linkValue, linkValue) || other.linkValue == linkValue)&&(identical(other.order, order) || other.order == order)&&(identical(other.popularityRank, popularityRank) || other.popularityRank == popularityRank)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,tagId,label,linkType,linkValue,order,popularityRank,isActive);

@override
String toString() {
  return 'SearchHashtagModel(tagId: $tagId, label: $label, linkType: $linkType, linkValue: $linkValue, order: $order, popularityRank: $popularityRank, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$SearchHashtagModelCopyWith<$Res> implements $SearchHashtagModelCopyWith<$Res> {
  factory _$SearchHashtagModelCopyWith(_SearchHashtagModel value, $Res Function(_SearchHashtagModel) _then) = __$SearchHashtagModelCopyWithImpl;
@override @useResult
$Res call({
 String tagId, String label, HashtagLinkType linkType, String linkValue, int order, int? popularityRank, bool isActive
});




}
/// @nodoc
class __$SearchHashtagModelCopyWithImpl<$Res>
    implements _$SearchHashtagModelCopyWith<$Res> {
  __$SearchHashtagModelCopyWithImpl(this._self, this._then);

  final _SearchHashtagModel _self;
  final $Res Function(_SearchHashtagModel) _then;

/// Create a copy of SearchHashtagModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tagId = null,Object? label = null,Object? linkType = null,Object? linkValue = null,Object? order = null,Object? popularityRank = freezed,Object? isActive = null,}) {
  return _then(_SearchHashtagModel(
tagId: null == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,linkType: null == linkType ? _self.linkType : linkType // ignore: cast_nullable_to_non_nullable
as HashtagLinkType,linkValue: null == linkValue ? _self.linkValue : linkValue // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,popularityRank: freezed == popularityRank ? _self.popularityRank : popularityRank // ignore: cast_nullable_to_non_nullable
as int?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
