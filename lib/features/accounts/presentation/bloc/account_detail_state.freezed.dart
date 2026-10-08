// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountDetailState {

 AccountDetailStatus get status; AccountBalance? get balance; List<AccountActivity> get activity; String? get errorMessage;
/// Create a copy of AccountDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountDetailStateCopyWith<AccountDetailState> get copyWith => _$AccountDetailStateCopyWithImpl<AccountDetailState>(this as AccountDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountDetailState&&(identical(other.status, status) || other.status == status)&&(identical(other.balance, balance) || other.balance == balance)&&const DeepCollectionEquality().equals(other.activity, activity)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,balance,const DeepCollectionEquality().hash(activity),errorMessage);

@override
String toString() {
  return 'AccountDetailState(status: $status, balance: $balance, activity: $activity, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AccountDetailStateCopyWith<$Res>  {
  factory $AccountDetailStateCopyWith(AccountDetailState value, $Res Function(AccountDetailState) _then) = _$AccountDetailStateCopyWithImpl;
@useResult
$Res call({
 AccountDetailStatus status, AccountBalance? balance, List<AccountActivity> activity, String? errorMessage
});


$AccountBalanceCopyWith<$Res>? get balance;

}
/// @nodoc
class _$AccountDetailStateCopyWithImpl<$Res>
    implements $AccountDetailStateCopyWith<$Res> {
  _$AccountDetailStateCopyWithImpl(this._self, this._then);

  final AccountDetailState _self;
  final $Res Function(AccountDetailState) _then;

/// Create a copy of AccountDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? balance = freezed,Object? activity = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountDetailStatus,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as AccountBalance?,activity: null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as List<AccountActivity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AccountDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountBalanceCopyWith<$Res>? get balance {
    if (_self.balance == null) {
    return null;
  }

  return $AccountBalanceCopyWith<$Res>(_self.balance!, (value) {
    return _then(_self.copyWith(balance: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountDetailState].
extension AccountDetailStatePatterns on AccountDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountDetailState value)  $default,){
final _that = this;
switch (_that) {
case _AccountDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _AccountDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccountDetailStatus status,  AccountBalance? balance,  List<AccountActivity> activity,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountDetailState() when $default != null:
return $default(_that.status,_that.balance,_that.activity,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccountDetailStatus status,  AccountBalance? balance,  List<AccountActivity> activity,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AccountDetailState():
return $default(_that.status,_that.balance,_that.activity,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccountDetailStatus status,  AccountBalance? balance,  List<AccountActivity> activity,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AccountDetailState() when $default != null:
return $default(_that.status,_that.balance,_that.activity,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _AccountDetailState implements AccountDetailState {
  const _AccountDetailState({this.status = AccountDetailStatus.initial, this.balance, final  List<AccountActivity> activity = const <AccountActivity>[], this.errorMessage}): _activity = activity;
  

@override@JsonKey() final  AccountDetailStatus status;
@override final  AccountBalance? balance;
 final  List<AccountActivity> _activity;
@override@JsonKey() List<AccountActivity> get activity {
  if (_activity is EqualUnmodifiableListView) return _activity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activity);
}

@override final  String? errorMessage;

/// Create a copy of AccountDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountDetailStateCopyWith<_AccountDetailState> get copyWith => __$AccountDetailStateCopyWithImpl<_AccountDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountDetailState&&(identical(other.status, status) || other.status == status)&&(identical(other.balance, balance) || other.balance == balance)&&const DeepCollectionEquality().equals(other._activity, _activity)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,balance,const DeepCollectionEquality().hash(_activity),errorMessage);

@override
String toString() {
  return 'AccountDetailState(status: $status, balance: $balance, activity: $activity, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AccountDetailStateCopyWith<$Res> implements $AccountDetailStateCopyWith<$Res> {
  factory _$AccountDetailStateCopyWith(_AccountDetailState value, $Res Function(_AccountDetailState) _then) = __$AccountDetailStateCopyWithImpl;
@override @useResult
$Res call({
 AccountDetailStatus status, AccountBalance? balance, List<AccountActivity> activity, String? errorMessage
});


@override $AccountBalanceCopyWith<$Res>? get balance;

}
/// @nodoc
class __$AccountDetailStateCopyWithImpl<$Res>
    implements _$AccountDetailStateCopyWith<$Res> {
  __$AccountDetailStateCopyWithImpl(this._self, this._then);

  final _AccountDetailState _self;
  final $Res Function(_AccountDetailState) _then;

/// Create a copy of AccountDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? balance = freezed,Object? activity = null,Object? errorMessage = freezed,}) {
  return _then(_AccountDetailState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountDetailStatus,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as AccountBalance?,activity: null == activity ? _self._activity : activity // ignore: cast_nullable_to_non_nullable
as List<AccountActivity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AccountDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountBalanceCopyWith<$Res>? get balance {
    if (_self.balance == null) {
    return null;
  }

  return $AccountBalanceCopyWith<$Res>(_self.balance!, (value) {
    return _then(_self.copyWith(balance: value));
  });
}
}

// dart format on
