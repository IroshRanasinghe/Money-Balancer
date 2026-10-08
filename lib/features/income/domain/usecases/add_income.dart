import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

class AddIncome {
  const AddIncome(this._repository, this._uuid);

  final TransactionRepository _repository;
  final Uuid _uuid;

  Future<Either<Failure, void>> call({
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
    String? accountId,
  }) => _repository.addTransaction(
    Transaction(
      id: _uuid.v4(),
      amount: amount,
      category: category,
      date: date,
      type: TransactionType.income,
      notes: notes,
      accountId: accountId,
      createdAt: DateTime.now(),
    ),
  );
}
