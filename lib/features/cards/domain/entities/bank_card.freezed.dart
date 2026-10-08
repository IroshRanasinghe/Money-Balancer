// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bank_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BankCard {

 String get id; String get nickname; String get bankName; CardType get type; CardNetwork get network; String get last4; int get expiryMonth; int get expiryYear; int get colorValue; DateTime get createdAt;
/// Create a copy of BankCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankCardCopyWith<BankCard> get copyWith => _$BankCardCopyWithImpl<BankCard>(this as BankCard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankCard&&(identical(other.id, id) || other.id == id)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.type, type) || other.type == type)&&(identical(other.network, network) || other.network == network)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.expiryMonth, expiryMonth) || other.expiryMonth == expiryMonth)&&(identical(other.expiryYear, expiryYear) || other.expiryYear == expiryYear)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,nickname,bankName,type,network,last4,expiryMonth,expiryYear,colorValue,createdAt);

@override
String toString() {
  return 'BankCard(id: $id, nickname: $nickname, bankName: $bankName, type: $type, network: $network, last4: $last4, expiryMonth: $expiryMonth, expiryYear: $expiryYear, colorValue: $colorValue, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BankCardCopyWith<$Res>  {
  factory $BankCardCopyWith(BankCard value, $Res Function(BankCard) _then) = _$BankCardCopyWithImpl;
@useResult
$Res call({
 String id, String nickname, String bankName, CardType type, CardNetwork network, String last4, int expiryMonth, int expiryYear, int colorValue, DateTime createdAt
});




}
/// @nodoc
class _$BankCardCopyWithImpl<$Res>
    implements $BankCardCopyWith<$Res> {
  _$BankCardCopyWithImpl(this._self, this._then);

  final BankCard _self;
  final $Res Function(BankCard) _then;

/// Create a copy of BankCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nickname = null,Object? bankName = null,Object? type = null,Object? network = null,Object? last4 = null,Object? expiryMonth = null,Object? expiryYear = null,Object? colorValue = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,bankName: null == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CardType,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as CardNetwork,last4: null == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String,expiryMonth: null == expiryMonth ? _self.expiryMonth : expiryMonth // ignore: cast_nullable_to_non_nullable
as int,expiryYear: null == expiryYear ? _self.expiryYear : expiryYear // ignore: cast_nullable_to_non_nullable
as int,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BankCard].
extension BankCardPatterns on BankCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankCard value)  $default,){
final _that = this;
switch (_that) {
case _BankCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankCard value)?  $default,){
final _that = this;
switch (_that) {
case _BankCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nickname,  String bankName,  CardType type,  CardNetwork network,  String last4,  int expiryMonth,  int expiryYear,  int colorValue,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankCard() when $default != null:
return $default(_that.id,_that.nickname,_that.bankName,_that.type,_that.network,_that.last4,_that.expiryMonth,_that.expiryYear,_that.colorValue,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nickname,  String bankName,  CardType type,  CardNetwork network,  String last4,  int expiryMonth,  int expiryYear,  int colorValue,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BankCard():
return $default(_that.id,_that.nickname,_that.bankName,_that.type,_that.network,_that.last4,_that.expiryMonth,_that.expiryYear,_that.colorValue,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nickname,  String bankName,  CardType type,  CardNetwork network,  String last4,  int expiryMonth,  int expiryYear,  int colorValue,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BankCard() when $default != null:
return $default(_that.id,_that.nickname,_that.bankName,_that.type,_that.network,_that.last4,_that.expiryMonth,_that.expiryYear,_that.colorValue,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _BankCard extends BankCard {
  const _BankCard({required this.id, required this.nickname, required this.bankName, required this.type, required this.network, required this.last4, required this.expiryMonth, required this.expiryYear, required this.colorValue, required this.createdAt}): super._();
  

@override final  String id;
@override final  String nickname;
@override final  String bankName;
@override final  CardType type;
@override final  CardNetwork network;
@override final  String last4;
@override final  int expiryMonth;
@override final  int expiryYear;
@override final  int colorValue;
@override final  DateTime createdAt;

/// Create a copy of BankCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankCardCopyWith<_BankCard> get copyWith => __$BankCardCopyWithImpl<_BankCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankCard&&(identical(other.id, id) || other.id == id)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.type, type) || other.type == type)&&(identical(other.network, network) || other.network == network)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.expiryMonth, expiryMonth) || other.expiryMonth == expiryMonth)&&(identical(other.expiryYear, expiryYear) || other.expiryYear == expiryYear)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,nickname,bankName,type,network,last4,expiryMonth,expiryYear,colorValue,createdAt);

@override
String toString() {
  return 'BankCard(id: $id, nickname: $nickname, bankName: $bankName, type: $type, network: $network, last4: $last4, expiryMonth: $expiryMonth, expiryYear: $expiryYear, colorValue: $colorValue, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BankCardCopyWith<$Res> implements $BankCardCopyWith<$Res> {
  factory _$BankCardCopyWith(_BankCard value, $Res Function(_BankCard) _then) = __$BankCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String nickname, String bankName, CardType type, CardNetwork network, String last4, int expiryMonth, int expiryYear, int colorValue, DateTime createdAt
});




}
/// @nodoc
class __$BankCardCopyWithImpl<$Res>
    implements _$BankCardCopyWith<$Res> {
  __$BankCardCopyWithImpl(this._self, this._then);

  final _BankCard _self;
  final $Res Function(_BankCard) _then;

/// Create a copy of BankCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nickname = null,Object? bankName = null,Object? type = null,Object? network = null,Object? last4 = null,Object? expiryMonth = null,Object? expiryYear = null,Object? colorValue = null,Object? createdAt = null,}) {
  return _then(_BankCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,bankName: null == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CardType,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as CardNetwork,last4: null == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String,expiryMonth: null == expiryMonth ? _self.expiryMonth : expiryMonth // ignore: cast_nullable_to_non_nullable
as int,expiryYear: null == expiryYear ? _self.expiryYear : expiryYear // ignore: cast_nullable_to_non_nullable
as int,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
