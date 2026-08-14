// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_version_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppVersionConfigModel {

/// "android" | "ios" (= 문서 ID)
 String get platform;/// 이 버전 미만이면 강제 업데이트. 비면 강제 없음.
 String get minVersion;/// 이 버전 미만이면 업데이트 권유(닫을 수 있음). 비면 권유 없음.
 String get latestVersion;/// 스토어 링크. 앱 배포 없이 바꿀 수 있게 서버에 둔다.
 String get storeUrl;/// 업데이트 안내 제목·본문. 비면 화면의 기본 문구를 쓴다.
 String get updateTitle; String get updateMessage;/// 점검 모드 — 버전과 무관하게 앱 진입을 막는다.
 bool get isMaintenance; String get maintenanceMessage; DateTime get updatedAt;
/// Create a copy of AppVersionConfigModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppVersionConfigModelCopyWith<AppVersionConfigModel> get copyWith => _$AppVersionConfigModelCopyWithImpl<AppVersionConfigModel>(this as AppVersionConfigModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppVersionConfigModel&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.storeUrl, storeUrl) || other.storeUrl == storeUrl)&&(identical(other.updateTitle, updateTitle) || other.updateTitle == updateTitle)&&(identical(other.updateMessage, updateMessage) || other.updateMessage == updateMessage)&&(identical(other.isMaintenance, isMaintenance) || other.isMaintenance == isMaintenance)&&(identical(other.maintenanceMessage, maintenanceMessage) || other.maintenanceMessage == maintenanceMessage)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,platform,minVersion,latestVersion,storeUrl,updateTitle,updateMessage,isMaintenance,maintenanceMessage,updatedAt);

