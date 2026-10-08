import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/card_model.dart';

abstract class CardLocalDataSource {
  List<CardModel> getAll();
  Future<void> put(CardModel model);

  /// Throws [NotFoundException] when [id] is absent.
  Future<void> delete(String id);
}

class HiveCardLocalDataSource implements CardLocalDataSource {
  HiveCardLocalDataSource(this._box);

  final Box<CardModel> _box;

  @override
  List<CardModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read cards: $e');
    }
  }

  @override
  Future<void> put(CardModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save card: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) throw const NotFoundException();
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete card: $e');
    }
  }
}
