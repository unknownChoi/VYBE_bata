// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchHistoryModel {

 String get historyId; String get userId; String get keyword; DateTime get createdAt;
/// Create a copy of SearchHistoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchHistoryModelCopyWith<SearchHistoryModel> get copyWith => _$SearchHistoryModelCopyWithImpl<SearchHistoryModel>(this as SearchHistoryModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchHistoryModel&&(identical(other.historyId, historyId) || other.historyId == historyId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,historyId,userId,keyword,createdAt);

@override
String toString() {
  return 'SearchHistoryModel(historyId: $historyId, userId: $userId, keyword: $keyword, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SearchHistoryModelCopyWith<$Res>  {
  factory $SearchHistoryModelCopyWith(SearchHistoryModel value, $Res Function(SearchHistoryModel) _then) = _$SearchHistoryModelCopyWithImpl;
@useResult
$Res call({
 String historyId, String userId, String keyword, DateTime createdAt
});




}
/// @nodoc
class _$SearchHistoryModelCopyWithImpl<$Res>
    implements $SearchHistoryModelCopyWith<$Res> {
  _$SearchHistoryModelCopyWithImpl(this._self, this._then);

  final SearchHistoryModel _self;
  final $Res Function(SearchHistoryModel) _then;

/// Create a copy of SearchHistoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? historyId = null,Object? userId = null,Object? keyword = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
historyId: null == historyId ? _self.historyId : historyId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchHistoryModel].
extension SearchHistoryModelPatterns on SearchHistoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchHistoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchHistoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchHistoryModel value)  $default,){
final _that = this;
switch (_that) {
case _SearchHistoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchHistoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _SearchHistoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String historyId,  String userId,  String keyword,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchHistoryModel() when $default != null:
return $default(_that.historyId,_that.userId,_that.keyword,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String historyId,  String userId,  String keyword,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SearchHistoryModel():
return $default(_that.historyId,_that.userId,_that.keyword,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String historyId,  String userId,  String keyword,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SearchHistoryModel() when $default != null:
return $default(_that.historyId,_that.userId,_that.keyword,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _SearchHistoryModel extends SearchHistoryModel {
  const _SearchHistoryModel({required this.historyId, required this.userId, required this.keyword, required this.createdAt}): super._();
  

@override final  String historyId;
@override final  String userId;
@override final  String keyword;
@override final  DateTime createdAt;

/// Create a copy of SearchHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchHistoryModelCopyWith<_SearchHistoryModel> get copyWith => __$SearchHistoryModelCopyWithImpl<_SearchHistoryModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchHistoryModel&&(identical(other.historyId, historyId) || other.historyId == historyId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,historyId,userId,keyword,createdAt);

@override
String toString() {
  return 'SearchHistoryModel(historyId: $historyId, userId: $userId, keyword: $keyword, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SearchHistoryModelCopyWith<$Res> implements $SearchHistoryModelCopyWith<$Res> {
  factory _$SearchHistoryModelCopyWith(_SearchHistoryModel value, $Res Function(_SearchHistoryModel) _then) = __$SearchHistoryModelCopyWithImpl;
@override @useResult
$Res call({
 String historyId, String userId, String keyword, DateTime createdAt
});




}
/// @nodoc
class __$SearchHistoryModelCopyWithImpl<$Res>
    implements _$SearchHistoryModelCopyWith<$Res> {
  __$SearchHistoryModelCopyWithImpl(this._self, this._then);

  final _SearchHistoryModel _self;
  final $Res Function(_SearchHistoryModel) _then;

/// Create a copy of SearchHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? historyId = null,Object? userId = null,Object? keyword = null,Object? createdAt = null,}) {
  return _then(_SearchHistoryModel(
historyId: null == historyId ? _self.historyId : historyId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
