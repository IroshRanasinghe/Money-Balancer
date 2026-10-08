// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'income_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IncomeState {

 FormSubmissionStatus get status; String? get errorMessage;
/// Create a copy of IncomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomeStateCopyWith<IncomeState> get copyWith => _$IncomeStateCopyWithImpl<IncomeState>(this as IncomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomeState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage);

@override
String toString() {
  return 'IncomeState(status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $IncomeStateCopyWith<$Res>  {
  factory $IncomeStateCopyWith(IncomeState value, $Res Function(IncomeState) _then) = _$IncomeStateCopyWithImpl;
@useResult
$Res call({
 FormSubmissionStatus status, String? errorMessage
});




}
/// @nodoc
class _$IncomeStateCopyWithImpl<$Res>
    implements $IncomeStateCopyWith<$Res> {
  _$IncomeStateCopyWithImpl(this._self, this._then);

  final IncomeState _self;
  final $Res Function(IncomeState) _then;

/// Create a copy of IncomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FormSubmissionStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IncomeState].
extension IncomeStatePatterns on IncomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IncomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IncomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IncomeState value)  $default,){
final _that = this;
switch (_that) {
case _IncomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IncomeState value)?  $default,){
final _that = this;
switch (_that) {
case _IncomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FormSubmissionStatus status,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IncomeState() when $default != null:
return $default(_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FormSubmissionStatus status,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _IncomeState():
return $default(_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FormSubmissionStatus status,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _IncomeState() when $default != null:
return $default(_that.status,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _IncomeState implements IncomeState {
  const _IncomeState({this.status = FormSubmissionStatus.initial, this.errorMessage});
  

@override@JsonKey() final  FormSubmissionStatus status;
@override final  String? errorMessage;

/// Create a copy of IncomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncomeStateCopyWith<_IncomeState> get copyWith => __$IncomeStateCopyWithImpl<_IncomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IncomeState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage);

@override
String toString() {
  return 'IncomeState(status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$IncomeStateCopyWith<$Res> implements $IncomeStateCopyWith<$Res> {
  factory _$IncomeStateCopyWith(_IncomeState value, $Res Function(_IncomeState) _then) = __$IncomeStateCopyWithImpl;
@override @useResult
$Res call({
 FormSubmissionStatus status, String? errorMessage
});




}
/// @nodoc
class __$IncomeStateCopyWithImpl<$Res>
    implements _$IncomeStateCopyWith<$Res> {
  __$IncomeStateCopyWithImpl(this._self, this._then);

  final _IncomeState _self;
  final $Res Function(_IncomeState) _then;

/// Create a copy of IncomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_IncomeState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FormSubmissionStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