@override
String toString() {
  return 'AppVersionConfigModel(platform: $platform, minVersion: $minVersion, latestVersion: $latestVersion, storeUrl: $storeUrl, updateTitle: $updateTitle, updateMessage: $updateMessage, isMaintenance: $isMaintenance, maintenanceMessage: $maintenanceMessage, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AppVersionConfigModelCopyWith<$Res>  {
  factory $AppVersionConfigModelCopyWith(AppVersionConfigModel value, $Res Function(AppVersionConfigModel) _then) = _$AppVersionConfigModelCopyWithImpl;
@useResult
$Res call({
 String platform, String minVersion, String latestVersion, String storeUrl, String updateTitle, String updateMessage, bool isMaintenance, String maintenanceMessage, DateTime updatedAt
});




}
/// @nodoc
class _$AppVersionConfigModelCopyWithImpl<$Res>
    implements $AppVersionConfigModelCopyWith<$Res> {
  _$AppVersionConfigModelCopyWithImpl(this._self, this._then);

  final AppVersionConfigModel _self;
  final $Res Function(AppVersionConfigModel) _then;

/// Create a copy of AppVersionConfigModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? minVersion = null,Object? latestVersion = null,Object? storeUrl = null,Object? updateTitle = null,Object? updateMessage = null,Object? isMaintenance = null,Object? maintenanceMessage = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,storeUrl: null == storeUrl ? _self.storeUrl : storeUrl // ignore: cast_nullable_to_non_nullable
as String,updateTitle: null == updateTitle ? _self.updateTitle : updateTitle // ignore: cast_nullable_to_non_nullable
as String,updateMessage: null == updateMessage ? _self.updateMessage : updateMessage // ignore: cast_nullable_to_non_nullable
as String,isMaintenance: null == isMaintenance ? _self.isMaintenance : isMaintenance // ignore: cast_nullable_to_non_nullable
as bool,maintenanceMessage: null == maintenanceMessage ? _self.maintenanceMessage : maintenanceMessage // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppVersionConfigModel].
extension AppVersionConfigModelPatterns on AppVersionConfigModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppVersionConfigModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppVersionConfigModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppVersionConfigModel value)  $default,){
final _that = this;
switch (_that) {
case _AppVersionConfigModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppVersionConfigModel value)?  $default,){
final _that = this;
switch (_that) {
case _AppVersionConfigModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String platform,  String minVersion,  String latestVersion,  String storeUrl,  String updateTitle,  String updateMessage,  bool isMaintenance,  String maintenanceMessage,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppVersionConfigModel() when $default != null:
return $default(_that.platform,_that.minVersion,_that.latestVersion,_that.storeUrl,_that.updateTitle,_that.updateMessage,_that.isMaintenance,_that.maintenanceMessage,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String platform,  String minVersion,  String latestVersion,  String storeUrl,  String updateTitle,  String updateMessage,  bool isMaintenance,  String maintenanceMessage,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppVersionConfigModel():
return $default(_that.platform,_that.minVersion,_that.latestVersion,_that.storeUrl,_that.updateTitle,_that.updateMessage,_that.isMaintenance,_that.maintenanceMessage,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String platform,  String minVersion,  String latestVersion,  String storeUrl,  String updateTitle,  String updateMessage,  bool isMaintenance,  String maintenanceMessage,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppVersionConfigModel() when $default != null:
return $default(_that.platform,_that.minVersion,_that.latestVersion,_that.storeUrl,_that.updateTitle,_that.updateMessage,_that.isMaintenance,_that.maintenanceMessage,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AppVersionConfigModel extends AppVersionConfigModel {
  const _AppVersionConfigModel({required this.platform, this.minVersion = '', this.latestVersion = '', this.storeUrl = '', this.updateTitle = '', this.updateMessage = '', this.isMaintenance = false, this.maintenanceMessage = '', required this.updatedAt}): super._();
  

/// "android" | "ios" (= 문서 ID)
@override final  String platform;
/// 이 버전 미만이면 강제 업데이트. 비면 강제 없음.
@override@JsonKey() final  String minVersion;
/// 이 버전 미만이면 업데이트 권유(닫을 수 있음). 비면 권유 없음.
@override@JsonKey() final  String latestVersion;
/// 스토어 링크. 앱 배포 없이 바꿀 수 있게 서버에 둔다.
@override@JsonKey() final  String storeUrl;
/// 업데이트 안내 제목·본문. 비면 화면의 기본 문구를 쓴다.
@override@JsonKey() final  String updateTitle;
@override@JsonKey() final  String updateMessage;
/// 점검 모드 — 버전과 무관하게 앱 진입을 막는다.
@override@JsonKey() final  bool isMaintenance;
@override@JsonKey() final  String maintenanceMessage;
@override final  DateTime updatedAt;

/// Create a copy of AppVersionConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppVersionConfigModelCopyWith<_AppVersionConfigModel> get copyWith => __$AppVersionConfigModelCopyWithImpl<_AppVersionConfigModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppVersionConfigModel&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.storeUrl, storeUrl) || other.storeUrl == storeUrl)&&(identical(other.updateTitle, updateTitle) || other.updateTitle == updateTitle)&&(identical(other.updateMessage, updateMessage) || other.updateMessage == updateMessage)&&(identical(other.isMaintenance, isMaintenance) || other.isMaintenance == isMaintenance)&&(identical(other.maintenanceMessage, maintenanceMessage) || other.maintenanceMessage == maintenanceMessage)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,platform,minVersion,latestVersion,storeUrl,updateTitle,updateMessage,isMaintenance,maintenanceMessage,updatedAt);

@override
String toString() {
  return 'AppVersionConfigModel(platform: $platform, minVersion: $minVersion, latestVersion: $latestVersion, storeUrl: $storeUrl, updateTitle: $updateTitle, updateMessage: $updateMessage, isMaintenance: $isMaintenance, maintenanceMessage: $maintenanceMessage, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppVersionConfigModelCopyWith<$Res> implements $AppVersionConfigModelCopyWith<$Res> {
  factory _$AppVersionConfigModelCopyWith(_AppVersionConfigModel value, $Res Function(_AppVersionConfigModel) _then) = __$AppVersionConfigModelCopyWithImpl;
@override @useResult
$Res call({
 String platform, String minVersion, String latestVersion, String storeUrl, String updateTitle, String updateMessage, bool isMaintenance, String maintenanceMessage, DateTime updatedAt
});




}
/// @nodoc
class __$AppVersionConfigModelCopyWithImpl<$Res>
    implements _$AppVersionConfigModelCopyWith<$Res> {
  __$AppVersionConfigModelCopyWithImpl(this._self, this._then);

  final _AppVersionConfigModel _self;
  final $Res Function(_AppVersionConfigModel) _then;

/// Create a copy of AppVersionConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? minVersion = null,Object? latestVersion = null,Object? storeUrl = null,Object? updateTitle = null,Object? updateMessage = null,Object? isMaintenance = null,Object? maintenanceMessage = null,Object? updatedAt = null,}) {
  return _then(_AppVersionConfigModel(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,storeUrl: null == storeUrl ? _self.storeUrl : storeUrl // ignore: cast_nullable_to_non_nullable
as String,updateTitle: null == updateTitle ? _self.updateTitle : updateTitle // ignore: cast_nullable_to_non_nullable
as String,updateMessage: null == updateMessage ? _self.updateMessage : updateMessage // ignore: cast_nullable_to_non_nullable
as String,isMaintenance: null == isMaintenance ? _self.isMaintenance : isMaintenance // ignore: cast_nullable_to_non_nullable
as bool,maintenanceMessage: null == maintenanceMessage ? _self.maintenanceMessage : maintenanceMessage // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
