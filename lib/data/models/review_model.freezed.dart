// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReviewModel {

 String get reviewId; String get clubId; String get userId; double get rating; String get content; List<String> get imageUrls; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ReviewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewModelCopyWith<ReviewModel> get copyWith => _$ReviewModelCopyWithImpl<ReviewModel>(this as ReviewModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewModel&&(identical(other.reviewId, reviewId) || other.reviewId == reviewId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,reviewId,clubId,userId,rating,content,const DeepCollectionEquality().hash(imageUrls),createdAt,updatedAt);

@override
String toString() {
  return 'ReviewModel(reviewId: $reviewId, clubId: $clubId, userId: $userId, rating: $rating, content: $content, imageUrls: $imageUrls, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReviewModelCopyWith<$Res>  {
  factory $ReviewModelCopyWith(ReviewModel value, $Res Function(ReviewModel) _then) = _$ReviewModelCopyWithImpl;
@useResult
$Res call({
 String reviewId, String clubId, String userId, double rating, String content, List<String> imageUrls, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ReviewModelCopyWithImpl<$Res>
    implements $ReviewModelCopyWith<$Res> {
  _$ReviewModelCopyWithImpl(this._self, this._then);

  final ReviewModel _self;
  final $Res Function(ReviewModel) _then;

/// Create a copy of ReviewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reviewId = null,Object? clubId = null,Object? userId = null,Object? rating = null,Object? content = null,Object? imageUrls = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
reviewId: null == reviewId ? _self.reviewId : reviewId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewModel].
extension ReviewModelPatterns on ReviewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewModel value)  $default,){
final _that = this;
switch (_that) {
case _ReviewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reviewId,  String clubId,  String userId,  double rating,  String content,  List<String> imageUrls,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewModel() when $default != null:
return $default(_that.reviewId,_that.clubId,_that.userId,_that.rating,_that.content,_that.imageUrls,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reviewId,  String clubId,  String userId,  double rating,  String content,  List<String> imageUrls,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReviewModel():
return $default(_that.reviewId,_that.clubId,_that.userId,_that.rating,_that.content,_that.imageUrls,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reviewId,  String clubId,  String userId,  double rating,  String content,  List<String> imageUrls,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReviewModel() when $default != null:
return $default(_that.reviewId,_that.clubId,_that.userId,_that.rating,_that.content,_that.imageUrls,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ReviewModel extends ReviewModel {
  const _ReviewModel({required this.reviewId, required this.clubId, required this.userId, required this.rating, required this.content, required final  List<String> imageUrls, required this.createdAt, required this.updatedAt}): _imageUrls = imageUrls,super._();
  

@override final  String reviewId;
@override final  String clubId;
@override final  String userId;
@override final  double rating;
@override final  String content;
 final  List<String> _imageUrls;
@override List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ReviewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewModelCopyWith<_ReviewModel> get copyWith => __$ReviewModelCopyWithImpl<_ReviewModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewModel&&(identical(other.reviewId, reviewId) || other.reviewId == reviewId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,reviewId,clubId,userId,rating,content,const DeepCollectionEquality().hash(_imageUrls),createdAt,updatedAt);

@override
String toString() {
  return 'ReviewModel(reviewId: $reviewId, clubId: $clubId, userId: $userId, rating: $rating, content: $content, imageUrls: $imageUrls, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewModelCopyWith<$Res> implements $ReviewModelCopyWith<$Res> {
  factory _$ReviewModelCopyWith(_ReviewModel value, $Res Function(_ReviewModel) _then) = __$ReviewModelCopyWithImpl;
@override @useResult
$Res call({
 String reviewId, String clubId, String userId, double rating, String content, List<String> imageUrls, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ReviewModelCopyWithImpl<$Res>
    implements _$ReviewModelCopyWith<$Res> {
  __$ReviewModelCopyWithImpl(this._self, this._then);

  final _ReviewModel _self;
  final $Res Function(_ReviewModel) _then;

/// Create a copy of ReviewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reviewId = null,Object? clubId = null,Object? userId = null,Object? rating = null,Object? content = null,Object? imageUrls = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ReviewModel(
reviewId: null == reviewId ? _self.reviewId : reviewId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
