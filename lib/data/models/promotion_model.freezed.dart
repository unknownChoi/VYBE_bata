// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promotion_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PromotionModel {

 String get promotionId; String get title;/// 제목 아래 한 줄 요약 (없으면 미표시)
 String get subtitle;/// 상세 상단 히어로 이미지. 비면 히어로 없이 제목부터 시작한다
/// (배너 이미지는 목록용 비율이라 상세에서 재사용하지 않는다).
 String get heroImageUrl;/// 본문 plain text. \n 줄바꿈만 반영 — 마크다운/HTML 파싱 안 함.
 String get content;/// 본문 아래 첨부 사진 0~n장
 List<String> get imageUrls; PromotionCtaType get ctaType;/// ctaType에 따라 clubId 또는 URL
 String get ctaValue;/// CTA 버튼 문구. 비면 ctaType 기본 문구 사용
 String get ctaLabel; bool get isActive;/// 표시용 진행 기간 (없으면 기간 pill 미표시)
 DateTime? get startAt; DateTime? get endAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of PromotionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromotionModelCopyWith<PromotionModel> get copyWith => _$PromotionModelCopyWithImpl<PromotionModel>(this as PromotionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromotionModel&&(identical(other.promotionId, promotionId) || other.promotionId == promotionId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.ctaType, ctaType) || other.ctaType == ctaType)&&(identical(other.ctaValue, ctaValue) || other.ctaValue == ctaValue)&&(identical(other.ctaLabel, ctaLabel) || other.ctaLabel == ctaLabel)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,promotionId,title,subtitle,heroImageUrl,content,const DeepCollectionEquality().hash(imageUrls),ctaType,ctaValue,ctaLabel,isActive,startAt,endAt,createdAt,updatedAt);

