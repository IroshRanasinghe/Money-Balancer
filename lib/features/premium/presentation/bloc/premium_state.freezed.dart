// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'premium_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PremiumState {

 PremiumStatus get status; List<PremiumPackage> get packages; PremiumBusy get busy; String? get message; bool get packagesLoading;
/// Create a copy of PremiumState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PremiumStateCopyWith<PremiumState> get copyWith => _$PremiumStateCopyWithImpl<PremiumState>(this as PremiumState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PremiumState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.packages, packages)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.message, message) || other.message == message)&&(identical(other.packagesLoading, packagesLoading) || other.packagesLoading == packagesLoading));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(packages),busy,message,packagesLoading);

@override
String toString() {
  return 'PremiumState(status: $status, packages: $packages, busy: $busy, message: $message, packagesLoading: $packagesLoading)';
}


}

/// @nodoc
abstract mixin class $PremiumStateCopyWith<$Res>  {
  factory $PremiumStateCopyWith(PremiumState value, $Res Function(PremiumState) _then) = _$PremiumStateCopyWithImpl;
@useResult
$Res call({
 PremiumStatus status, List<PremiumPackage> packages, PremiumBusy busy, String? message, bool packagesLoading
});


$PremiumStatusCopyWith<$Res> get status;

}
/// @nodoc
class _$PremiumStateCopyWithImpl<$Res>
    implements $PremiumStateCopyWith<$Res> {
  _$PremiumStateCopyWithImpl(this._self, this._then);

  final PremiumState _self;
  final $Res Function(PremiumState) _then;

/// Create a copy of PremiumState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? packages = null,Object? busy = null,Object? message = freezed,Object? packagesLoading = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PremiumStatus,packages: null == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as List<PremiumPackage>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as PremiumBusy,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,packagesLoading: null == packagesLoading ? _self.packagesLoading : packagesLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PremiumState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PremiumStatusCopyWith<$Res> get status {
  
  return $PremiumStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [PremiumState].
extension PremiumStatePatterns on PremiumState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PremiumState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PremiumState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PremiumState value)  $default,){
final _that = this;
switch (_that) {
case _PremiumState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PremiumState value)?  $default,){
final _that = this;
switch (_that) {
case _PremiumState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PremiumStatus status,  List<PremiumPackage> packages,  PremiumBusy busy,  String? message,  bool packagesLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PremiumState() when $default != null:
return $default(_that.status,_that.packages,_that.busy,_that.message,_that.packagesLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PremiumStatus status,  List<PremiumPackage> packages,  PremiumBusy busy,  String? message,  bool packagesLoading)  $default,) {final _that = this;
switch (_that) {
case _PremiumState():
return $default(_that.status,_that.packages,_that.busy,_that.message,_that.packagesLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PremiumStatus status,  List<PremiumPackage> packages,  PremiumBusy busy,  String? message,  bool packagesLoading)?  $default,) {final _that = this;
switch (_that) {
case _PremiumState() when $default != null:
return $default(_that.status,_that.packages,_that.busy,_that.message,_that.packagesLoading);case _:
  return null;

}
}

}

/// @nodoc


class _PremiumState implements PremiumState {
  const _PremiumState({this.status = const PremiumStatus(), final  List<PremiumPackage> packages = const <PremiumPackage>[], this.busy = PremiumBusy.none, this.message, this.packagesLoading = false}): _packages = packages;
  

@override@JsonKey() final  PremiumStatus status;
 final  List<PremiumPackage> _packages;
@override@JsonKey() List<PremiumPackage> get packages {
  if (_packages is EqualUnmodifiableListView) return _packages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packages);
}

@override@JsonKey() final  PremiumBusy busy;
@override final  String? message;
@override@JsonKey() final  bool packagesLoading;

/// Create a copy of PremiumState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PremiumStateCopyWith<_PremiumState> get copyWith => __$PremiumStateCopyWithImpl<_PremiumState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PremiumState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._packages, _packages)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.message, message) || other.message == message)&&(identical(other.packagesLoading, packagesLoading) || other.packagesLoading == packagesLoading));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_packages),busy,message,packagesLoading);

@override
String toString() {
  return 'PremiumState(status: $status, packages: $packages, busy: $busy, message: $message, packagesLoading: $packagesLoading)';
}


}

/// @nodoc
abstract mixin class _$PremiumStateCopyWith<$Res> implements $PremiumStateCopyWith<$Res> {
  factory _$PremiumStateCopyWith(_PremiumState value, $Res Function(_PremiumState) _then) = __$PremiumStateCopyWithImpl;
@override @useResult
$Res call({
 PremiumStatus status, List<PremiumPackage> packages, PremiumBusy busy, String? message, bool packagesLoading
});


@override $PremiumStatusCopyWith<$Res> get status;

}
/// @nodoc
class __$PremiumStateCopyWithImpl<$Res>
    implements _$PremiumStateCopyWith<$Res> {
  __$PremiumStateCopyWithImpl(this._self, this._then);

  final _PremiumState _self;
  final $Res Function(_PremiumState) _then;

/// Create a copy of PremiumState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? packages = null,Object? busy = null,Object? message = freezed,Object? packagesLoading = null,}) {
  return _then(_PremiumState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PremiumStatus,packages: null == packages ? _self._packages : packages // ignore: cast_nullable_to_non_nullable
as List<PremiumPackage>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as PremiumBusy,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,packagesLoading: null == packagesLoading ? _self.packagesLoading : packagesLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PremiumState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PremiumStatusCopyWith<$Res> get status {
  
  return $PremiumStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}

// dart format on
