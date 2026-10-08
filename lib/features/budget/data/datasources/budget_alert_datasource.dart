import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';

abstract class BudgetAlertDataSource {
  bool wasSent(String key);
  Future<void> markSent(String key);
}

class HiveBudgetAlertDataSource implements BudgetAlertDataSource {
  HiveBudgetAlertDataSource(this._box);

  final Box<bool> _box;

  @override
  bool wasSent(String key) {
    try {
      return _box.get(key, defaultValue: false) ?? false;
    } catch (e) {
      throw CacheException('Failed to read budget alerts: $e');
    }
  }

  @override
  Future<void> markSent(String key) async {
    try {
      await _box.put(key, true);
    } catch (e) {
      throw CacheException('Failed to save budget alert: $e');
    }
  }
}
