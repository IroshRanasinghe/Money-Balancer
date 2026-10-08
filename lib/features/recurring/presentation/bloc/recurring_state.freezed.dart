// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecurringState {

 RecurringStatus get status; List<RecurringRule> get rules; String? get errorMessage; String? get infoMessage;/// Incremented on every successful save/delete so sheets can close.
 int get savedCount;/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
 int get paywallCount; PremiumFeature? get paywallFeature;
/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringStateCopyWith<RecurringState> get copyWith => _$RecurringStateCopyWithImpl<RecurringState>(this as RecurringState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.rules, rules)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage)&&(identical(other.savedCount, savedCount) || other.savedCount == savedCount)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(rules),errorMessage,infoMessage,savedCount,paywallCount,paywallFeature);

@override
String toString() {
  return 'RecurringState(status: $status, rules: $rules, errorMessage: $errorMessage, infoMessage: $infoMessage, savedCount: $savedCount, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class $RecurringStateCopyWith<$Res>  {
  factory $RecurringStateCopyWith(RecurringState value, $Res Function(RecurringState) _then) = _$RecurringStateCopyWithImpl;
@useResult
$Res call({
 RecurringStatus status, List<RecurringRule> rules, String? errorMessage, String? infoMessage, int savedCount, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class _$RecurringStateCopyWithImpl<$Res>
    implements $RecurringStateCopyWith<$Res> {
  _$RecurringStateCopyWithImpl(this._self, this._then);

  final RecurringState _self;
  final $Res Function(RecurringState) _then;

/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? rules = null,Object? errorMessage = freezed,Object? infoMessage = freezed,Object? savedCount = null,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecurringStatus,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<RecurringRule>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,savedCount: null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringState].
extension RecurringStatePatterns on RecurringState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringState value)  $default,){
final _that = this;
switch (_that) {
case _RecurringState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringState value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecurringStatus status,  List<RecurringRule> rules,  String? errorMessage,  String? infoMessage,  int savedCount,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringState() when $default != null:
return $default(_that.status,_that.rules,_that.errorMessage,_that.infoMessage,_that.savedCount,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecurringStatus status,  List<RecurringRule> rules,  String? errorMessage,  String? infoMessage,  int savedCount,  int paywallCount,  PremiumFeature? paywallFeature)  $default,) {final _that = this;
switch (_that) {
case _RecurringState():
return $default(_that.status,_that.rules,_that.errorMessage,_that.infoMessage,_that.savedCount,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecurringStatus status,  List<RecurringRule> rules,  String? errorMessage,  String? infoMessage,  int savedCount,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,) {final _that = this;
switch (_that) {
case _RecurringState() when $default != null:
return $default(_that.status,_that.rules,_that.errorMessage,_that.infoMessage,_that.savedCount,_that.paywallCount,_that.paywallFeature);case _:
  return null;

}
}

}

/// @nodoc


class _RecurringState implements RecurringState {
  const _RecurringState({this.status = RecurringStatus.initial, final  List<RecurringRule> rules = const <RecurringRule>[], this.errorMessage, this.infoMessage, this.savedCount = 0, this.paywallCount = 0, this.paywallFeature}): _rules = rules;
  

@override@JsonKey() final  RecurringStatus status;
 final  List<RecurringRule> _rules;
@override@JsonKey() List<RecurringRule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

@override final  String? errorMessage;
@override final  String? infoMessage;
/// Incremented on every successful save/delete so sheets can close.
@override@JsonKey() final  int savedCount;
/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
@override@JsonKey() final  int paywallCount;
@override final  PremiumFeature? paywallFeature;

/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringStateCopyWith<_RecurringState> get copyWith => __$RecurringStateCopyWithImpl<_RecurringState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._rules, _rules)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage)&&(identical(other.savedCount, savedCount) || other.savedCount == savedCount)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_rules),errorMessage,infoMessage,savedCount,paywallCount,paywallFeature);

@override
String toString() {
  return 'RecurringState(status: $status, rules: $rules, errorMessage: $errorMessage, infoMessage: $infoMessage, savedCount: $savedCount, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class _$RecurringStateCopyWith<$Res> implements $RecurringStateCopyWith<$Res> {
  factory _$RecurringStateCopyWith(_RecurringState value, $Res Function(_RecurringState) _then) = __$RecurringStateCopyWithImpl;
@override @useResult
$Res call({
 RecurringStatus status, List<RecurringRule> rules, String? errorMessage, String? infoMessage, int savedCount, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class __$RecurringStateCopyWithImpl<$Res>
    implements _$RecurringStateCopyWith<$Res> {
  __$RecurringStateCopyWithImpl(this._self, this._then);

  final _RecurringState _self;
  final $Res Function(_RecurringState) _then;

/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? rules = null,Object? errorMessage = freezed,Object? infoMessage = freezed,Object? savedCount = null,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_RecurringState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecurringStatus,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<RecurringRule>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,savedCount: null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}


}

// dart format on
