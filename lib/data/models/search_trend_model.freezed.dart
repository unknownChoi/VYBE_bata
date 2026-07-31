// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_trend_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchTrendItem {

 int get rank; String get keyword; TrendStatus get status; int? get change;/// 0이면 실데이터가 아니라 fallback 큐레이션으로 채운 자리.
 int get uniqueUsers;
/// Create a copy of SearchTrendItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchTrendItemCopyWith<SearchTrendItem> get copyWith => _$SearchTrendItemCopyWithImpl<SearchTrendItem>(this as SearchTrendItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchTrendItem&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.status, status) || other.status == status)&&(identical(other.change, change) || other.change == change)&&(identical(other.uniqueUsers, uniqueUsers) || other.uniqueUsers == uniqueUsers));
}


@override
int get hashCode => Object.hash(runtimeType,rank,keyword,status,change,uniqueUsers);

@override
String toString() {
  return 'SearchTrendItem(rank: $rank, keyword: $keyword, status: $status, change: $change, uniqueUsers: $uniqueUsers)';
}


}

/// @nodoc
abstract mixin class $SearchTrendItemCopyWith<$Res>  {
  factory $SearchTrendItemCopyWith(SearchTrendItem value, $Res Function(SearchTrendItem) _then) = _$SearchTrendItemCopyWithImpl;
@useResult
$Res call({
 int rank, String keyword, TrendStatus status, int? change, int uniqueUsers
});




}
/// @nodoc
class _$SearchTrendItemCopyWithImpl<$Res>
    implements $SearchTrendItemCopyWith<$Res> {
  _$SearchTrendItemCopyWithImpl(this._self, this._then);

  final SearchTrendItem _self;
  final $Res Function(SearchTrendItem) _then;

/// Create a copy of SearchTrendItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? keyword = null,Object? status = null,Object? change = freezed,Object? uniqueUsers = null,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TrendStatus,change: freezed == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as int?,uniqueUsers: null == uniqueUsers ? _self.uniqueUsers : uniqueUsers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchTrendItem].
extension SearchTrendItemPatterns on SearchTrendItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchTrendItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchTrendItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchTrendItem value)  $default,){
final _that = this;
switch (_that) {
case _SearchTrendItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchTrendItem value)?  $default,){
final _that = this;
switch (_that) {
case _SearchTrendItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank,  String keyword,  TrendStatus status,  int? change,  int uniqueUsers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchTrendItem() when $default != null:
return $default(_that.rank,_that.keyword,_that.status,_that.change,_that.uniqueUsers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank,  String keyword,  TrendStatus status,  int? change,  int uniqueUsers)  $default,) {final _that = this;
switch (_that) {
case _SearchTrendItem():
return $default(_that.rank,_that.keyword,_that.status,_that.change,_that.uniqueUsers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank,  String keyword,  TrendStatus status,  int? change,  int uniqueUsers)?  $default,) {final _that = this;
switch (_that) {
case _SearchTrendItem() when $default != null:
return $default(_that.rank,_that.keyword,_that.status,_that.change,_that.uniqueUsers);case _:
  return null;

}
}

}

/// @nodoc


class _SearchTrendItem extends SearchTrendItem {
  const _SearchTrendItem({required this.rank, required this.keyword, required this.status, required this.change, required this.uniqueUsers}): super._();
  

@override final  int rank;
@override final  String keyword;
@override final  TrendStatus status;
@override final  int? change;
/// 0이면 실데이터가 아니라 fallback 큐레이션으로 채운 자리.
@override final  int uniqueUsers;

/// Create a copy of SearchTrendItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchTrendItemCopyWith<_SearchTrendItem> get copyWith => __$SearchTrendItemCopyWithImpl<_SearchTrendItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchTrendItem&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.status, status) || other.status == status)&&(identical(other.change, change) || other.change == change)&&(identical(other.uniqueUsers, uniqueUsers) || other.uniqueUsers == uniqueUsers));
}


@override
int get hashCode => Object.hash(runtimeType,rank,keyword,status,change,uniqueUsers);

@override
String toString() {
  return 'SearchTrendItem(rank: $rank, keyword: $keyword, status: $status, change: $change, uniqueUsers: $uniqueUsers)';
}


}

