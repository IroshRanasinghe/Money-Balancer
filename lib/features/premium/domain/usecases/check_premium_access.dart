import 'package:dartz/dartz.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/error/failures.dart';
import '../entities/premium_feature.dart';
import '../repositories/premium_repository.dart';

/// Decides whether the user may use [PremiumFeature] given how many items they
/// already have. Free tier is the safe fallback when status can't be read.
class CheckPremiumAccess {
  const CheckPremiumAccess(this._repository);

  final PremiumRepository _repository;

  Future<Either<Failure, void>> call(
    PremiumFeature feature, {
    required int currentCount,
  }) async {
    final status = (await _repository.getStatus())
        .fold<bool>((_) => false, (s) => s.isPremium);
    if (status) return const Right(null);
    final limit = switch (feature) {
      PremiumFeature.accounts => PremiumLimits.freeAccounts,
      PremiumFeature.cards => PremiumLimits.freeCards,
      PremiumFeature.budgets => PremiumLimits.freeBudgetsPerMonth,
      PremiumFeature.recurring => PremiumLimits.freeRecurring,
      PremiumFeature.goals => PremiumLimits.freeGoals,
      PremiumFeature.csvExport || PremiumFeature.budgetAlerts => 0,
    };
    if (limit > 0 && currentCount < limit) return const Right(null);
    return Left(PremiumRequiredFailure(feature));
  }
}
