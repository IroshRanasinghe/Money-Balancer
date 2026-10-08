import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../premium/domain/entities/premium_feature.dart';
import '../../../premium/domain/usecases/check_premium_access.dart';
import '../entities/recurring_rule.dart';
import '../repositories/recurring_repository.dart';

class SaveRecurringRule {
  const SaveRecurringRule(this._repository, this._checkPremium);

  final RecurringRepository _repository;
  final CheckPremiumAccess _checkPremium;

  Future<Either<Failure, void>> call(RecurringRule rule) async {
    final existing = await _repository.getRules();
    return existing.fold((failure) async => Left(failure), (rules) async {
      if (!rules.any((r) => r.id == rule.id)) {
        final allowed = await _checkPremium(
          PremiumFeature.recurring,
          currentCount: rules.length,
        );
        if (allowed.isLeft()) return allowed;
      }
      return _repository.saveRule(rule);
    });
  }
}
