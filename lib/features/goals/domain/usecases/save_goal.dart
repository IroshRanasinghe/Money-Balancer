import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/premium/premium_feature.dart';
import '../../../premium/domain/usecases/check_premium_access.dart';
import '../entities/savings_goal.dart';
import '../repositories/goal_repository.dart';

class SaveGoal {
  const SaveGoal(this._repository, this._checkPremium);

  final GoalRepository _repository;
  final CheckPremiumAccess _checkPremium;

  Future<Either<Failure, void>> call(SavingsGoal goal) async {
    final existing = await _repository.getGoals();
    return existing.fold((failure) async => Left(failure), (goals) async {
      if (!goals.any((g) => g.id == goal.id)) {
        final allowed = await _checkPremium(
          PremiumFeature.goals,
          currentCount: goals.length,
        );
        if (allowed.isLeft()) return allowed;
      }
      return _repository.saveGoal(goal);
    });
  }
}
