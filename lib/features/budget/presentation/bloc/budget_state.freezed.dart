// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetState {

 int get month; int get year; BudgetListStatus get status; List<BudgetProgress> get items; String? get errorMessage;/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
 int get paywallCount; PremiumFeature? get paywallFeature;
/// Create a copy of BudgetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetStateCopyWith<BudgetState> get copyWith => _$BudgetStateCopyWithImpl<BudgetState>(this as BudgetState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetState&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,month,year,status,const DeepCollectionEquality().hash(items),errorMessage,paywallCount,paywallFeature);

@override
String toString() {
  return 'BudgetState(month: $month, year: $year, status: $status, items: $items, errorMessage: $errorMessage, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class $BudgetStateCopyWith<$Res>  {
  factory $BudgetStateCopyWith(BudgetState value, $Res Function(BudgetState) _then) = _$BudgetStateCopyWithImpl;
@useResult
$Res call({
 int month, int year, BudgetListStatus status, List<BudgetProgress> items, String? errorMessage, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class _$BudgetStateCopyWithImpl<$Res>
    implements $BudgetStateCopyWith<$Res> {
  _$BudgetStateCopyWithImpl(this._self, this._then);

  final BudgetState _self;
  final $Res Function(BudgetState) _then;

/// Create a copy of BudgetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? year = null,Object? status = null,Object? items = null,Object? errorMessage = freezed,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetListStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BudgetProgress>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetState].
extension BudgetStatePatterns on BudgetState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetState value)  $default,){
final _that = this;
switch (_that) {
case _BudgetState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetState value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int month,  int year,  BudgetListStatus status,  List<BudgetProgress> items,  String? errorMessage,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetState() when $default != null:
return $default(_that.month,_that.year,_that.status,_that.items,_that.errorMessage,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int month,  int year,  BudgetListStatus status,  List<BudgetProgress> items,  String? errorMessage,  int paywallCount,  PremiumFeature? paywallFeature)  $default,) {final _that = this;
switch (_that) {
case _BudgetState():
return $default(_that.month,_that.year,_that.status,_that.items,_that.errorMessage,_that.paywallCount,_that.paywallFeature);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int month,  int year,  BudgetListStatus status,  List<BudgetProgress> items,  String? errorMessage,  int paywallCount,  PremiumFeature? paywallFeature)?  $default,) {final _that = this;
switch (_that) {
case _BudgetState() when $default != null:
return $default(_that.month,_that.year,_that.status,_that.items,_that.errorMessage,_that.paywallCount,_that.paywallFeature);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetState implements BudgetState {
  const _BudgetState({required this.month, required this.year, this.status = BudgetListStatus.initial, final  List<BudgetProgress> items = const <BudgetProgress>[], this.errorMessage, this.paywallCount = 0, this.paywallFeature}): _items = items;
  

@override final  int month;
@override final  int year;
@override@JsonKey() final  BudgetListStatus status;
 final  List<BudgetProgress> _items;
@override@JsonKey() List<BudgetProgress> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? errorMessage;
/// Incremented when a save hits a free-plan limit, so the page can open
/// the paywall for [paywallFeature].
@override@JsonKey() final  int paywallCount;
@override final  PremiumFeature? paywallFeature;

/// Create a copy of BudgetState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetStateCopyWith<_BudgetState> get copyWith => __$BudgetStateCopyWithImpl<_BudgetState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetState&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.paywallCount, paywallCount) || other.paywallCount == paywallCount)&&(identical(other.paywallFeature, paywallFeature) || other.paywallFeature == paywallFeature));
}


@override
int get hashCode => Object.hash(runtimeType,month,year,status,const DeepCollectionEquality().hash(_items),errorMessage,paywallCount,paywallFeature);

@override
String toString() {
  return 'BudgetState(month: $month, year: $year, status: $status, items: $items, errorMessage: $errorMessage, paywallCount: $paywallCount, paywallFeature: $paywallFeature)';
}


}

/// @nodoc
abstract mixin class _$BudgetStateCopyWith<$Res> implements $BudgetStateCopyWith<$Res> {
  factory _$BudgetStateCopyWith(_BudgetState value, $Res Function(_BudgetState) _then) = __$BudgetStateCopyWithImpl;
@override @useResult
$Res call({
 int month, int year, BudgetListStatus status, List<BudgetProgress> items, String? errorMessage, int paywallCount, PremiumFeature? paywallFeature
});




}
/// @nodoc
class __$BudgetStateCopyWithImpl<$Res>
    implements _$BudgetStateCopyWith<$Res> {
  __$BudgetStateCopyWithImpl(this._self, this._then);

  final _BudgetState _self;
  final $Res Function(_BudgetState) _then;

/// Create a copy of BudgetState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? year = null,Object? status = null,Object? items = null,Object? errorMessage = freezed,Object? paywallCount = null,Object? paywallFeature = freezed,}) {
  return _then(_BudgetState(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetListStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BudgetProgress>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,paywallCount: null == paywallCount ? _self.paywallCount : paywallCount // ignore: cast_nullable_to_non_nullable
as int,paywallFeature: freezed == paywallFeature ? _self.paywallFeature : paywallFeature // ignore: cast_nullable_to_non_nullable
as PremiumFeature?,
  ));
}


}

// dart format on
