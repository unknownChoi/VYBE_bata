// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'terms_agreement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TermsAgreement {

/// 동의 여부. 선택 항목을 체크하지 않았으면 false 로 **기록한다** —
/// 필드를 빼면 '비동의'와 '아직 안 물어봤다'가 구분되지 않는다.
 bool get agreed;/// 동의한 문서의 개정일(`LegalDoc.version`). 읽을 문서가 없는 확인
/// 항목([kAgreementAge19])은 빈 문자열.
 String get version;/// 동의(또는 철회)한 시각. 서버 시각으로 쓴다.
 DateTime? get agreedAt;
/// Create a copy of TermsAgreement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TermsAgreementCopyWith<TermsAgreement> get copyWith => _$TermsAgreementCopyWithImpl<TermsAgreement>(this as TermsAgreement, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TermsAgreement&&(identical(other.agreed, agreed) || other.agreed == agreed)&&(identical(other.version, version) || other.version == version)&&(identical(other.agreedAt, agreedAt) || other.agreedAt == agreedAt));
}


@override
int get hashCode => Object.hash(runtimeType,agreed,version,agreedAt);

@override
String toString() {
  return 'TermsAgreement(agreed: $agreed, version: $version, agreedAt: $agreedAt)';
}


}

/// @nodoc
abstract mixin class $TermsAgreementCopyWith<$Res>  {
  factory $TermsAgreementCopyWith(TermsAgreement value, $Res Function(TermsAgreement) _then) = _$TermsAgreementCopyWithImpl;
@useResult
$Res call({
 bool agreed, String version, DateTime? agreedAt
});




}
/// @nodoc
class _$TermsAgreementCopyWithImpl<$Res>
    implements $TermsAgreementCopyWith<$Res> {
  _$TermsAgreementCopyWithImpl(this._self, this._then);

  final TermsAgreement _self;
  final $Res Function(TermsAgreement) _then;

/// Create a copy of TermsAgreement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? agreed = null,Object? version = null,Object? agreedAt = freezed,}) {
  return _then(_self.copyWith(
agreed: null == agreed ? _self.agreed : agreed // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,agreedAt: freezed == agreedAt ? _self.agreedAt : agreedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TermsAgreement].
extension TermsAgreementPatterns on TermsAgreement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TermsAgreement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TermsAgreement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TermsAgreement value)  $default,){
final _that = this;
switch (_that) {
case _TermsAgreement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TermsAgreement value)?  $default,){
final _that = this;
switch (_that) {
case _TermsAgreement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool agreed,  String version,  DateTime? agreedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TermsAgreement() when $default != null:
return $default(_that.agreed,_that.version,_that.agreedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool agreed,  String version,  DateTime? agreedAt)  $default,) {final _that = this;
switch (_that) {
case _TermsAgreement():
return $default(_that.agreed,_that.version,_that.agreedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool agreed,  String version,  DateTime? agreedAt)?  $default,) {final _that = this;
switch (_that) {
case _TermsAgreement() when $default != null:
return $default(_that.agreed,_that.version,_that.agreedAt);case _:
  return null;

}
}

}

/// @nodoc


class _TermsAgreement extends TermsAgreement {
  const _TermsAgreement({required this.agreed, required this.version, this.agreedAt}): super._();
  

/// 동의 여부. 선택 항목을 체크하지 않았으면 false 로 **기록한다** —
/// 필드를 빼면 '비동의'와 '아직 안 물어봤다'가 구분되지 않는다.
@override final  bool agreed;
/// 동의한 문서의 개정일(`LegalDoc.version`). 읽을 문서가 없는 확인
/// 항목([kAgreementAge19])은 빈 문자열.
@override final  String version;
/// 동의(또는 철회)한 시각. 서버 시각으로 쓴다.
@override final  DateTime? agreedAt;

/// Create a copy of TermsAgreement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TermsAgreementCopyWith<_TermsAgreement> get copyWith => __$TermsAgreementCopyWithImpl<_TermsAgreement>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TermsAgreement&&(identical(other.agreed, agreed) || other.agreed == agreed)&&(identical(other.version, version) || other.version == version)&&(identical(other.agreedAt, agreedAt) || other.agreedAt == agreedAt));
}


@override
int get hashCode => Object.hash(runtimeType,agreed,version,agreedAt);

@override
String toString() {
  return 'TermsAgreement(agreed: $agreed, version: $version, agreedAt: $agreedAt)';
}


}

/// @nodoc
abstract mixin class _$TermsAgreementCopyWith<$Res> implements $TermsAgreementCopyWith<$Res> {
  factory _$TermsAgreementCopyWith(_TermsAgreement value, $Res Function(_TermsAgreement) _then) = __$TermsAgreementCopyWithImpl;
@override @useResult
$Res call({
 bool agreed, String version, DateTime? agreedAt
});




}
/// @nodoc
class __$TermsAgreementCopyWithImpl<$Res>
    implements _$TermsAgreementCopyWith<$Res> {
  __$TermsAgreementCopyWithImpl(this._self, this._then);

  final _TermsAgreement _self;
  final $Res Function(_TermsAgreement) _then;

/// Create a copy of TermsAgreement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? agreed = null,Object? version = null,Object? agreedAt = freezed,}) {
  return _then(_TermsAgreement(
agreed: null == agreed ? _self.agreed : agreed // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,agreedAt: freezed == agreedAt ? _self.agreedAt : agreedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
