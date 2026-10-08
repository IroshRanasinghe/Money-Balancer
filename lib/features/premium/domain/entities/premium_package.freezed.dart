// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'premium_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PremiumPackage {

 String get id; String get title; String get priceString;/// 'monthly' | 'yearly' | other
 String get period;/// e.g. '7-day free trial'
 String? get introOffer;
/// Create a copy of PremiumPackage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PremiumPackageCopyWith<PremiumPackage> get copyWith => _$PremiumPackageCopyWithImpl<PremiumPackage>(this as PremiumPackage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PremiumPackage&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceString, priceString) || other.priceString == priceString)&&(identical(other.period, period) || other.period == period)&&(identical(other.introOffer, introOffer) || other.introOffer == introOffer));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,priceString,period,introOffer);

@override
String toString() {
  return 'PremiumPackage(id: $id, title: $title, priceString: $priceString, period: $period, introOffer: $introOffer)';
}


}

/// @nodoc
abstract mixin class $PremiumPackageCopyWith<$Res>  {
  factory $PremiumPackageCopyWith(PremiumPackage value, $Res Function(PremiumPackage) _then) = _$PremiumPackageCopyWithImpl;
@useResult
$Res call({
 String id, String title, String priceString, String period, String? introOffer
});




}
/// @nodoc
class _$PremiumPackageCopyWithImpl<$Res>
    implements $PremiumPackageCopyWith<$Res> {
  _$PremiumPackageCopyWithImpl(this._self, this._then);

  final PremiumPackage _self;
  final $Res Function(PremiumPackage) _then;

/// Create a copy of PremiumPackage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? priceString = null,Object? period = null,Object? introOffer = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceString: null == priceString ? _self.priceString : priceString // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,introOffer: freezed == introOffer ? _self.introOffer : introOffer // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PremiumPackage].
extension PremiumPackagePatterns on PremiumPackage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PremiumPackage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PremiumPackage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PremiumPackage value)  $default,){
final _that = this;
switch (_that) {
case _PremiumPackage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PremiumPackage value)?  $default,){
final _that = this;
switch (_that) {
case _PremiumPackage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String priceString,  String period,  String? introOffer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PremiumPackage() when $default != null:
return $default(_that.id,_that.title,_that.priceString,_that.period,_that.introOffer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String priceString,  String period,  String? introOffer)  $default,) {final _that = this;
switch (_that) {
case _PremiumPackage():
return $default(_that.id,_that.title,_that.priceString,_that.period,_that.introOffer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String priceString,  String period,  String? introOffer)?  $default,) {final _that = this;
switch (_that) {
case _PremiumPackage() when $default != null:
return $default(_that.id,_that.title,_that.priceString,_that.period,_that.introOffer);case _:
  return null;

}
}

}

/// @nodoc


class _PremiumPackage implements PremiumPackage {
  const _PremiumPackage({required this.id, required this.title, required this.priceString, required this.period, this.introOffer});
  

@override final  String id;
@override final  String title;
@override final  String priceString;
/// 'monthly' | 'yearly' | other
@override final  String period;
/// e.g. '7-day free trial'
@override final  String? introOffer;

/// Create a copy of PremiumPackage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PremiumPackageCopyWith<_PremiumPackage> get copyWith => __$PremiumPackageCopyWithImpl<_PremiumPackage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PremiumPackage&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceString, priceString) || other.priceString == priceString)&&(identical(other.period, period) || other.period == period)&&(identical(other.introOffer, introOffer) || other.introOffer == introOffer));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,priceString,period,introOffer);

@override
String toString() {
  return 'PremiumPackage(id: $id, title: $title, priceString: $priceString, period: $period, introOffer: $introOffer)';
}


}

/// @nodoc
abstract mixin class _$PremiumPackageCopyWith<$Res> implements $PremiumPackageCopyWith<$Res> {
  factory _$PremiumPackageCopyWith(_PremiumPackage value, $Res Function(_PremiumPackage) _then) = __$PremiumPackageCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String priceString, String period, String? introOffer
});




}
/// @nodoc
class __$PremiumPackageCopyWithImpl<$Res>
    implements _$PremiumPackageCopyWith<$Res> {
  __$PremiumPackageCopyWithImpl(this._self, this._then);

  final _PremiumPackage _self;
  final $Res Function(_PremiumPackage) _then;

/// Create a copy of PremiumPackage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? priceString = null,Object? period = null,Object? introOffer = freezed,}) {
  return _then(_PremiumPackage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceString: null == priceString ? _self.priceString : priceString // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,introOffer: freezed == introOffer ? _self.introOffer : introOffer // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
