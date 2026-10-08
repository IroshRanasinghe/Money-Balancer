// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accounts_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountsState {

 AccountsStatus get status; List<AccountBalance> get items; String? get errorMessage;/// Incremented on every successful save/delete so sheets can close.
 int get savedCount;/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
 int get paywallCount; PremiumFeature? get paywallFeature;
/// Create a copy of AccountsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountsStateCopyWith<AccountsState> get copyWith => _$AccountsStateCopyWithImpl<AccountsState>(this as AccountsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.savedCount, savedCount) || other.savedCount == savedCount)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(items),errorMessage,savedCount,paywallCount,paywallFeature);

@override
String toString() {
  return 'AccountsState(status: $status, items: $items, errorMessage: $errorMessage, savedCount: $savedCount, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class $AccountsStateCopyWith<$Res>  {
  factory $AccountsStateCopyWith(AccountsState value, $Res Function(AccountsState) _then) = _$AccountsStateCopyWithImpl;
@useResult
$Res call({
 AccountsStatus status, List<AccountBalance> items, String? errorMessage, int savedCount, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class _$AccountsStateCopyWithImpl<$Res>
    implements $AccountsStateCopyWith<$Res> {
  _$AccountsStateCopyWithImpl(this._self, this._then);

  final AccountsState _self;
  final $Res Function(AccountsState) _then;

/// Create a copy of AccountsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? items = null,Object? errorMessage = freezed,Object? savedCount = null,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountsStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AccountBalance>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,savedCount: null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountsState].
extension AccountsStatePatterns on AccountsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountsState value)  $default,){
final _that = this;
switch (_that) {
case _AccountsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountsState value)?  $default,){
final _that = this;
switch (_that) {
case _AccountsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccountsStatus status,  List<AccountBalance> items,  String? errorMessage,  int savedCount,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountsState() when $default != null:
return $default(_that.status,_that.items,_that.errorMessage,_that.savedCount,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccountsStatus status,  List<AccountBalance> items,  String? errorMessage,  int savedCount,  int paywallCount,  PremiumFeature? paywallFeature)  $default,) {final _that = this;
switch (_that) {
case _AccountsState():
return $default(_that.status,_that.items,_that.errorMessage,_that.savedCount,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccountsStatus status,  List<AccountBalance> items,  String? errorMessage,  int savedCount,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,) {final _that = this;
switch (_that) {
case _AccountsState() when $default != null:
return $default(_that.status,_that.items,_that.errorMessage,_that.savedCount,_that.paywallCount,_that.paywallFeature);case _:
  return null;

}
}

}

/// @nodoc


class _AccountsState implements AccountsState {
  const _AccountsState({this.status = AccountsStatus.initial, final  List<AccountBalance> items = const <AccountBalance>[], this.errorMessage, this.savedCount = 0, this.paywallCount = 0, this.paywallFeature}): _items = items;
  

@override@JsonKey() final  AccountsStatus status;
 final  List<AccountBalance> _items;
@override@JsonKey() List<AccountBalance> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? errorMessage;
/// Incremented on every successful save/delete so sheets can close.
@override@JsonKey() final  int savedCount;
/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
@override@JsonKey() final  int paywallCount;
@override final  PremiumFeature? paywallFeature;

/// Create a copy of AccountsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountsStateCopyWith<_AccountsState> get copyWith => __$AccountsStateCopyWithImpl<_AccountsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.savedCount, savedCount) || other.savedCount == savedCount)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_items),errorMessage,savedCount,paywallCount,paywallFeature);

@override
String toString() {
  return 'AccountsState(status: $status, items: $items, errorMessage: $errorMessage, savedCount: $savedCount, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class _$AccountsStateCopyWith<$Res> implements $AccountsStateCopyWith<$Res> {
  factory _$AccountsStateCopyWith(_AccountsState value, $Res Function(_AccountsState) _then) = __$AccountsStateCopyWithImpl;
@override @useResult
$Res call({
 AccountsStatus status, List<AccountBalance> items, String? errorMessage, int savedCount, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class __$AccountsStateCopyWithImpl<$Res>
    implements _$AccountsStateCopyWith<$Res> {
  __$AccountsStateCopyWithImpl(this._self, this._then);

  final _AccountsState _self;
  final $Res Function(_AccountsState) _then;

/// Create a copy of AccountsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? items = null,Object? errorMessage = freezed,Object? savedCount = null,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_AccountsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountsStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AccountBalance>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,savedCount: null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}


}

// dart format on