@override
String toString() {
  return 'PromotionModel(promotionId: $promotionId, title: $title, subtitle: $subtitle, heroImageUrl: $heroImageUrl, content: $content, imageUrls: $imageUrls, ctaType: $ctaType, ctaValue: $ctaValue, ctaLabel: $ctaLabel, isActive: $isActive, startAt: $startAt, endAt: $endAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PromotionModelCopyWith<$Res>  {
  factory $PromotionModelCopyWith(PromotionModel value, $Res Function(PromotionModel) _then) = _$PromotionModelCopyWithImpl;
@useResult
$Res call({
 String promotionId, String title, String subtitle, String heroImageUrl, String content, List<String> imageUrls, PromotionCtaType ctaType, String ctaValue, String ctaLabel, bool isActive, DateTime? startAt, DateTime? endAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PromotionModelCopyWithImpl<$Res>
    implements $PromotionModelCopyWith<$Res> {
  _$PromotionModelCopyWithImpl(this._self, this._then);

  final PromotionModel _self;
  final $Res Function(PromotionModel) _then;

/// Create a copy of PromotionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? promotionId = null,Object? title = null,Object? subtitle = null,Object? heroImageUrl = null,Object? content = null,Object? imageUrls = null,Object? ctaType = null,Object? ctaValue = null,Object? ctaLabel = null,Object? isActive = null,Object? startAt = freezed,Object? endAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
promotionId: null == promotionId ? _self.promotionId : promotionId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,ctaType: null == ctaType ? _self.ctaType : ctaType // ignore: cast_nullable_to_non_nullable
as PromotionCtaType,ctaValue: null == ctaValue ? _self.ctaValue : ctaValue // ignore: cast_nullable_to_non_nullable
as String,ctaLabel: null == ctaLabel ? _self.ctaLabel : ctaLabel // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PromotionModel].
extension PromotionModelPatterns on PromotionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromotionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromotionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromotionModel value)  $default,){
final _that = this;
switch (_that) {
case _PromotionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromotionModel value)?  $default,){
final _that = this;
switch (_that) {
case _PromotionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String promotionId,  String title,  String subtitle,  String heroImageUrl,  String content,  List<String> imageUrls,  PromotionCtaType ctaType,  String ctaValue,  String ctaLabel,  bool isActive,  DateTime? startAt,  DateTime? endAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromotionModel() when $default != null:
return $default(_that.promotionId,_that.title,_that.subtitle,_that.heroImageUrl,_that.content,_that.imageUrls,_that.ctaType,_that.ctaValue,_that.ctaLabel,_that.isActive,_that.startAt,_that.endAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String promotionId,  String title,  String subtitle,  String heroImageUrl,  String content,  List<String> imageUrls,  PromotionCtaType ctaType,  String ctaValue,  String ctaLabel,  bool isActive,  DateTime? startAt,  DateTime? endAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PromotionModel():
return $default(_that.promotionId,_that.title,_that.subtitle,_that.heroImageUrl,_that.content,_that.imageUrls,_that.ctaType,_that.ctaValue,_that.ctaLabel,_that.isActive,_that.startAt,_that.endAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String promotionId,  String title,  String subtitle,  String heroImageUrl,  String content,  List<String> imageUrls,  PromotionCtaType ctaType,  String ctaValue,  String ctaLabel,  bool isActive,  DateTime? startAt,  DateTime? endAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PromotionModel() when $default != null:
return $default(_that.promotionId,_that.title,_that.subtitle,_that.heroImageUrl,_that.content,_that.imageUrls,_that.ctaType,_that.ctaValue,_that.ctaLabel,_that.isActive,_that.startAt,_that.endAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PromotionModel extends PromotionModel {
  const _PromotionModel({required this.promotionId, required this.title, this.subtitle = '', this.heroImageUrl = '', this.content = '', final  List<String> imageUrls = const <String>[], this.ctaType = PromotionCtaType.none, this.ctaValue = '', this.ctaLabel = '', this.isActive = true, this.startAt, this.endAt, required this.createdAt, required this.updatedAt}): _imageUrls = imageUrls,super._();
  

@override final  String promotionId;
@override final  String title;
/// 제목 아래 한 줄 요약 (없으면 미표시)
@override@JsonKey() final  String subtitle;
/// 상세 상단 히어로 이미지. 비면 히어로 없이 제목부터 시작한다
/// (배너 이미지는 목록용 비율이라 상세에서 재사용하지 않는다).
@override@JsonKey() final  String heroImageUrl;
/// 본문 plain text. \n 줄바꿈만 반영 — 마크다운/HTML 파싱 안 함.
@override@JsonKey() final  String content;
/// 본문 아래 첨부 사진 0~n장
 final  List<String> _imageUrls;
/// 본문 아래 첨부 사진 0~n장
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override@JsonKey() final  PromotionCtaType ctaType;
/// ctaType에 따라 clubId 또는 URL
@override@JsonKey() final  String ctaValue;
/// CTA 버튼 문구. 비면 ctaType 기본 문구 사용
@override@JsonKey() final  String ctaLabel;
@override@JsonKey() final  bool isActive;
/// 표시용 진행 기간 (없으면 기간 pill 미표시)
@override final  DateTime? startAt;
@override final  DateTime? endAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of PromotionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromotionModelCopyWith<_PromotionModel> get copyWith => __$PromotionModelCopyWithImpl<_PromotionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromotionModel&&(identical(other.promotionId, promotionId) || other.promotionId == promotionId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.ctaType, ctaType) || other.ctaType == ctaType)&&(identical(other.ctaValue, ctaValue) || other.ctaValue == ctaValue)&&(identical(other.ctaLabel, ctaLabel) || other.ctaLabel == ctaLabel)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,promotionId,title,subtitle,heroImageUrl,content,const DeepCollectionEquality().hash(_imageUrls),ctaType,ctaValue,ctaLabel,isActive,startAt,endAt,createdAt,updatedAt);

@override
String toString() {
  return 'PromotionModel(promotionId: $promotionId, title: $title, subtitle: $subtitle, heroImageUrl: $heroImageUrl, content: $content, imageUrls: $imageUrls, ctaType: $ctaType, ctaValue: $ctaValue, ctaLabel: $ctaLabel, isActive: $isActive, startAt: $startAt, endAt: $endAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PromotionModelCopyWith<$Res> implements $PromotionModelCopyWith<$Res> {
  factory _$PromotionModelCopyWith(_PromotionModel value, $Res Function(_PromotionModel) _then) = __$PromotionModelCopyWithImpl;
@override @useResult
$Res call({
 String promotionId, String title, String subtitle, String heroImageUrl, String content, List<String> imageUrls, PromotionCtaType ctaType, String ctaValue, String ctaLabel, bool isActive, DateTime? startAt, DateTime? endAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PromotionModelCopyWithImpl<$Res>
    implements _$PromotionModelCopyWith<$Res> {
  __$PromotionModelCopyWithImpl(this._self, this._then);

  final _PromotionModel _self;
  final $Res Function(_PromotionModel) _then;

/// Create a copy of PromotionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? promotionId = null,Object? title = null,Object? subtitle = null,Object? heroImageUrl = null,Object? content = null,Object? imageUrls = null,Object? ctaType = null,Object? ctaValue = null,Object? ctaLabel = null,Object? isActive = null,Object? startAt = freezed,Object? endAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PromotionModel(
promotionId: null == promotionId ? _self.promotionId : promotionId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,ctaType: null == ctaType ? _self.ctaType : ctaType // ignore: cast_nullable_to_non_nullable
as PromotionCtaType,ctaValue: null == ctaValue ? _self.ctaValue : ctaValue // ignore: cast_nullable_to_non_nullable
as String,ctaLabel: null == ctaLabel ? _self.ctaLabel : ctaLabel // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
