// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BackupState {

 BackupStatus get status; String? get message; int get restoredCount;/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
 int get paywallCount; PremiumFeature? get paywallFeature;
/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupStateCopyWith<BackupState> get copyWith => _$BackupStateCopyWithImpl<BackupState>(this as BackupState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupState&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.restoredCount, restoredCount) || other.restoredCount == restoredCount)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,status,message,restoredCount,paywallCount,paywallFeature);

@override
String toString() {
  return 'BackupState(status: $status, message: $message, restoredCount: $restoredCount, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class $BackupStateCopyWith<$Res>  {
  factory $BackupStateCopyWith(BackupState value, $Res Function(BackupState) _then) = _$BackupStateCopyWithImpl;
@useResult
$Res call({
 BackupStatus status, String? message, int restoredCount, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class _$BackupStateCopyWithImpl<$Res>
    implements $BackupStateCopyWith<$Res> {
  _$BackupStateCopyWithImpl(this._self, this._then);

  final BackupState _self;
  final $Res Function(BackupState) _then;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? message = freezed,Object? restoredCount = null,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BackupStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,restoredCount: null == restoredCount ? _self.restoredCount : restoredCount // ignore: cast_nullable_to_non_nullable
as int,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}

}


/// Adds pattern-matching-related methods to [BackupState].
extension BackupStatePatterns on BackupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackupState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackupState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackupState value)  $default,){
final _that = this;
switch (_that) {
case _BackupState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackupState value)?  $default,){
final _that = this;
switch (_that) {
case _BackupState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BackupStatus status,  String? message,  int restoredCount,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackupState() when $default != null:
return $default(_that.status,_that.message,_that.restoredCount,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BackupStatus status,  String? message,  int restoredCount,  int paywallCount,  PremiumFeature? paywallFeature)  $default,) {final _that = this;
switch (_that) {
case _BackupState():
return $default(_that.status,_that.message,_that.restoredCount,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BackupStatus status,  String? message,  int restoredCount,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,) {final _that = this;
switch (_that) {
case _BackupState() when $default != null:
return $default(_that.status,_that.message,_that.restoredCount,_that.paywallCount,_that.paywallFeature);case _:
  return null;

}
}

}

/// @nodoc


class _BackupState implements BackupState {
  const _BackupState({this.status = BackupStatus.idle, this.message, this.restoredCount = 0, this.paywallCount = 0, this.paywallFeature});
  

@override@JsonKey() final  BackupStatus status;
@override final  String? message;
@override@JsonKey() final  int restoredCount;
/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
@override@JsonKey() final  int paywallCount;
@override final  PremiumFeature? paywallFeature;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackupStateCopyWith<_BackupState> get copyWith => __$BackupStateCopyWithImpl<_BackupState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackupState&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.restoredCount, restoredCount) || other.restoredCount == restoredCount)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,status,message,restoredCount,paywallCount,paywallFeature);

@override
String toString() {
  return 'BackupState(status: $status, message: $message, restoredCount: $restoredCount, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class _$BackupStateCopyWith<$Res> implements $BackupStateCopyWith<$Res> {
  factory _$BackupStateCopyWith(_BackupState value, $Res Function(_BackupState) _then) = __$BackupStateCopyWithImpl;
@override @useResult
$Res call({
 BackupStatus status, String? message, int restoredCount, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class __$BackupStateCopyWithImpl<$Res>
    implements _$BackupStateCopyWith<$Res> {
  __$BackupStateCopyWithImpl(this._self, this._then);

  final _BackupState _self;
  final $Res Function(_BackupState) _then;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? message = freezed,Object? restoredCount = null,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_BackupState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BackupStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,restoredCount: null == restoredCount ? _self.restoredCount : restoredCount // ignore: cast_nullable_to_non_nullable
as int,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}


}

// dart format on
