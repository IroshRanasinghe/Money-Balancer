import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/budget_model.dart';

abstract class BudgetLocalDataSource {
  List<BudgetModel> getAll();
  Future<void> put(BudgetModel model);

  /// Throws [NotFoundException] when [id] is absent.
  Future<void> delete(String id);
}

class HiveBudgetLocalDataSource implements BudgetLocalDataSource {
  HiveBudgetLocalDataSource(this._box);

  final Box<BudgetModel> _box;

  @override
  List<BudgetModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read budgets: $e');
    }
  }

  @override
  Future<void> put(BudgetModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save budget: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) throw const NotFoundException();
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete budget: $e');
    }
  }
}
