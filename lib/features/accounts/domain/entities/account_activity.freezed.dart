// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountActivity {

 DateTime get date; DateTime get createdAt; String get title; double get signedAmount; Transaction? get transaction; Transfer? get transfer;
/// Create a copy of AccountActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountActivityCopyWith<AccountActivity> get copyWith => _$AccountActivityCopyWithImpl<AccountActivity>(this as AccountActivity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountActivity&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.signedAmount, signedAmount) || other.signedAmount == signedAmount)&&(identical(other.transaction, transaction) || other.transaction == transaction)&&(identical(other.transfer, transfer) || other.transfer == transfer));
}


@override
int get hashCode => Object.hash(runtimeType,date,createdAt,title,signedAmount,transaction,transfer);

@override
String toString() {
  return 'AccountActivity(date: $date, createdAt: $createdAt, title: $title, signedAmount: $signedAmount, transaction: $transaction, transfer: $transfer)';
}


}

/// @nodoc
abstract mixin class $AccountActivityCopyWith<$Res>  {
  factory $AccountActivityCopyWith(AccountActivity value, $Res Function(AccountActivity) _then) = _$AccountActivityCopyWithImpl;
@useResult
$Res call({
 DateTime date, DateTime createdAt, String title, double signedAmount, Transaction? transaction, Transfer? transfer
});


$TransactionCopyWith<$Res>? get transaction;$TransferCopyWith<$Res>? get transfer;

}
/// @nodoc
class _$AccountActivityCopyWithImpl<$Res>
    implements $AccountActivityCopyWith<$Res> {
  _$AccountActivityCopyWithImpl(this._self, this._then);

  final AccountActivity _self;
  final $Res Function(AccountActivity) _then;

/// Create a copy of AccountActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? createdAt = null,Object? title = null,Object? signedAmount = null,Object? transaction = freezed,Object? transfer = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,signedAmount: null == signedAmount ? _self.signedAmount : signedAmount // ignore: cast_nullable_to_non_nullable
as double,transaction: freezed == transaction ? _self.transaction : transaction // ignore: cast_nullable_to_non_nullable
as Transaction?,transfer: freezed == transfer ? _self.transfer : transfer // ignore: cast_nullable_to_non_nullable
as Transfer?,
  ));
}
/// Create a copy of AccountActivity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionCopyWith<$Res>? get transaction {
    if (_self.transaction == null) {
    return null;
  }

  return $TransactionCopyWith<$Res>(_self.transaction!, (value) {
    return _then(_self.copyWith(transaction: value));
  });
}/// Create a copy of AccountActivity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransferCopyWith<$Res>? get transfer {
    if (_self.transfer == null) {
    return null;
  }

  return $TransferCopyWith<$Res>(_self.transfer!, (value) {
    return _then(_self.copyWith(transfer: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountActivity].
extension AccountActivityPatterns on AccountActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountActivity value)  $default,){
final _that = this;
switch (_that) {
case _AccountActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountActivity value)?  $default,){
final _that = this;
switch (_that) {
case _AccountActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  DateTime createdAt,  String title,  double signedAmount,  Transaction? transaction,  Transfer? transfer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountActivity() when $default != null:
return $default(_that.date,_that.createdAt,_that.title,_that.signedAmount,_that.transaction,_that.transfer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  DateTime createdAt,  String title,  double signedAmount,  Transaction? transaction,  Transfer? transfer)  $default,) {final _that = this;
switch (_that) {
case _AccountActivity():
return $default(_that.date,_that.createdAt,_that.title,_that.signedAmount,_that.transaction,_that.transfer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  DateTime createdAt,  String title,  double signedAmount,  Transaction? transaction,  Transfer? transfer)?  $default,) {final _that = this;
switch (_that) {
case _AccountActivity() when $default != null:
return $default(_that.date,_that.createdAt,_that.title,_that.signedAmount,_that.transaction,_that.transfer);case _:
  return null;

}
}

}

/// @nodoc


class _AccountActivity implements AccountActivity {
  const _AccountActivity({required this.date, required this.createdAt, required this.title, required this.signedAmount, this.transaction, this.transfer});
  

@override final  DateTime date;
@override final  DateTime createdAt;
@override final  String title;
@override final  double signedAmount;
@override final  Transaction? transaction;
@override final  Transfer? transfer;

/// Create a copy of AccountActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountActivityCopyWith<_AccountActivity> get copyWith => __$AccountActivityCopyWithImpl<_AccountActivity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountActivity&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.signedAmount, signedAmount) || other.signedAmount == signedAmount)&&(identical(other.transaction, transaction) || other.transaction == transaction)&&(identical(other.transfer, transfer) || other.transfer == transfer));
}


@override
int get hashCode => Object.hash(runtimeType,date,createdAt,title,signedAmount,transaction,transfer);

@override
String toString() {
  return 'AccountActivity(date: $date, createdAt: $createdAt, title: $title, signedAmount: $signedAmount, transaction: $transaction, transfer: $transfer)';
}


}

/// @nodoc
abstract mixin class _$AccountActivityCopyWith<$Res> implements $AccountActivityCopyWith<$Res> {
  factory _$AccountActivityCopyWith(_AccountActivity value, $Res Function(_AccountActivity) _then) = __$AccountActivityCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, DateTime createdAt, String title, double signedAmount, Transaction? transaction, Transfer? transfer
});


@override $TransactionCopyWith<$Res>? get transaction;@override $TransferCopyWith<$Res>? get transfer;

}
/// @nodoc
class __$AccountActivityCopyWithImpl<$Res>
    implements _$AccountActivityCopyWith<$Res> {
  __$AccountActivityCopyWithImpl(this._self, this._then);

  final _AccountActivity _self;
  final $Res Function(_AccountActivity) _then;

/// Create a copy of AccountActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? createdAt = null,Object? title = null,Object? signedAmount = null,Object? transaction = freezed,Object? transfer = freezed,}) {
  return _then(_AccountActivity(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,signedAmount: null == signedAmount ? _self.signedAmount : signedAmount // ignore: cast_nullable_to_non_nullable
as double,transaction: freezed == transaction ? _self.transaction : transaction // ignore: cast_nullable_to_non_nullable
as Transaction?,transfer: freezed == transfer ? _self.transfer : transfer // ignore: cast_nullable_to_non_nullable
as Transfer?,
  ));
}

/// Create a copy of AccountActivity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionCopyWith<$Res>? get transaction {
    if (_self.transaction == null) {
    return null;
  }

  return $TransactionCopyWith<$Res>(_self.transaction!, (value) {
    return _then(_self.copyWith(transaction: value));
  });
}/// Create a copy of AccountActivity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransferCopyWith<$Res>? get transfer {
    if (_self.transfer == null) {
    return null;
  }

  return $TransferCopyWith<$Res>(_self.transfer!, (value) {
    return _then(_self.copyWith(transfer: value));
  });
}
}

// dart format on
