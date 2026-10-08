// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_counts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BackupCounts {

 int get transactions; int get budgets; int get cards; int get accounts; int get transfers; int get recurringRules; int get goals;
/// Create a copy of BackupCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupCountsCopyWith<BackupCounts> get copyWith => _$BackupCountsCopyWithImpl<BackupCounts>(this as BackupCounts, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupCounts&&(identical(other.transactions, transactions) || other.transactions == transactions)&&(identical(other.budgets, budgets) || other.budgets == budgets)&&(identical(other.cards, cards) || other.cards == cards)&&(identical(other.accounts, accounts) || other.accounts == accounts)&&(identical(other.transfers, transfers) || other.transfers == transfers)&&(identical(other.recurringRules, recurringRules) || other.recurringRules == recurringRules)&&(identical(other.goals, goals) || other.goals == goals));
}


@override
int get hashCode => Object.hash(runtimeType,transactions,budgets,cards,accounts,transfers,recurringRules,goals);

@override
String toString() {
  return 'BackupCounts(transactions: $transactions, budgets: $budgets, cards: $cards, accounts: $accounts, transfers: $transfers, recurringRules: $recurringRules, goals: $goals)';
}


}

/// @nodoc
abstract mixin class $BackupCountsCopyWith<$Res>  {
  factory $BackupCountsCopyWith(BackupCounts value, $Res Function(BackupCounts) _then) = _$BackupCountsCopyWithImpl;
@useResult
$Res call({
 int transactions, int budgets, int cards, int accounts, int transfers, int recurringRules, int goals
});




}
/// @nodoc
class _$BackupCountsCopyWithImpl<$Res>
    implements $BackupCountsCopyWith<$Res> {
  _$BackupCountsCopyWithImpl(this._self, this._then);

  final BackupCounts _self;
  final $Res Function(BackupCounts) _then;

/// Create a copy of BackupCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactions = null,Object? budgets = null,Object? cards = null,Object? accounts = null,Object? transfers = null,Object? recurringRules = null,Object? goals = null,}) {
  return _then(_self.copyWith(
transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as int,budgets: null == budgets ? _self.budgets : budgets // ignore: cast_nullable_to_non_nullable
as int,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as int,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as int,transfers: null == transfers ? _self.transfers : transfers // ignore: cast_nullable_to_non_nullable
as int,recurringRules: null == recurringRules ? _self.recurringRules : recurringRules // ignore: cast_nullable_to_non_nullable
as int,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BackupCounts].
extension BackupCountsPatterns on BackupCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackupCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackupCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackupCounts value)  $default,){
final _that = this;
switch (_that) {
case _BackupCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackupCounts value)?  $default,){
final _that = this;
switch (_that) {
case _BackupCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int transactions,  int budgets,  int cards,  int accounts,  int transfers,  int recurringRules,  int goals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackupCounts() when $default != null:
return $default(_that.transactions,_that.budgets,_that.cards,_that.accounts,_that.transfers,_that.recurringRules,_that.goals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int transactions,  int budgets,  int cards,  int accounts,  int transfers,  int recurringRules,  int goals)  $default,) {final _that = this;
switch (_that) {
case _BackupCounts():
return $default(_that.transactions,_that.budgets,_that.cards,_that.accounts,_that.transfers,_that.recurringRules,_that.goals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int transactions,  int budgets,  int cards,  int accounts,  int transfers,  int recurringRules,  int goals)?  $default,) {final _that = this;
switch (_that) {
case _BackupCounts() when $default != null:
return $default(_that.transactions,_that.budgets,_that.cards,_that.accounts,_that.transfers,_that.recurringRules,_that.goals);case _:
  return null;

}
}

}

/// @nodoc


class _BackupCounts implements BackupCounts {
  const _BackupCounts({required this.transactions, required this.budgets, required this.cards, required this.accounts, required this.transfers, required this.recurringRules, required this.goals});
  

@override final  int transactions;
@override final  int budgets;
@override final  int cards;
@override final  int accounts;
@override final  int transfers;
@override final  int recurringRules;
@override final  int goals;

/// Create a copy of BackupCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackupCountsCopyWith<_BackupCounts> get copyWith => __$BackupCountsCopyWithImpl<_BackupCounts>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackupCounts&&(identical(other.transactions, transactions) || other.transactions == transactions)&&(identical(other.budgets, budgets) || other.budgets == budgets)&&(identical(other.cards, cards) || other.cards == cards)&&(identical(other.accounts, accounts) || other.accounts == accounts)&&(identical(other.transfers, transfers) || other.transfers == transfers)&&(identical(other.recurringRules, recurringRules) || other.recurringRules == recurringRules)&&(identical(other.goals, goals) || other.goals == goals));
}


@override
int get hashCode => Object.hash(runtimeType,transactions,budgets,cards,accounts,transfers,recurringRules,goals);

@override
String toString() {
  return 'BackupCounts(transactions: $transactions, budgets: $budgets, cards: $cards, accounts: $accounts, transfers: $transfers, recurringRules: $recurringRules, goals: $goals)';
}


}

/// @nodoc
abstract mixin class _$BackupCountsCopyWith<$Res> implements $BackupCountsCopyWith<$Res> {
  factory _$BackupCountsCopyWith(_BackupCounts value, $Res Function(_BackupCounts) _then) = __$BackupCountsCopyWithImpl;
@override @useResult
$Res call({
 int transactions, int budgets, int cards, int accounts, int transfers, int recurringRules, int goals
});




}
/// @nodoc
class __$BackupCountsCopyWithImpl<$Res>
    implements _$BackupCountsCopyWith<$Res> {
  __$BackupCountsCopyWithImpl(this._self, this._then);

  final _BackupCounts _self;
  final $Res Function(_BackupCounts) _then;

/// Create a copy of BackupCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactions = null,Object? budgets = null,Object? cards = null,Object? accounts = null,Object? transfers = null,Object? recurringRules = null,Object? goals = null,}) {
  return _then(_BackupCounts(
transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as int,budgets: null == budgets ? _self.budgets : budgets // ignore: cast_nullable_to_non_nullable
as int,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as int,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as int,transfers: null == transfers ? _self.transfers : transfers // ignore: cast_nullable_to_non_nullable
as int,recurringRules: null == recurringRules ? _self.recurringRules : recurringRules // ignore: cast_nullable_to_non_nullable
as int,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
