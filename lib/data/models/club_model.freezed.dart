// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClubModel {

 String get clubId; String get name; String get description; String get address; String get phone; String get instagramUrl; double get lat; double get lng; String get geohash; List<String> get imageUrls; String get thumbnailUrl; List<String> get tags; int get favoriteCount; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ClubModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubModelCopyWith<ClubModel> get copyWith => _$ClubModelCopyWithImpl<ClubModel>(this as ClubModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubModel&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.instagramUrl, instagramUrl) || other.instagramUrl == instagramUrl)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,clubId,name,description,address,phone,instagramUrl,lat,lng,geohash,const DeepCollectionEquality().hash(imageUrls),thumbnailUrl,const DeepCollectionEquality().hash(tags),favoriteCount,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'ClubModel(clubId: $clubId, name: $name, description: $description, address: $address, phone: $phone, instagramUrl: $instagramUrl, lat: $lat, lng: $lng, geohash: $geohash, imageUrls: $imageUrls, thumbnailUrl: $thumbnailUrl, tags: $tags, favoriteCount: $favoriteCount, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ClubModelCopyWith<$Res>  {
  factory $ClubModelCopyWith(ClubModel value, $Res Function(ClubModel) _then) = _$ClubModelCopyWithImpl;
@useResult
$Res call({
 String clubId, String name, String description, String address, String phone, String instagramUrl, double lat, double lng, String geohash, List<String> imageUrls, String thumbnailUrl, List<String> tags, int favoriteCount, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ClubModelCopyWithImpl<$Res>
    implements $ClubModelCopyWith<$Res> {
  _$ClubModelCopyWithImpl(this._self, this._then);

  final ClubModel _self;
  final $Res Function(ClubModel) _then;

/// Create a copy of ClubModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clubId = null,Object? name = null,Object? description = null,Object? address = null,Object? phone = null,Object? instagramUrl = null,Object? lat = null,Object? lng = null,Object? geohash = null,Object? imageUrls = null,Object? thumbnailUrl = null,Object? tags = null,Object? favoriteCount = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,instagramUrl: null == instagramUrl ? _self.instagramUrl : instagramUrl // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,favoriteCount: null == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubModel].
extension ClubModelPatterns on ClubModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubModel value)  $default,){
final _that = this;
switch (_that) {
case _ClubModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubModel value)?  $default,){
final _that = this;
switch (_that) {
case _ClubModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clubId,  String name,  String description,  String address,  String phone,  String instagramUrl,  double lat,  double lng,  String geohash,  List<String> imageUrls,  String thumbnailUrl,  List<String> tags,  int favoriteCount,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubModel() when $default != null:
return $default(_that.clubId,_that.name,_that.description,_that.address,_that.phone,_that.instagramUrl,_that.lat,_that.lng,_that.geohash,_that.imageUrls,_that.thumbnailUrl,_that.tags,_that.favoriteCount,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clubId,  String name,  String description,  String address,  String phone,  String instagramUrl,  double lat,  double lng,  String geohash,  List<String> imageUrls,  String thumbnailUrl,  List<String> tags,  int favoriteCount,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ClubModel():
return $default(_that.clubId,_that.name,_that.description,_that.address,_that.phone,_that.instagramUrl,_that.lat,_that.lng,_that.geohash,_that.imageUrls,_that.thumbnailUrl,_that.tags,_that.favoriteCount,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clubId,  String name,  String description,  String address,  String phone,  String instagramUrl,  double lat,  double lng,  String geohash,  List<String> imageUrls,  String thumbnailUrl,  List<String> tags,  int favoriteCount,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ClubModel() when $default != null:
return $default(_that.clubId,_that.name,_that.description,_that.address,_that.phone,_that.instagramUrl,_that.lat,_that.lng,_that.geohash,_that.imageUrls,_that.thumbnailUrl,_that.tags,_that.favoriteCount,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ClubModel extends ClubModel {
  const _ClubModel({required this.clubId, required this.name, required this.description, required this.address, required this.phone, required this.instagramUrl, required this.lat, required this.lng, required this.geohash, required final  List<String> imageUrls, required this.thumbnailUrl, required final  List<String> tags, required this.favoriteCount, required this.isActive, required this.createdAt, required this.updatedAt}): _imageUrls = imageUrls,_tags = tags,super._();
  

@override final  String clubId;
@override final  String name;
@override final  String description;
@override final  String address;
@override final  String phone;
@override final  String instagramUrl;
@override final  double lat;
@override final  double lng;
@override final  String geohash;
 final  List<String> _imageUrls;
@override List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override final  String thumbnailUrl;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  int favoriteCount;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ClubModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubModelCopyWith<_ClubModel> get copyWith => __$ClubModelCopyWithImpl<_ClubModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubModel&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.instagramUrl, instagramUrl) || other.instagramUrl == instagramUrl)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,clubId,name,description,address,phone,instagramUrl,lat,lng,geohash,const DeepCollectionEquality().hash(_imageUrls),thumbnailUrl,const DeepCollectionEquality().hash(_tags),favoriteCount,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'ClubModel(clubId: $clubId, name: $name, description: $description, address: $address, phone: $phone, instagramUrl: $instagramUrl, lat: $lat, lng: $lng, geohash: $geohash, imageUrls: $imageUrls, thumbnailUrl: $thumbnailUrl, tags: $tags, favoriteCount: $favoriteCount, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ClubModelCopyWith<$Res> implements $ClubModelCopyWith<$Res> {
  factory _$ClubModelCopyWith(_ClubModel value, $Res Function(_ClubModel) _then) = __$ClubModelCopyWithImpl;
@override @useResult
$Res call({
 String clubId, String name, String description, String address, String phone, String instagramUrl, double lat, double lng, String geohash, List<String> imageUrls, String thumbnailUrl, List<String> tags, int favoriteCount, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ClubModelCopyWithImpl<$Res>
    implements _$ClubModelCopyWith<$Res> {
  __$ClubModelCopyWithImpl(this._self, this._then);

  final _ClubModel _self;
  final $Res Function(_ClubModel) _then;

/// Create a copy of ClubModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clubId = null,Object? name = null,Object? description = null,Object? address = null,Object? phone = null,Object? instagramUrl = null,Object? lat = null,Object? lng = null,Object? geohash = null,Object? imageUrls = null,Object? thumbnailUrl = null,Object? tags = null,Object? favoriteCount = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ClubModel(
clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,instagramUrl: null == instagramUrl ? _self.instagramUrl : instagramUrl // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,favoriteCount: null == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
