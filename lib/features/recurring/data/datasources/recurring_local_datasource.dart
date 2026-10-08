import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/recurring_rule_model.dart';

abstract class RecurringLocalDataSource {
  List<RecurringRuleModel> getAll();
  Future<void> put(RecurringRuleModel model);

  /// Throws [NotFoundException] when [id] is absent.
  Future<void> delete(String id);
}

class HiveRecurringLocalDataSource implements RecurringLocalDataSource {
  HiveRecurringLocalDataSource(this._box);

  final Box<RecurringRuleModel> _box;

  @override
  List<RecurringRuleModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read recurring items: $e');
    }
  }

  @override
  Future<void> put(RecurringRuleModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save recurring item: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) throw const NotFoundException();
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete recurring item: $e');
    }
  }
}
