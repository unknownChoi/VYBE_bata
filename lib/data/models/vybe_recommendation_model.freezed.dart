// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vybe_recommendation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VybeRecommendationModel {

 String get recId; String get clubId; int get rank;// 1 = featured(NO.1 PICK)
 int get match;// VYBE 매치 %
 String get reason;// 큐레이터 노트
 List<String> get tags;// 큐레이션 태그 override(비면 club.tags 사용)
 DateTime get weekOf;// 주간 식별(매주 화요일 업데이트)
 bool get isActive;// 노출 여부
 DateTime get createdAt;
/// Create a copy of VybeRecommendationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VybeRecommendationModelCopyWith<VybeRecommendationModel> get copyWith => _$VybeRecommendationModelCopyWithImpl<VybeRecommendationModel>(this as VybeRecommendationModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VybeRecommendationModel&&(identical(other.recId, recId) || other.recId == recId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.match, match) || other.match == match)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.weekOf, weekOf) || other.weekOf == weekOf)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,recId,clubId,rank,match,reason,const DeepCollectionEquality().hash(tags),weekOf,isActive,createdAt);

@override
String toString() {
  return 'VybeRecommendationModel(recId: $recId, clubId: $clubId, rank: $rank, match: $match, reason: $reason, tags: $tags, weekOf: $weekOf, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $VybeRecommendationModelCopyWith<$Res>  {
  factory $VybeRecommendationModelCopyWith(VybeRecommendationModel value, $Res Function(VybeRecommendationModel) _then) = _$VybeRecommendationModelCopyWithImpl;
@useResult
$Res call({
 String recId, String clubId, int rank, int match, String reason, List<String> tags, DateTime weekOf, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$VybeRecommendationModelCopyWithImpl<$Res>
    implements $VybeRecommendationModelCopyWith<$Res> {
  _$VybeRecommendationModelCopyWithImpl(this._self, this._then);

  final VybeRecommendationModel _self;
  final $Res Function(VybeRecommendationModel) _then;

/// Create a copy of VybeRecommendationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recId = null,Object? clubId = null,Object? rank = null,Object? match = null,Object? reason = null,Object? tags = null,Object? weekOf = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
recId: null == recId ? _self.recId : recId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,match: null == match ? _self.match : match // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,weekOf: null == weekOf ? _self.weekOf : weekOf // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [VybeRecommendationModel].
extension VybeRecommendationModelPatterns on VybeRecommendationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VybeRecommendationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VybeRecommendationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VybeRecommendationModel value)  $default,){
final _that = this;
switch (_that) {
case _VybeRecommendationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VybeRecommendationModel value)?  $default,){
final _that = this;
switch (_that) {
case _VybeRecommendationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recId,  String clubId,  int rank,  int match,  String reason,  List<String> tags,  DateTime weekOf,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VybeRecommendationModel() when $default != null:
return $default(_that.recId,_that.clubId,_that.rank,_that.match,_that.reason,_that.tags,_that.weekOf,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recId,  String clubId,  int rank,  int match,  String reason,  List<String> tags,  DateTime weekOf,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _VybeRecommendationModel():
return $default(_that.recId,_that.clubId,_that.rank,_that.match,_that.reason,_that.tags,_that.weekOf,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recId,  String clubId,  int rank,  int match,  String reason,  List<String> tags,  DateTime weekOf,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _VybeRecommendationModel() when $default != null:
return $default(_that.recId,_that.clubId,_that.rank,_that.match,_that.reason,_that.tags,_that.weekOf,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _VybeRecommendationModel extends VybeRecommendationModel {
  const _VybeRecommendationModel({required this.recId, required this.clubId, required this.rank, required this.match, required this.reason, final  List<String> tags = const [], required this.weekOf, required this.isActive, required this.createdAt}): _tags = tags,super._();
  

@override final  String recId;
@override final  String clubId;
@override final  int rank;
// 1 = featured(NO.1 PICK)
@override final  int match;
// VYBE 매치 %
@override final  String reason;
// 큐레이터 노트
 final  List<String> _tags;
// 큐레이터 노트
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

// 큐레이션 태그 override(비면 club.tags 사용)
@override final  DateTime weekOf;
// 주간 식별(매주 화요일 업데이트)
@override final  bool isActive;
// 노출 여부
@override final  DateTime createdAt;

/// Create a copy of VybeRecommendationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VybeRecommendationModelCopyWith<_VybeRecommendationModel> get copyWith => __$VybeRecommendationModelCopyWithImpl<_VybeRecommendationModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VybeRecommendationModel&&(identical(other.recId, recId) || other.recId == recId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.match, match) || other.match == match)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.weekOf, weekOf) || other.weekOf == weekOf)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,recId,clubId,rank,match,reason,const DeepCollectionEquality().hash(_tags),weekOf,isActive,createdAt);

@override
String toString() {
  return 'VybeRecommendationModel(recId: $recId, clubId: $clubId, rank: $rank, match: $match, reason: $reason, tags: $tags, weekOf: $weekOf, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$VybeRecommendationModelCopyWith<$Res> implements $VybeRecommendationModelCopyWith<$Res> {
  factory _$VybeRecommendationModelCopyWith(_VybeRecommendationModel value, $Res Function(_VybeRecommendationModel) _then) = __$VybeRecommendationModelCopyWithImpl;
@override @useResult
$Res call({
 String recId, String clubId, int rank, int match, String reason, List<String> tags, DateTime weekOf, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$VybeRecommendationModelCopyWithImpl<$Res>
    implements _$VybeRecommendationModelCopyWith<$Res> {
  __$VybeRecommendationModelCopyWithImpl(this._self, this._then);

  final _VybeRecommendationModel _self;
  final $Res Function(_VybeRecommendationModel) _then;

/// Create a copy of VybeRecommendationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recId = null,Object? clubId = null,Object? rank = null,Object? match = null,Object? reason = null,Object? tags = null,Object? weekOf = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_VybeRecommendationModel(
recId: null == recId ? _self.recId : recId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,match: null == match ? _self.match : match // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,weekOf: null == weekOf ? _self.weekOf : weekOf // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
