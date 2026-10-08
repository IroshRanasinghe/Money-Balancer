import 'package:equatable/equatable.dart';

sealed class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class BudgetLoadRequested extends BudgetEvent {
  const BudgetLoadRequested();
}

class BudgetMonthShifted extends BudgetEvent {
  const BudgetMonthShifted(this.delta);
  final int delta;
  @override
  List<Object?> get props => [delta];
}

class BudgetSaveRequested extends BudgetEvent {
  const BudgetSaveRequested({
    this.id,
    required this.category,
    required this.limitText,
    required this.isActive,
  });

  final String? id;
  final String category;
  final String limitText;
  final bool isActive;

  @override
  List<Object?> get props => [id, category, limitText, isActive];
}

class BudgetDeleteRequested extends BudgetEvent {
  const BudgetDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
