import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/transfer_model.dart';

abstract class TransferLocalDataSource {
  List<TransferModel> getAll();
  Future<void> put(TransferModel model);

  /// Throws [NotFoundException] when [id] is absent.
  Future<void> delete(String id);
}

class HiveTransferLocalDataSource implements TransferLocalDataSource {
  HiveTransferLocalDataSource(this._box);

  final Box<TransferModel> _box;

  @override
  List<TransferModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read transfers: $e');
    }
  }

  @override
  Future<void> put(TransferModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save transfer: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) throw const NotFoundException();
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete transfer: $e');
    }
  }
}
