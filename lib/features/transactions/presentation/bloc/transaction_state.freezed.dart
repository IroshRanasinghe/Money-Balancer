// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionState {

 TransactionListStatus get status; List<Transaction> get all; TransactionType? get typeFilter; String? get categoryFilter; TransactionSort get sort; String? get errorMessage;
/// Create a copy of TransactionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionStateCopyWith<TransactionState> get copyWith => _$TransactionStateCopyWithImpl<TransactionState>(this as TransactionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.all, all)&&(identical(other.typeFilter, typeFilter) || other.typeFilter == typeFilter)&&(identical(other.categoryFilter, categoryFilter) || other.categoryFilter == categoryFilter)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(all),typeFilter,categoryFilter,sort,errorMessage);

@override
String toString() {
  return 'TransactionState(status: $status, all: $all, typeFilter: $typeFilter, categoryFilter: $categoryFilter, sort: $sort, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $TransactionStateCopyWith<$Res>  {
  factory $TransactionStateCopyWith(TransactionState value, $Res Function(TransactionState) _then) = _$TransactionStateCopyWithImpl;
@useResult
$Res call({
 TransactionListStatus status, List<Transaction> all, TransactionType? typeFilter, String? categoryFilter, TransactionSort sort, String? errorMessage
});




}
/// @nodoc
class _$TransactionStateCopyWithImpl<$Res>
    implements $TransactionStateCopyWith<$Res> {
  _$TransactionStateCopyWithImpl(this._self, this._then);

  final TransactionState _self;
  final $Res Function(TransactionState) _then;

/// Create a copy of TransactionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? all = null,Object? typeFilter = freezed,Object? categoryFilter = freezed,Object? sort = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionListStatus,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as List<Transaction>,typeFilter: freezed == typeFilter ? _self.typeFilter : typeFilter // ignore: cast_nullable_to_non_nullable
as TransactionType?,categoryFilter: freezed == categoryFilter ? _self.categoryFilter : categoryFilter // ignore: cast_nullable_to_non_nullable
as String?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as TransactionSort,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionState].
extension TransactionStatePatterns on TransactionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionState value)  $default,){
final _that = this;
switch (_that) {
case _TransactionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionState value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TransactionListStatus status,  List<Transaction> all,  TransactionType? typeFilter,  String? categoryFilter,  TransactionSort sort,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionState() when $default != null:
return $default(_that.status,_that.all,_that.typeFilter,_that.categoryFilter,_that.sort,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TransactionListStatus status,  List<Transaction> all,  TransactionType? typeFilter,  String? categoryFilter,  TransactionSort sort,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _TransactionState():
return $default(_that.status,_that.all,_that.typeFilter,_that.categoryFilter,_that.sort,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TransactionListStatus status,  List<Transaction> all,  TransactionType? typeFilter,  String? categoryFilter,  TransactionSort sort,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _TransactionState() when $default != null:
return $default(_that.status,_that.all,_that.typeFilter,_that.categoryFilter,_that.sort,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionState extends TransactionState {
  const _TransactionState({this.status = TransactionListStatus.initial, final  List<Transaction> all = const <Transaction>[], this.typeFilter, this.categoryFilter, this.sort = TransactionSort.newest, this.errorMessage}): _all = all,super._();
  

@override@JsonKey() final  TransactionListStatus status;
 final  List<Transaction> _all;
@override@JsonKey() List<Transaction> get all {
  if (_all is EqualUnmodifiableListView) return _all;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_all);
}

@override final  TransactionType? typeFilter;
@override final  String? categoryFilter;
@override@JsonKey() final  TransactionSort sort;
@override final  String? errorMessage;

/// Create a copy of TransactionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionStateCopyWith<_TransactionState> get copyWith => __$TransactionStateCopyWithImpl<_TransactionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._all, _all)&&(identical(other.typeFilter, typeFilter) || other.typeFilter == typeFilter)&&(identical(other.categoryFilter, categoryFilter) || other.categoryFilter == categoryFilter)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_all),typeFilter,categoryFilter,sort,errorMessage);

@override
String toString() {
  return 'TransactionState(status: $status, all: $all, typeFilter: $typeFilter, categoryFilter: $categoryFilter, sort: $sort, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$TransactionStateCopyWith<$Res> implements $TransactionStateCopyWith<$Res> {
  factory _$TransactionStateCopyWith(_TransactionState value, $Res Function(_TransactionState) _then) = __$TransactionStateCopyWithImpl;
@override @useResult
$Res call({
 TransactionListStatus status, List<Transaction> all, TransactionType? typeFilter, String? categoryFilter, TransactionSort sort, String? errorMessage
});




}
/// @nodoc
class __$TransactionStateCopyWithImpl<$Res>
    implements _$TransactionStateCopyWith<$Res> {
  __$TransactionStateCopyWithImpl(this._self, this._then);

  final _TransactionState _self;
  final $Res Function(_TransactionState) _then;

/// Create a copy of TransactionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? all = null,Object? typeFilter = freezed,Object? categoryFilter = freezed,Object? sort = null,Object? errorMessage = freezed,}) {
  return _then(_TransactionState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionListStatus,all: null == all ? _self._all : all // ignore: cast_nullable_to_non_nullable
as List<Transaction>,typeFilter: freezed == typeFilter ? _self.typeFilter : typeFilter // ignore: cast_nullable_to_non_nullable
as TransactionType?,categoryFilter: freezed == categoryFilter ? _self.categoryFilter : categoryFilter // ignore: cast_nullable_to_non_nullable
as String?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as TransactionSort,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
