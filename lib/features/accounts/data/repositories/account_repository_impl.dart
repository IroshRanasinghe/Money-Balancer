import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/transfer.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../datasources/transfer_local_datasource.dart';
import '../models/account_model.dart';
import '../models/transfer_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._accounts, this._transfers);

  final AccountLocalDataSource _accounts;
  final TransferLocalDataSource _transfers;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    try {
      final list = _accounts.getAll().map((m) => m.toEntity()).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Right(list);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveAccount(Account account) async {
    try {
      await _accounts.put(AccountModel.fromEntity(account));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      await _accounts.delete(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Transfer>>> getTransfers() async {
    try {
      final list = _transfers.getAll().map((m) => m.toEntity()).toList()
        ..sort((a, b) {
          final byDate = b.date.compareTo(a.date);
          return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
        });
      return Right(list);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveTransfer(Transfer transfer) async {
    try {
      await _transfers.put(TransferModel.fromEntity(transfer));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransfer(String id) async {
    try {
      await _transfers.delete(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
