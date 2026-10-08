import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@JsonSerializable()
class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
    required this.isActive,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  factory BudgetModel.fromEntity(Budget b) => BudgetModel(
        id: b.id,
        category: b.category,
        limit: b.limit,
        month: b.month,
        year: b.year,
        isActive: b.isActive,
      );

  final String id;
  final String category;
  final double limit;
  final int month;
  final int year;
  final bool isActive;

  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);

  Budget toEntity() => Budget(
        id: id,
        category: category,
        limit: limit,
        month: month,
        year: year,
        isActive: isActive,
      );
}
