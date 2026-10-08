// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MonthlyTotal {

 int get month; int get year; double get income; double get expense;
/// Create a copy of MonthlyTotal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyTotalCopyWith<MonthlyTotal> get copyWith => _$MonthlyTotalCopyWithImpl<MonthlyTotal>(this as MonthlyTotal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyTotal&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,month,year,income,expense);

@override
String toString() {
  return 'MonthlyTotal(month: $month, year: $year, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class $MonthlyTotalCopyWith<$Res>  {
  factory $MonthlyTotalCopyWith(MonthlyTotal value, $Res Function(MonthlyTotal) _then) = _$MonthlyTotalCopyWithImpl;
@useResult
$Res call({
 int month, int year, double income, double expense
});




}
/// @nodoc
class _$MonthlyTotalCopyWithImpl<$Res>
    implements $MonthlyTotalCopyWith<$Res> {
  _$MonthlyTotalCopyWithImpl(this._self, this._then);

  final MonthlyTotal _self;
  final $Res Function(MonthlyTotal) _then;

/// Create a copy of MonthlyTotal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? year = null,Object? income = null,Object? expense = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyTotal].
extension MonthlyTotalPatterns on MonthlyTotal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyTotal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyTotal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyTotal value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyTotal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyTotal value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyTotal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int month,  int year,  double income,  double expense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyTotal() when $default != null:
return $default(_that.month,_that.year,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int month,  int year,  double income,  double expense)  $default,) {final _that = this;
switch (_that) {
case _MonthlyTotal():
return $default(_that.month,_that.year,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int month,  int year,  double income,  double expense)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyTotal() when $default != null:
return $default(_that.month,_that.year,_that.income,_that.expense);case _:
  return null;

}
}

}

/// @nodoc


