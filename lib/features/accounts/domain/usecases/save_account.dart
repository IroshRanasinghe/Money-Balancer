import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/premium/premium_feature.dart';
import '../../../premium/domain/usecases/check_premium_access.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class SaveAccount {
  const SaveAccount(this._repository, this._checkPremium);

  final AccountRepository _repository;
  final CheckPremiumAccess _checkPremium;

  Future<Either<Failure, void>> call(Account account) async {
    final existing = await _repository.getAccounts();
    return existing.fold((failure) async => Left(failure), (accounts) async {
      if (!accounts.any((a) => a.id == account.id)) {
        final allowed = await _checkPremium(
          PremiumFeature.accounts,
          currentCount: accounts.length,
        );
        if (allowed.isLeft()) return allowed;
      }
      return _repository.saveAccount(account);
    });
  }
}
