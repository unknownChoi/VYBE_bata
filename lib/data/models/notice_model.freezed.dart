// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notice_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoticeModel {

 String get noticeId; String get title; String get content;// plain text, \n 줄바꿈 그대로 렌더
 List<String> get imageUrls;// "notice" | "update" | "event" | "maint" | "ad"
 String get category;/// 연결된 프로모션 문서 id. 비어 있지 않으면 목록에서 탭했을 때 공지 상세가
/// 아니라 `PromotionDetailScreen`으로 바로 보낸다 (광고 공지 = 배너와 같은 목적지).
/// category와 분리한 이유 — 프로모션 문서가 없는 광고 공지도 있을 수 있고,
/// 반대로 광고가 아닌 공지에서 이벤트 페이지로 보내고 싶을 수도 있다.
 String get promotionId; bool get isPinned; bool get isActive; DateTime get publishedAt;// 목록 정렬 키
 String get authorName; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of NoticeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoticeModelCopyWith<NoticeModel> get copyWith => _$NoticeModelCopyWithImpl<NoticeModel>(this as NoticeModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoticeModel&&(identical(other.noticeId, noticeId) || other.noticeId == noticeId)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.category, category) || other.category == category)&&(identical(other.promotionId, promotionId) || other.promotionId == promotionId)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,noticeId,title,content,const DeepCollectionEquality().hash(imageUrls),category,promotionId,isPinned,isActive,publishedAt,authorName,createdAt,updatedAt);

@override
String toString() {
  return 'NoticeModel(noticeId: $noticeId, title: $title, content: $content, imageUrls: $imageUrls, category: $category, promotionId: $promotionId, isPinned: $isPinned, isActive: $isActive, publishedAt: $publishedAt, authorName: $authorName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NoticeModelCopyWith<$Res>  {
  factory $NoticeModelCopyWith(NoticeModel value, $Res Function(NoticeModel) _then) = _$NoticeModelCopyWithImpl;
@useResult
$Res call({
 String noticeId, String title, String content, List<String> imageUrls, String category, String promotionId, bool isPinned, bool isActive, DateTime publishedAt, String authorName, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$NoticeModelCopyWithImpl<$Res>
    implements $NoticeModelCopyWith<$Res> {
  _$NoticeModelCopyWithImpl(this._self, this._then);

  final NoticeModel _self;
  final $Res Function(NoticeModel) _then;

/// Create a copy of NoticeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? noticeId = null,Object? title = null,Object? content = null,Object? imageUrls = null,Object? category = null,Object? promotionId = null,Object? isPinned = null,Object? isActive = null,Object? publishedAt = null,Object? authorName = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
noticeId: null == noticeId ? _self.noticeId : noticeId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,promotionId: null == promotionId ? _self.promotionId : promotionId // ignore: cast_nullable_to_non_nullable
as String,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NoticeModel].
extension NoticeModelPatterns on NoticeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoticeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoticeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoticeModel value)  $default,){
final _that = this;
switch (_that) {
case _NoticeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoticeModel value)?  $default,){
final _that = this;
switch (_that) {
case _NoticeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String noticeId,  String title,  String content,  List<String> imageUrls,  String category,  String promotionId,  bool isPinned,  bool isActive,  DateTime publishedAt,  String authorName,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoticeModel() when $default != null:
return $default(_that.noticeId,_that.title,_that.content,_that.imageUrls,_that.category,_that.promotionId,_that.isPinned,_that.isActive,_that.publishedAt,_that.authorName,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String noticeId,  String title,  String content,  List<String> imageUrls,  String category,  String promotionId,  bool isPinned,  bool isActive,  DateTime publishedAt,  String authorName,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NoticeModel():
return $default(_that.noticeId,_that.title,_that.content,_that.imageUrls,_that.category,_that.promotionId,_that.isPinned,_that.isActive,_that.publishedAt,_that.authorName,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String noticeId,  String title,  String content,  List<String> imageUrls,  String category,  String promotionId,  bool isPinned,  bool isActive,  DateTime publishedAt,  String authorName,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NoticeModel() when $default != null:
return $default(_that.noticeId,_that.title,_that.content,_that.imageUrls,_that.category,_that.promotionId,_that.isPinned,_that.isActive,_that.publishedAt,_that.authorName,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _NoticeModel extends NoticeModel {
  const _NoticeModel({required this.noticeId, required this.title, required this.content, final  List<String> imageUrls = const <String>[], this.category = 'notice', this.promotionId = '', this.isPinned = false, this.isActive = true, required this.publishedAt, this.authorName = 'VYBE 운영팀', required this.createdAt, required this.updatedAt}): _imageUrls = imageUrls,super._();
  

@override final  String noticeId;
@override final  String title;
@override final  String content;
// plain text, \n 줄바꿈 그대로 렌더
 final  List<String> _imageUrls;
// plain text, \n 줄바꿈 그대로 렌더
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

// "notice" | "update" | "event" | "maint" | "ad"
@override@JsonKey() final  String category;
/// 연결된 프로모션 문서 id. 비어 있지 않으면 목록에서 탭했을 때 공지 상세가
/// 아니라 `PromotionDetailScreen`으로 바로 보낸다 (광고 공지 = 배너와 같은 목적지).
/// category와 분리한 이유 — 프로모션 문서가 없는 광고 공지도 있을 수 있고,
/// 반대로 광고가 아닌 공지에서 이벤트 페이지로 보내고 싶을 수도 있다.
@override@JsonKey() final  String promotionId;
@override@JsonKey() final  bool isPinned;
@override@JsonKey() final  bool isActive;
@override final  DateTime publishedAt;
// 목록 정렬 키
@override@JsonKey() final  String authorName;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of NoticeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoticeModelCopyWith<_NoticeModel> get copyWith => __$NoticeModelCopyWithImpl<_NoticeModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoticeModel&&(identical(other.noticeId, noticeId) || other.noticeId == noticeId)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.category, category) || other.category == category)&&(identical(other.promotionId, promotionId) || other.promotionId == promotionId)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,noticeId,title,content,const DeepCollectionEquality().hash(_imageUrls),category,promotionId,isPinned,isActive,publishedAt,authorName,createdAt,updatedAt);

@override
String toString() {
  return 'NoticeModel(noticeId: $noticeId, title: $title, content: $content, imageUrls: $imageUrls, category: $category, promotionId: $promotionId, isPinned: $isPinned, isActive: $isActive, publishedAt: $publishedAt, authorName: $authorName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NoticeModelCopyWith<$Res> implements $NoticeModelCopyWith<$Res> {
  factory _$NoticeModelCopyWith(_NoticeModel value, $Res Function(_NoticeModel) _then) = __$NoticeModelCopyWithImpl;
@override @useResult
$Res call({
 String noticeId, String title, String content, List<String> imageUrls, String category, String promotionId, bool isPinned, bool isActive, DateTime publishedAt, String authorName, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$NoticeModelCopyWithImpl<$Res>
    implements _$NoticeModelCopyWith<$Res> {
  __$NoticeModelCopyWithImpl(this._self, this._then);

  final _NoticeModel _self;
  final $Res Function(_NoticeModel) _then;

/// Create a copy of NoticeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? noticeId = null,Object? title = null,Object? content = null,Object? imageUrls = null,Object? category = null,Object? promotionId = null,Object? isPinned = null,Object? isActive = null,Object? publishedAt = null,Object? authorName = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_NoticeModel(
noticeId: null == noticeId ? _self.noticeId : noticeId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,promotionId: null == promotionId ? _self.promotionId : promotionId // ignore: cast_nullable_to_non_nullable
as String,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
