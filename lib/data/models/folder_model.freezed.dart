// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'folder_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FolderModel {

 String get folderId; String get name; String get emoji; int get order; DateTime get createdAt;
/// Create a copy of FolderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FolderModelCopyWith<FolderModel> get copyWith => _$FolderModelCopyWithImpl<FolderModel>(this as FolderModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FolderModel&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,folderId,name,emoji,order,createdAt);

@override
String toString() {
  return 'FolderModel(folderId: $folderId, name: $name, emoji: $emoji, order: $order, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FolderModelCopyWith<$Res>  {
  factory $FolderModelCopyWith(FolderModel value, $Res Function(FolderModel) _then) = _$FolderModelCopyWithImpl;
@useResult
$Res call({
 String folderId, String name, String emoji, int order, DateTime createdAt
});




}
/// @nodoc
class _$FolderModelCopyWithImpl<$Res>
    implements $FolderModelCopyWith<$Res> {
  _$FolderModelCopyWithImpl(this._self, this._then);

  final FolderModel _self;
  final $Res Function(FolderModel) _then;

/// Create a copy of FolderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? folderId = null,Object? name = null,Object? emoji = null,Object? order = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
folderId: null == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FolderModel].
extension FolderModelPatterns on FolderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FolderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FolderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FolderModel value)  $default,){
final _that = this;
switch (_that) {
case _FolderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FolderModel value)?  $default,){
final _that = this;
switch (_that) {
case _FolderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String folderId,  String name,  String emoji,  int order,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FolderModel() when $default != null:
return $default(_that.folderId,_that.name,_that.emoji,_that.order,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String folderId,  String name,  String emoji,  int order,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FolderModel():
return $default(_that.folderId,_that.name,_that.emoji,_that.order,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String folderId,  String name,  String emoji,  int order,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FolderModel() when $default != null:
return $default(_that.folderId,_that.name,_that.emoji,_that.order,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _FolderModel extends FolderModel {
  const _FolderModel({required this.folderId, required this.name, this.emoji = '', this.order = 0, required this.createdAt}): super._();
  

@override final  String folderId;
@override final  String name;
@override@JsonKey() final  String emoji;
@override@JsonKey() final  int order;
@override final  DateTime createdAt;

/// Create a copy of FolderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FolderModelCopyWith<_FolderModel> get copyWith => __$FolderModelCopyWithImpl<_FolderModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FolderModel&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,folderId,name,emoji,order,createdAt);

@override
String toString() {
  return 'FolderModel(folderId: $folderId, name: $name, emoji: $emoji, order: $order, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FolderModelCopyWith<$Res> implements $FolderModelCopyWith<$Res> {
  factory _$FolderModelCopyWith(_FolderModel value, $Res Function(_FolderModel) _then) = __$FolderModelCopyWithImpl;
@override @useResult
$Res call({
 String folderId, String name, String emoji, int order, DateTime createdAt
});




}
/// @nodoc
class __$FolderModelCopyWithImpl<$Res>
    implements _$FolderModelCopyWith<$Res> {
  __$FolderModelCopyWithImpl(this._self, this._then);

  final _FolderModel _self;
  final $Res Function(_FolderModel) _then;

/// Create a copy of FolderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? folderId = null,Object? name = null,Object? emoji = null,Object? order = null,Object? createdAt = null,}) {
  return _then(_FolderModel(
folderId: null == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
