// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goals_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoalsState {

 GoalsStatus get status; List<SavingsGoal> get goals; String? get errorMessage; String? get infoMessage;/// Incremented on every successful save/delete/adjust so sheets can close.
 int get savedCount;/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
 int get paywallCount; PremiumFeature? get paywallFeature;
/// Create a copy of GoalsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalsStateCopyWith<GoalsState> get copyWith => _$GoalsStateCopyWithImpl<GoalsState>(this as GoalsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.goals, goals)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage)&&(identical(other.savedCount, savedCount) || other.savedCount == savedCount)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(goals),errorMessage,infoMessage,savedCount,paywallCount,paywallFeature);

@override
String toString() {
  return 'GoalsState(status: $status, goals: $goals, errorMessage: $errorMessage, infoMessage: $infoMessage, savedCount: $savedCount, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class $GoalsStateCopyWith<$Res>  {
  factory $GoalsStateCopyWith(GoalsState value, $Res Function(GoalsState) _then) = _$GoalsStateCopyWithImpl;
@useResult
$Res call({
 GoalsStatus status, List<SavingsGoal> goals, String? errorMessage, String? infoMessage, int savedCount, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class _$GoalsStateCopyWithImpl<$Res>
    implements $GoalsStateCopyWith<$Res> {
  _$GoalsStateCopyWithImpl(this._self, this._then);

  final GoalsState _self;
  final $Res Function(GoalsState) _then;

/// Create a copy of GoalsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? goals = null,Object? errorMessage = freezed,Object? infoMessage = freezed,Object? savedCount = null,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GoalsStatus,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as List<SavingsGoal>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,savedCount: null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalsState].
extension GoalsStatePatterns on GoalsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalsState value)  $default,){
final _that = this;
switch (_that) {
case _GoalsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalsState value)?  $default,){
final _that = this;
switch (_that) {
case _GoalsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GoalsStatus status,  List<SavingsGoal> goals,  String? errorMessage,  String? infoMessage,  int savedCount,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalsState() when $default != null:
return $default(_that.status,_that.goals,_that.errorMessage,_that.infoMessage,_that.savedCount,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GoalsStatus status,  List<SavingsGoal> goals,  String? errorMessage,  String? infoMessage,  int savedCount,  int paywallCount,  PremiumFeature? paywallFeature)  $default,) {final _that = this;
switch (_that) {
case _GoalsState():
return $default(_that.status,_that.goals,_that.errorMessage,_that.infoMessage,_that.savedCount,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GoalsStatus status,  List<SavingsGoal> goals,  String? errorMessage,  String? infoMessage,  int savedCount,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,) {final _that = this;
switch (_that) {
case _GoalsState() when $default != null:
return $default(_that.status,_that.goals,_that.errorMessage,_that.infoMessage,_that.savedCount,_that.paywallCount,_that.paywallFeature);case _:
  return null;

}
}

}

/// @nodoc


class _GoalsState implements GoalsState {
  const _GoalsState({this.status = GoalsStatus.initial, final  List<SavingsGoal> goals = const <SavingsGoal>[], this.errorMessage, this.infoMessage, this.savedCount = 0, this.paywallCount = 0, this.paywallFeature}): _goals = goals;
  

@override@JsonKey() final  GoalsStatus status;
 final  List<SavingsGoal> _goals;
@override@JsonKey() List<SavingsGoal> get goals {
  if (_goals is EqualUnmodifiableListView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goals);
}

@override final  String? errorMessage;
@override final  String? infoMessage;
/// Incremented on every successful save/delete/adjust so sheets can close.
@override@JsonKey() final  int savedCount;
/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
@override@JsonKey() final  int paywallCount;
@override final  PremiumFeature? paywallFeature;

/// Create a copy of GoalsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalsStateCopyWith<_GoalsState> get copyWith => __$GoalsStateCopyWithImpl<_GoalsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._goals, _goals)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage)&&(identical(other.savedCount, savedCount) || other.savedCount == savedCount)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_goals),errorMessage,infoMessage,savedCount,paywallCount,paywallFeature);

@override
String toString() {
  return 'GoalsState(status: $status, goals: $goals, errorMessage: $errorMessage, infoMessage: $infoMessage, savedCount: $savedCount, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class _$GoalsStateCopyWith<$Res> implements $GoalsStateCopyWith<$Res> {
  factory _$GoalsStateCopyWith(_GoalsState value, $Res Function(_GoalsState) _then) = __$GoalsStateCopyWithImpl;
@override @useResult
$Res call({
 GoalsStatus status, List<SavingsGoal> goals, String? errorMessage, String? infoMessage, int savedCount, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class __$GoalsStateCopyWithImpl<$Res>
    implements _$GoalsStateCopyWith<$Res> {
  __$GoalsStateCopyWithImpl(this._self, this._then);

  final _GoalsState _self;
  final $Res Function(_GoalsState) _then;

/// Create a copy of GoalsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? goals = null,Object? errorMessage = freezed,Object? infoMessage = freezed,Object? savedCount = null,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_GoalsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GoalsStatus,goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as List<SavingsGoal>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,savedCount: null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}


}

// dart format on
