import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/goal_model.dart';

abstract class GoalLocalDataSource {
  List<GoalModel> getAll();
  Future<void> put(GoalModel model);

  /// Throws [NotFoundException] when [id] is absent.
  Future<void> delete(String id);
}

class HiveGoalLocalDataSource implements GoalLocalDataSource {
  HiveGoalLocalDataSource(this._box);

  final Box<GoalModel> _box;

  @override
  List<GoalModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read goals: $e');
    }
  }

  @override
  Future<void> put(GoalModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save goal: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) throw const NotFoundException();
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete goal: $e');
    }
  }
}