class _MonthlyTotal implements MonthlyTotal {
  const _MonthlyTotal({required this.month, required this.year, required this.income, required this.expense});
  

@override final  int month;
@override final  int year;
@override final  double income;
@override final  double expense;

/// Create a copy of MonthlyTotal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyTotalCopyWith<_MonthlyTotal> get copyWith => __$MonthlyTotalCopyWithImpl<_MonthlyTotal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyTotal&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,month,year,income,expense);

@override
String toString() {
  return 'MonthlyTotal(month: $month, year: $year, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class _$MonthlyTotalCopyWith<$Res> implements $MonthlyTotalCopyWith<$Res> {
  factory _$MonthlyTotalCopyWith(_MonthlyTotal value, $Res Function(_MonthlyTotal) _then) = __$MonthlyTotalCopyWithImpl;
@override @useResult
$Res call({
 int month, int year, double income, double expense
});




}
/// @nodoc
class __$MonthlyTotalCopyWithImpl<$Res>
    implements _$MonthlyTotalCopyWith<$Res> {
  __$MonthlyTotalCopyWithImpl(this._self, this._then);

  final _MonthlyTotal _self;
  final $Res Function(_MonthlyTotal) _then;

/// Create a copy of MonthlyTotal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? year = null,Object? income = null,Object? expense = null,}) {
  return _then(_MonthlyTotal(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$ReportData {

 int get month; int get year; double get totalIncome; double get totalExpense;/// Expense totals per category for the month, largest first.
 Map<String, double> get expenseByCategory;/// Oldest → newest, ending with the selected month.
 List<MonthlyTotal> get trend;
/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportDataCopyWith<ReportData> get copyWith => _$ReportDataCopyWithImpl<ReportData>(this as ReportData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportData&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&const DeepCollectionEquality().equals(other.expenseByCategory, expenseByCategory)&&const DeepCollectionEquality().equals(other.trend, trend));
}


@override
int get hashCode => Object.hash(runtimeType,month,year,totalIncome,totalExpense,const DeepCollectionEquality().hash(expenseByCategory),const DeepCollectionEquality().hash(trend));

@override
String toString() {
  return 'ReportData(month: $month, year: $year, totalIncome: $totalIncome, totalExpense: $totalExpense, expenseByCategory: $expenseByCategory, trend: $trend)';
}


}

/// @nodoc
abstract mixin class $ReportDataCopyWith<$Res>  {
  factory $ReportDataCopyWith(ReportData value, $Res Function(ReportData) _then) = _$ReportDataCopyWithImpl;
@useResult
$Res call({
 int month, int year, double totalIncome, double totalExpense, Map<String, double> expenseByCategory, List<MonthlyTotal> trend
});




}
/// @nodoc
class _$ReportDataCopyWithImpl<$Res>
    implements $ReportDataCopyWith<$Res> {
  _$ReportDataCopyWithImpl(this._self, this._then);

  final ReportData _self;
  final $Res Function(ReportData) _then;

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? year = null,Object? totalIncome = null,Object? totalExpense = null,Object? expenseByCategory = null,Object? trend = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,expenseByCategory: null == expenseByCategory ? _self.expenseByCategory : expenseByCategory // ignore: cast_nullable_to_non_nullable
as Map<String, double>,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as List<MonthlyTotal>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportData].
extension ReportDataPatterns on ReportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportData value)  $default,){
final _that = this;
switch (_that) {
case _ReportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportData value)?  $default,){
final _that = this;
switch (_that) {
case _ReportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int month,  int year,  double totalIncome,  double totalExpense,  Map<String, double> expenseByCategory,  List<MonthlyTotal> trend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportData() when $default != null:
return $default(_that.month,_that.year,_that.totalIncome,_that.totalExpense,_that.expenseByCategory,_that.trend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int month,  int year,  double totalIncome,  double totalExpense,  Map<String, double> expenseByCategory,  List<MonthlyTotal> trend)  $default,) {final _that = this;
switch (_that) {
case _ReportData():
return $default(_that.month,_that.year,_that.totalIncome,_that.totalExpense,_that.expenseByCategory,_that.trend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int month,  int year,  double totalIncome,  double totalExpense,  Map<String, double> expenseByCategory,  List<MonthlyTotal> trend)?  $default,) {final _that = this;
switch (_that) {
case _ReportData() when $default != null:
return $default(_that.month,_that.year,_that.totalIncome,_that.totalExpense,_that.expenseByCategory,_that.trend);case _:
  return null;

}
}

}

/// @nodoc


class _ReportData extends ReportData {
  const _ReportData({required this.month, required this.year, required this.totalIncome, required this.totalExpense, required final  Map<String, double> expenseByCategory, required final  List<MonthlyTotal> trend}): _expenseByCategory = expenseByCategory,_trend = trend,super._();
  

@override final  int month;
@override final  int year;
@override final  double totalIncome;
@override final  double totalExpense;
/// Expense totals per category for the month, largest first.
 final  Map<String, double> _expenseByCategory;
/// Expense totals per category for the month, largest first.
@override Map<String, double> get expenseByCategory {
  if (_expenseByCategory is EqualUnmodifiableMapView) return _expenseByCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_expenseByCategory);
}

/// Oldest → newest, ending with the selected month.
 final  List<MonthlyTotal> _trend;
/// Oldest → newest, ending with the selected month.
@override List<MonthlyTotal> get trend {
  if (_trend is EqualUnmodifiableListView) return _trend;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trend);
}


/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportDataCopyWith<_ReportData> get copyWith => __$ReportDataCopyWithImpl<_ReportData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportData&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&const DeepCollectionEquality().equals(other._expenseByCategory, _expenseByCategory)&&const DeepCollectionEquality().equals(other._trend, _trend));
}


@override
int get hashCode => Object.hash(runtimeType,month,year,totalIncome,totalExpense,const DeepCollectionEquality().hash(_expenseByCategory),const DeepCollectionEquality().hash(_trend));

@override
String toString() {
  return 'ReportData(month: $month, year: $year, totalIncome: $totalIncome, totalExpense: $totalExpense, expenseByCategory: $expenseByCategory, trend: $trend)';
}


}

/// @nodoc
abstract mixin class _$ReportDataCopyWith<$Res> implements $ReportDataCopyWith<$Res> {
  factory _$ReportDataCopyWith(_ReportData value, $Res Function(_ReportData) _then) = __$ReportDataCopyWithImpl;
@override @useResult
$Res call({
 int month, int year, double totalIncome, double totalExpense, Map<String, double> expenseByCategory, List<MonthlyTotal> trend
});




}
/// @nodoc
class __$ReportDataCopyWithImpl<$Res>
    implements _$ReportDataCopyWith<$Res> {
  __$ReportDataCopyWithImpl(this._self, this._then);

  final _ReportData _self;
  final $Res Function(_ReportData) _then;

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? year = null,Object? totalIncome = null,Object? totalExpense = null,Object? expenseByCategory = null,Object? trend = null,}) {
  return _then(_ReportData(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,expenseByCategory: null == expenseByCategory ? _self._expenseByCategory : expenseByCategory // ignore: cast_nullable_to_non_nullable
as Map<String, double>,trend: null == trend ? _self._trend : trend // ignore: cast_nullable_to_non_nullable
as List<MonthlyTotal>,
  ));
}


}

// dart format on
