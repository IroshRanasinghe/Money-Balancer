// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cards_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CardsState {

 CardsStatus get status; List<CardSpending> get items; String? get errorMessage;/// Set only while the reveal dialog is open; cleared on dismiss.
 String? get revealedCardId;/// SENSITIVE full card number. Never log this state (a BlocObserver
/// would print it).
 String? get revealedNumber;/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
 int get paywallCount; PremiumFeature? get paywallFeature;
/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardsStateCopyWith<CardsState> get copyWith => _$CardsStateCopyWithImpl<CardsState>(this as CardsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.revealedCardId, revealedCardId) || other.revealedCardId == revealedCardId)&&(identical(other.revealedNumber, revealedNumber) || other.revealedNumber == revealedNumber)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(items),errorMessage,revealedCardId,revealedNumber,paywallCount,paywallFeature);

@override
String toString() {
  return 'CardsState(status: $status, items: $items, errorMessage: $errorMessage, revealedCardId: $revealedCardId, revealedNumber: $revealedNumber, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class $CardsStateCopyWith<$Res>  {
  factory $CardsStateCopyWith(CardsState value, $Res Function(CardsState) _then) = _$CardsStateCopyWithImpl;
@useResult
$Res call({
 CardsStatus status, List<CardSpending> items, String? errorMessage, String? revealedCardId, String? revealedNumber, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class _$CardsStateCopyWithImpl<$Res>
    implements $CardsStateCopyWith<$Res> {
  _$CardsStateCopyWithImpl(this._self, this._then);

  final CardsState _self;
  final $Res Function(CardsState) _then;

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? items = null,Object? errorMessage = freezed,Object? revealedCardId = freezed,Object? revealedNumber = freezed,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardsStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CardSpending>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,revealedCardId: freezed == revealedCardId ? _self.revealedCardId : revealedCardId // ignore: cast_nullable_to_non_nullable
as String?,revealedNumber: freezed == revealedNumber ? _self.revealedNumber : revealedNumber // ignore: cast_nullable_to_non_nullable
as String?,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardsState].
extension CardsStatePatterns on CardsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardsState value)  $default,){
final _that = this;
switch (_that) {
case _CardsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardsState value)?  $default,){
final _that = this;
switch (_that) {
case _CardsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CardsStatus status,  List<CardSpending> items,  String? errorMessage,  String? revealedCardId,  String? revealedNumber,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardsState() when $default != null:
return $default(_that.status,_that.items,_that.errorMessage,_that.revealedCardId,_that.revealedNumber,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CardsStatus status,  List<CardSpending> items,  String? errorMessage,  String? revealedCardId,  String? revealedNumber,  int paywallCount,  PremiumFeature? paywallFeature)  $default,) {final _that = this;
switch (_that) {
case _CardsState():
return $default(_that.status,_that.items,_that.errorMessage,_that.revealedCardId,_that.revealedNumber,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CardsStatus status,  List<CardSpending> items,  String? errorMessage,  String? revealedCardId,  String? revealedNumber,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,) {final _that = this;
switch (_that) {
case _CardsState() when $default != null:
return $default(_that.status,_that.items,_that.errorMessage,_that.revealedCardId,_that.revealedNumber,_that.paywallCount,_that.paywallFeature);case _:
  return null;

}
}

}

/// @nodoc


class _CardsState implements CardsState {
  const _CardsState({this.status = CardsStatus.initial, final  List<CardSpending> items = const <CardSpending>[], this.errorMessage, this.revealedCardId, this.revealedNumber, this.paywallCount = 0, this.paywallFeature}): _items = items;
  

@override@JsonKey() final  CardsStatus status;
 final  List<CardSpending> _items;
@override@JsonKey() List<CardSpending> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? errorMessage;
/// Set only while the reveal dialog is open; cleared on dismiss.
@override final  String? revealedCardId;
/// SENSITIVE full card number. Never log this state (a BlocObserver
/// would print it).
@override final  String? revealedNumber;
/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
@override@JsonKey() final  int paywallCount;
@override final  PremiumFeature? paywallFeature;

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardsStateCopyWith<_CardsState> get copyWith => __$CardsStateCopyWithImpl<_CardsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.revealedCardId, revealedCardId) || other.revealedCardId == revealedCardId)&&(identical(other.revealedNumber, revealedNumber) || other.revealedNumber == revealedNumber)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_items),errorMessage,revealedCardId,revealedNumber,paywallCount,paywallFeature);

@override
String toString() {
  return 'CardsState(status: $status, items: $items, errorMessage: $errorMessage, revealedCardId: $revealedCardId, revealedNumber: $revealedNumber, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class _$CardsStateCopyWith<$Res> implements $CardsStateCopyWith<$Res> {
  factory _$CardsStateCopyWith(_CardsState value, $Res Function(_CardsState) _then) = __$CardsStateCopyWithImpl;
@override @useResult
$Res call({
 CardsStatus status, List<CardSpending> items, String? errorMessage, String? revealedCardId, String? revealedNumber, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class __$CardsStateCopyWithImpl<$Res>
    implements _$CardsStateCopyWith<$Res> {
  __$CardsStateCopyWithImpl(this._self, this._then);

  final _CardsState _self;
  final $Res Function(_CardsState) _then;

/// Create a copy of CardsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? items = null,Object? errorMessage = freezed,Object? revealedCardId = freezed,Object? revealedNumber = freezed,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_CardsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardsStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CardSpending>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,revealedCardId: freezed == revealedCardId ? _self.revealedCardId : revealedCardId // ignore: cast_nullable_to_non_nullable
as String?,revealedNumber: freezed == revealedNumber ? _self.revealedNumber : revealedNumber // ignore: cast_nullable_to_non_nullable
as String?,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}


}

// dart format on
