// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MenuModel {

 String get menuId; String get clubId; String get name; String get description; int get price; String get imageUrl; String get category; bool get isAvailable; DateTime get createdAt;
/// Create a copy of MenuModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuModelCopyWith<MenuModel> get copyWith => _$MenuModelCopyWithImpl<MenuModel>(this as MenuModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuModel&&(identical(other.menuId, menuId) || other.menuId == menuId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,menuId,clubId,name,description,price,imageUrl,category,isAvailable,createdAt);

@override
String toString() {
  return 'MenuModel(menuId: $menuId, clubId: $clubId, name: $name, description: $description, price: $price, imageUrl: $imageUrl, category: $category, isAvailable: $isAvailable, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MenuModelCopyWith<$Res>  {
  factory $MenuModelCopyWith(MenuModel value, $Res Function(MenuModel) _then) = _$MenuModelCopyWithImpl;
@useResult
$Res call({
 String menuId, String clubId, String name, String description, int price, String imageUrl, String category, bool isAvailable, DateTime createdAt
});




}
/// @nodoc
class _$MenuModelCopyWithImpl<$Res>
    implements $MenuModelCopyWith<$Res> {
  _$MenuModelCopyWithImpl(this._self, this._then);

  final MenuModel _self;
  final $Res Function(MenuModel) _then;

/// Create a copy of MenuModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuId = null,Object? clubId = null,Object? name = null,Object? description = null,Object? price = null,Object? imageUrl = null,Object? category = null,Object? isAvailable = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
menuId: null == menuId ? _self.menuId : menuId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuModel].
extension MenuModelPatterns on MenuModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuModel value)  $default,){
final _that = this;
switch (_that) {
case _MenuModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuModel value)?  $default,){
final _that = this;
switch (_that) {
case _MenuModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String menuId,  String clubId,  String name,  String description,  int price,  String imageUrl,  String category,  bool isAvailable,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuModel() when $default != null:
return $default(_that.menuId,_that.clubId,_that.name,_that.description,_that.price,_that.imageUrl,_that.category,_that.isAvailable,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String menuId,  String clubId,  String name,  String description,  int price,  String imageUrl,  String category,  bool isAvailable,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MenuModel():
return $default(_that.menuId,_that.clubId,_that.name,_that.description,_that.price,_that.imageUrl,_that.category,_that.isAvailable,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String menuId,  String clubId,  String name,  String description,  int price,  String imageUrl,  String category,  bool isAvailable,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MenuModel() when $default != null:
return $default(_that.menuId,_that.clubId,_that.name,_that.description,_that.price,_that.imageUrl,_that.category,_that.isAvailable,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _MenuModel extends MenuModel {
  const _MenuModel({required this.menuId, required this.clubId, required this.name, required this.description, required this.price, required this.imageUrl, required this.category, required this.isAvailable, required this.createdAt}): super._();
  

@override final  String menuId;
@override final  String clubId;
@override final  String name;
@override final  String description;
@override final  int price;
@override final  String imageUrl;
@override final  String category;
@override final  bool isAvailable;
@override final  DateTime createdAt;

/// Create a copy of MenuModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuModelCopyWith<_MenuModel> get copyWith => __$MenuModelCopyWithImpl<_MenuModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuModel&&(identical(other.menuId, menuId) || other.menuId == menuId)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,menuId,clubId,name,description,price,imageUrl,category,isAvailable,createdAt);

@override
String toString() {
  return 'MenuModel(menuId: $menuId, clubId: $clubId, name: $name, description: $description, price: $price, imageUrl: $imageUrl, category: $category, isAvailable: $isAvailable, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MenuModelCopyWith<$Res> implements $MenuModelCopyWith<$Res> {
  factory _$MenuModelCopyWith(_MenuModel value, $Res Function(_MenuModel) _then) = __$MenuModelCopyWithImpl;
@override @useResult
$Res call({
 String menuId, String clubId, String name, String description, int price, String imageUrl, String category, bool isAvailable, DateTime createdAt
});




}
/// @nodoc
class __$MenuModelCopyWithImpl<$Res>
    implements _$MenuModelCopyWith<$Res> {
  __$MenuModelCopyWithImpl(this._self, this._then);

  final _MenuModel _self;
  final $Res Function(_MenuModel) _then;

/// Create a copy of MenuModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuId = null,Object? clubId = null,Object? name = null,Object? description = null,Object? price = null,Object? imageUrl = null,Object? category = null,Object? isAvailable = null,Object? createdAt = null,}) {
  return _then(_MenuModel(
menuId: null == menuId ? _self.menuId : menuId // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
