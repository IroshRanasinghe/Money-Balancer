import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  List<TransactionModel> getAll();
  Future<void> put(TransactionModel model);

  /// Throws [NotFoundException] when [id] is absent.
  Future<void> update(TransactionModel model);

  /// Throws [NotFoundException] when [id] is absent.
  Future<void> delete(String id);
}

class HiveTransactionLocalDataSource implements TransactionLocalDataSource {
  HiveTransactionLocalDataSource(this._box);

  final Box<TransactionModel> _box;

  @override
  List<TransactionModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read transactions: $e');
    }
  }

  @override
  Future<void> put(TransactionModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save transaction: $e');
    }
  }

  @override
  Future<void> update(TransactionModel model) async {
    if (!_box.containsKey(model.id)) throw const NotFoundException();
    await put(model);
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) throw const NotFoundException();
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete transaction: $e');
    }
  }
}