/// @nodoc
abstract mixin class _$SearchTrendItemCopyWith<$Res> implements $SearchTrendItemCopyWith<$Res> {
  factory _$SearchTrendItemCopyWith(_SearchTrendItem value, $Res Function(_SearchTrendItem) _then) = __$SearchTrendItemCopyWithImpl;
@override @useResult
$Res call({
 int rank, String keyword, TrendStatus status, int? change, int uniqueUsers
});




}
/// @nodoc
class __$SearchTrendItemCopyWithImpl<$Res>
    implements _$SearchTrendItemCopyWith<$Res> {
  __$SearchTrendItemCopyWithImpl(this._self, this._then);

  final _SearchTrendItem _self;
  final $Res Function(_SearchTrendItem) _then;

/// Create a copy of SearchTrendItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? keyword = null,Object? status = null,Object? change = freezed,Object? uniqueUsers = null,}) {
  return _then(_SearchTrendItem(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TrendStatus,change: freezed == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as int?,uniqueUsers: null == uniqueUsers ? _self.uniqueUsers : uniqueUsers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SearchTrendSnapshot {

 List<SearchTrendItem> get items;/// 실데이터로 채워진 항목 수 (나머지는 fallback).
 int get realCount; DateTime? get updatedAt;
/// Create a copy of SearchTrendSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchTrendSnapshotCopyWith<SearchTrendSnapshot> get copyWith => _$SearchTrendSnapshotCopyWithImpl<SearchTrendSnapshot>(this as SearchTrendSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchTrendSnapshot&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.realCount, realCount) || other.realCount == realCount)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),realCount,updatedAt);

@override
String toString() {
  return 'SearchTrendSnapshot(items: $items, realCount: $realCount, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SearchTrendSnapshotCopyWith<$Res>  {
  factory $SearchTrendSnapshotCopyWith(SearchTrendSnapshot value, $Res Function(SearchTrendSnapshot) _then) = _$SearchTrendSnapshotCopyWithImpl;
@useResult
$Res call({
 List<SearchTrendItem> items, int realCount, DateTime? updatedAt
});




}
/// @nodoc
class _$SearchTrendSnapshotCopyWithImpl<$Res>
    implements $SearchTrendSnapshotCopyWith<$Res> {
  _$SearchTrendSnapshotCopyWithImpl(this._self, this._then);

  final SearchTrendSnapshot _self;
  final $Res Function(SearchTrendSnapshot) _then;

/// Create a copy of SearchTrendSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? realCount = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SearchTrendItem>,realCount: null == realCount ? _self.realCount : realCount // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchTrendSnapshot].
extension SearchTrendSnapshotPatterns on SearchTrendSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchTrendSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchTrendSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchTrendSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _SearchTrendSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchTrendSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _SearchTrendSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SearchTrendItem> items,  int realCount,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchTrendSnapshot() when $default != null:
return $default(_that.items,_that.realCount,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SearchTrendItem> items,  int realCount,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SearchTrendSnapshot():
return $default(_that.items,_that.realCount,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SearchTrendItem> items,  int realCount,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SearchTrendSnapshot() when $default != null:
return $default(_that.items,_that.realCount,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SearchTrendSnapshot extends SearchTrendSnapshot {
  const _SearchTrendSnapshot({required final  List<SearchTrendItem> items, required this.realCount, required this.updatedAt}): _items = items,super._();
  

 final  List<SearchTrendItem> _items;
@override List<SearchTrendItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// 실데이터로 채워진 항목 수 (나머지는 fallback).
@override final  int realCount;
@override final  DateTime? updatedAt;

/// Create a copy of SearchTrendSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchTrendSnapshotCopyWith<_SearchTrendSnapshot> get copyWith => __$SearchTrendSnapshotCopyWithImpl<_SearchTrendSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchTrendSnapshot&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.realCount, realCount) || other.realCount == realCount)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),realCount,updatedAt);

@override
String toString() {
  return 'SearchTrendSnapshot(items: $items, realCount: $realCount, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SearchTrendSnapshotCopyWith<$Res> implements $SearchTrendSnapshotCopyWith<$Res> {
  factory _$SearchTrendSnapshotCopyWith(_SearchTrendSnapshot value, $Res Function(_SearchTrendSnapshot) _then) = __$SearchTrendSnapshotCopyWithImpl;
@override @useResult
$Res call({
 List<SearchTrendItem> items, int realCount, DateTime? updatedAt
});




}
/// @nodoc
class __$SearchTrendSnapshotCopyWithImpl<$Res>
    implements _$SearchTrendSnapshotCopyWith<$Res> {
  __$SearchTrendSnapshotCopyWithImpl(this._self, this._then);

  final _SearchTrendSnapshot _self;
  final $Res Function(_SearchTrendSnapshot) _then;

/// Create a copy of SearchTrendSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? realCount = null,Object? updatedAt = freezed,}) {
  return _then(_SearchTrendSnapshot(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SearchTrendItem>,realCount: null == realCount ? _self.realCount : realCount // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
