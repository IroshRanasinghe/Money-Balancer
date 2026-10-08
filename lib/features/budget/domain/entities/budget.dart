import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';

@freezed
abstract class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String category,
    required double limit,
    required int month,
    required int year,
    @Default(true) bool isActive,
  }) = _Budget;
}
