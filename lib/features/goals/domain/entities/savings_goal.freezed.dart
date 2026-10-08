// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SavingsGoal {

 String get id; String get name; double get targetAmount; double get savedAmount; DateTime? get targetDate; int get colorValue; DateTime get createdAt;
/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsGoalCopyWith<SavingsGoal> get copyWith => _$SavingsGoalCopyWithImpl<SavingsGoal>(this as SavingsGoal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingsGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.savedAmount, savedAmount) || other.savedAmount == savedAmount)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,targetAmount,savedAmount,targetDate,colorValue,createdAt);

@override
String toString() {
  return 'SavingsGoal(id: $id, name: $name, targetAmount: $targetAmount, savedAmount: $savedAmount, targetDate: $targetDate, colorValue: $colorValue, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SavingsGoalCopyWith<$Res>  {
  factory $SavingsGoalCopyWith(SavingsGoal value, $Res Function(SavingsGoal) _then) = _$SavingsGoalCopyWithImpl;
@useResult
$Res call({
 String id, String name, double targetAmount, double savedAmount, DateTime? targetDate, int colorValue, DateTime createdAt
});




}
/// @nodoc
class _$SavingsGoalCopyWithImpl<$Res>
    implements $SavingsGoalCopyWith<$Res> {
  _$SavingsGoalCopyWithImpl(this._self, this._then);

  final SavingsGoal _self;
  final $Res Function(SavingsGoal) _then;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? targetAmount = null,Object? savedAmount = null,Object? targetDate = freezed,Object? colorValue = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,savedAmount: null == savedAmount ? _self.savedAmount : savedAmount // ignore: cast_nullable_to_non_nullable
as double,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingsGoal].
extension SavingsGoalPatterns on SavingsGoal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingsGoal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingsGoal value)  $default,){
final _that = this;
switch (_that) {
case _SavingsGoal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingsGoal value)?  $default,){
final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double targetAmount,  double savedAmount,  DateTime? targetDate,  int colorValue,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
return $default(_that.id,_that.name,_that.targetAmount,_that.savedAmount,_that.targetDate,_that.colorValue,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double targetAmount,  double savedAmount,  DateTime? targetDate,  int colorValue,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SavingsGoal():
return $default(_that.id,_that.name,_that.targetAmount,_that.savedAmount,_that.targetDate,_that.colorValue,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double targetAmount,  double savedAmount,  DateTime? targetDate,  int colorValue,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
return $default(_that.id,_that.name,_that.targetAmount,_that.savedAmount,_that.targetDate,_that.colorValue,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _SavingsGoal extends SavingsGoal {
  const _SavingsGoal({required this.id, required this.name, required this.targetAmount, this.savedAmount = 0, this.targetDate, required this.colorValue, required this.createdAt}): super._();
  

@override final  String id;
@override final  String name;
@override final  double targetAmount;
@override@JsonKey() final  double savedAmount;
@override final  DateTime? targetDate;
@override final  int colorValue;
@override final  DateTime createdAt;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsGoalCopyWith<_SavingsGoal> get copyWith => __$SavingsGoalCopyWithImpl<_SavingsGoal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingsGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.savedAmount, savedAmount) || other.savedAmount == savedAmount)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,targetAmount,savedAmount,targetDate,colorValue,createdAt);

@override
String toString() {
  return 'SavingsGoal(id: $id, name: $name, targetAmount: $targetAmount, savedAmount: $savedAmount, targetDate: $targetDate, colorValue: $colorValue, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SavingsGoalCopyWith<$Res> implements $SavingsGoalCopyWith<$Res> {
  factory _$SavingsGoalCopyWith(_SavingsGoal value, $Res Function(_SavingsGoal) _then) = __$SavingsGoalCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double targetAmount, double savedAmount, DateTime? targetDate, int colorValue, DateTime createdAt
});




}
/// @nodoc
class __$SavingsGoalCopyWithImpl<$Res>
    implements _$SavingsGoalCopyWith<$Res> {
  __$SavingsGoalCopyWithImpl(this._self, this._then);

  final _SavingsGoal _self;
  final $Res Function(_SavingsGoal) _then;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? targetAmount = null,Object? savedAmount = null,Object? targetDate = freezed,Object? colorValue = null,Object? createdAt = null,}) {
  return _then(_SavingsGoal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,savedAmount: null == savedAmount ? _self.savedAmount : savedAmount // ignore: cast_nullable_to_non_nullable
as double,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
