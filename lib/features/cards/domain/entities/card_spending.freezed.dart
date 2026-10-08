// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_spending.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CardSpending {

 BankCard get card; double get spent;
/// Create a copy of CardSpending
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardSpendingCopyWith<CardSpending> get copyWith => _$CardSpendingCopyWithImpl<CardSpending>(this as CardSpending, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardSpending&&(identical(other.card, card) || other.card == card)&&(identical(other.spent, spent) || other.spent == spent));
}


@override
int get hashCode => Object.hash(runtimeType,card,spent);

@override
String toString() {
  return 'CardSpending(card: $card, spent: $spent)';
}


}

/// @nodoc
abstract mixin class $CardSpendingCopyWith<$Res>  {
  factory $CardSpendingCopyWith(CardSpending value, $Res Function(CardSpending) _then) = _$CardSpendingCopyWithImpl;
@useResult
$Res call({
 BankCard card, double spent
});


$BankCardCopyWith<$Res> get card;

}
/// @nodoc
class _$CardSpendingCopyWithImpl<$Res>
    implements $CardSpendingCopyWith<$Res> {
  _$CardSpendingCopyWithImpl(this._self, this._then);

  final CardSpending _self;
  final $Res Function(CardSpending) _then;

/// Create a copy of CardSpending
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? card = null,Object? spent = null,}) {
  return _then(_self.copyWith(
card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as BankCard,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of CardSpending
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankCardCopyWith<$Res> get card {
  
  return $BankCardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}


/// Adds pattern-matching-related methods to [CardSpending].
extension CardSpendingPatterns on CardSpending {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardSpending value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardSpending() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardSpending value)  $default,){
final _that = this;
switch (_that) {
case _CardSpending():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardSpending value)?  $default,){
final _that = this;
switch (_that) {
case _CardSpending() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BankCard card,  double spent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardSpending() when $default != null:
return $default(_that.card,_that.spent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BankCard card,  double spent)  $default,) {final _that = this;
switch (_that) {
case _CardSpending():
return $default(_that.card,_that.spent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BankCard card,  double spent)?  $default,) {final _that = this;
switch (_that) {
case _CardSpending() when $default != null:
return $default(_that.card,_that.spent);case _:
  return null;

}
}

}

/// @nodoc


class _CardSpending implements CardSpending {
  const _CardSpending({required this.card, required this.spent});
  

@override final  BankCard card;
@override final  double spent;

/// Create a copy of CardSpending
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardSpendingCopyWith<_CardSpending> get copyWith => __$CardSpendingCopyWithImpl<_CardSpending>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardSpending&&(identical(other.card, card) || other.card == card)&&(identical(other.spent, spent) || other.spent == spent));
}


@override
int get hashCode => Object.hash(runtimeType,card,spent);

@override
String toString() {
  return 'CardSpending(card: $card, spent: $spent)';
}


}

/// @nodoc
abstract mixin class _$CardSpendingCopyWith<$Res> implements $CardSpendingCopyWith<$Res> {
  factory _$CardSpendingCopyWith(_CardSpending value, $Res Function(_CardSpending) _then) = __$CardSpendingCopyWithImpl;
@override @useResult
$Res call({
 BankCard card, double spent
});


@override $BankCardCopyWith<$Res> get card;

}
/// @nodoc
class __$CardSpendingCopyWithImpl<$Res>
    implements _$CardSpendingCopyWith<$Res> {
  __$CardSpendingCopyWithImpl(this._self, this._then);

  final _CardSpending _self;
  final $Res Function(_CardSpending) _then;

/// Create a copy of CardSpending
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? card = null,Object? spent = null,}) {
  return _then(_CardSpending(
card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as BankCard,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of CardSpending
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankCardCopyWith<$Res> get card {
  
  return $BankCardCopyWith<$Res>(_self.card, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}

// dart format on
