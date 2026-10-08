import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/account_model.dart';

abstract class AccountLocalDataSource {
  List<AccountModel> getAll();
  Future<void> put(AccountModel model);

  /// Throws [NotFoundException] when [id] is absent.
  Future<void> delete(String id);
}

class HiveAccountLocalDataSource implements AccountLocalDataSource {
  HiveAccountLocalDataSource(this._box);

  final Box<AccountModel> _box;

  @override
  List<AccountModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read accounts: $e');
    }
  }

  @override
  Future<void> put(AccountModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save account: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) throw const NotFoundException();
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete account: $e');
    }
  }
}
