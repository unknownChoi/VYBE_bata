// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'performance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PerformanceModel {

 String get performanceId; String get clubId; String get clubName;// 비정규화 — 조인 없이 rail/hero 표시
 String get clubArea;// 비정규화 — 지역 표시
 String get genre;// "힙합" 등
 String get artistName;// 헤드라이너 (예: "YANO")
 String get artistType;// "rapper" | "dj"
 DateTime get startAt;// 공연 시작 시각
 String get date;// "YYYYMMDD" — 날짜 버킷
 bool get isFeatured;// true = Hero 캐러셀
 bool get isActive; DateTime get createdAt;
/// Create a copy of PerformanceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceModelCopyWith<PerformanceModel> get copyWith => _$PerformanceModelCopyWithImpl<PerformanceModel>(this as PerformanceModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformanceModel&&(identical(other.performanceId, performanceId) || other.performanceId == performanceId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.clubName, clubName) || other.clubName == clubName)&&(identical(other.clubArea, clubArea) || other.clubArea == clubArea)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&(identical(other.artistType, artistType) || other.artistType == artistType)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.date, date) || other.date == date)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,performanceId,clubId,clubName,clubArea,genre,artistName,artistType,startAt,date,isFeatured,isActive,createdAt);

@override
String toString() {
  return 'PerformanceModel(performanceId: $performanceId, clubId: $clubId, clubName: $clubName, clubArea: $clubArea, genre: $genre, artistName: $artistName, artistType: $artistType, startAt: $startAt, date: $date, isFeatured: $isFeatured, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PerformanceModelCopyWith<$Res>  {
  factory $PerformanceModelCopyWith(PerformanceModel value, $Res Function(PerformanceModel) _then) = _$PerformanceModelCopyWithImpl;
@useResult
$Res call({
 String performanceId, String clubId, String clubName, String clubArea, String genre, String artistName, String artistType, DateTime startAt, String date, bool isFeatured, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$PerformanceModelCopyWithImpl<$Res>
    implements $PerformanceModelCopyWith<$Res> {
  _$PerformanceModelCopyWithImpl(this._self, this._then);

  final PerformanceModel _self;
  final $Res Function(PerformanceModel) _then;

/// Create a copy of PerformanceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? performanceId = null,Object? clubId = null,Object? clubName = null,Object? clubArea = null,Object? genre = null,Object? artistName = null,Object? artistType = null,Object? startAt = null,Object? date = null,Object? isFeatured = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
performanceId: null == performanceId ? _self.performanceId : performanceId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,clubName: null == clubName ? _self.clubName : clubName // ignore: cast_nullable_to_non_nullable
as String,clubArea: null == clubArea ? _self.clubArea : clubArea // ignore: cast_nullable_to_non_nullable
as String,genre: null == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String,artistName: null == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String,artistType: null == artistType ? _self.artistType : artistType // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PerformanceModel].
extension PerformanceModelPatterns on PerformanceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerformanceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerformanceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerformanceModel value)  $default,){
final _that = this;
switch (_that) {
case _PerformanceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerformanceModel value)?  $default,){
final _that = this;
switch (_that) {
case _PerformanceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String performanceId,  String clubId,  String clubName,  String clubArea,  String genre,  String artistName,  String artistType,  DateTime startAt,  String date,  bool isFeatured,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformanceModel() when $default != null:
return $default(_that.performanceId,_that.clubId,_that.clubName,_that.clubArea,_that.genre,_that.artistName,_that.artistType,_that.startAt,_that.date,_that.isFeatured,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String performanceId,  String clubId,  String clubName,  String clubArea,  String genre,  String artistName,  String artistType,  DateTime startAt,  String date,  bool isFeatured,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PerformanceModel():
return $default(_that.performanceId,_that.clubId,_that.clubName,_that.clubArea,_that.genre,_that.artistName,_that.artistType,_that.startAt,_that.date,_that.isFeatured,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String performanceId,  String clubId,  String clubName,  String clubArea,  String genre,  String artistName,  String artistType,  DateTime startAt,  String date,  bool isFeatured,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PerformanceModel() when $default != null:
return $default(_that.performanceId,_that.clubId,_that.clubName,_that.clubArea,_that.genre,_that.artistName,_that.artistType,_that.startAt,_that.date,_that.isFeatured,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _PerformanceModel extends PerformanceModel {
  const _PerformanceModel({required this.performanceId, required this.clubId, required this.clubName, required this.clubArea, required this.genre, required this.artistName, required this.artistType, required this.startAt, required this.date, this.isFeatured = false, this.isActive = true, required this.createdAt}): super._();
  

@override final  String performanceId;
@override final  String clubId;
@override final  String clubName;
// 비정규화 — 조인 없이 rail/hero 표시
@override final  String clubArea;
// 비정규화 — 지역 표시
@override final  String genre;
// "힙합" 등
@override final  String artistName;
// 헤드라이너 (예: "YANO")
@override final  String artistType;
// "rapper" | "dj"
@override final  DateTime startAt;
// 공연 시작 시각
@override final  String date;
// "YYYYMMDD" — 날짜 버킷
@override@JsonKey() final  bool isFeatured;
// true = Hero 캐러셀
@override@JsonKey() final  bool isActive;
@override final  DateTime createdAt;

/// Create a copy of PerformanceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformanceModelCopyWith<_PerformanceModel> get copyWith => __$PerformanceModelCopyWithImpl<_PerformanceModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformanceModel&&(identical(other.performanceId, performanceId) || other.performanceId == performanceId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.clubName, clubName) || other.clubName == clubName)&&(identical(other.clubArea, clubArea) || other.clubArea == clubArea)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&(identical(other.artistType, artistType) || other.artistType == artistType)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.date, date) || other.date == date)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,performanceId,clubId,clubName,clubArea,genre,artistName,artistType,startAt,date,isFeatured,isActive,createdAt);

@override
String toString() {
  return 'PerformanceModel(performanceId: $performanceId, clubId: $clubId, clubName: $clubName, clubArea: $clubArea, genre: $genre, artistName: $artistName, artistType: $artistType, startAt: $startAt, date: $date, isFeatured: $isFeatured, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PerformanceModelCopyWith<$Res> implements $PerformanceModelCopyWith<$Res> {
  factory _$PerformanceModelCopyWith(_PerformanceModel value, $Res Function(_PerformanceModel) _then) = __$PerformanceModelCopyWithImpl;
@override @useResult
$Res call({
 String performanceId, String clubId, String clubName, String clubArea, String genre, String artistName, String artistType, DateTime startAt, String date, bool isFeatured, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$PerformanceModelCopyWithImpl<$Res>
    implements _$PerformanceModelCopyWith<$Res> {
  __$PerformanceModelCopyWithImpl(this._self, this._then);

  final _PerformanceModel _self;
  final $Res Function(_PerformanceModel) _then;

/// Create a copy of PerformanceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? performanceId = null,Object? clubId = null,Object? clubName = null,Object? clubArea = null,Object? genre = null,Object? artistName = null,Object? artistType = null,Object? startAt = null,Object? date = null,Object? isFeatured = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_PerformanceModel(
performanceId: null == performanceId ? _self.performanceId : performanceId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,clubName: null == clubName ? _self.clubName : clubName // ignore: cast_nullable_to_non_nullable
as String,clubArea: null == clubArea ? _self.clubArea : clubArea // ignore: cast_nullable_to_non_nullable
as String,genre: null == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String,artistName: null == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String,artistType: null == artistType ? _self.artistType : artistType // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
