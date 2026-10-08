import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exceptions.dart';

abstract class CardNumberSecureDataSource {
  /// Null when no number is stored for [cardId].
  Future<String?> read(String cardId);
  Future<void> write(String cardId, String number);

  /// A missing entry is not an error.
  Future<void> delete(String cardId);
}

/// Stores full card numbers in the platform keystore (Keychain, Android
/// Keystore, etc.). On web the storage is browser-backed and weaker.
class SecureStorageCardNumberDataSource implements CardNumberSecureDataSource {
  SecureStorageCardNumberDataSource(this._storage);

  final FlutterSecureStorage _storage;

  String _key(String cardId) => 'card_number_$cardId';

  @override
  Future<String?> read(String cardId) async {
    try {
      return await _storage.read(key: _key(cardId));
    } catch (_) {
      throw const CacheException('Failed to read card number');
    }
  }

  @override
  Future<void> write(String cardId, String number) async {
    try {
      await _storage.write(key: _key(cardId), value: number);
    } catch (_) {
      throw const CacheException('Failed to save card number');
    }
  }

  @override
  Future<void> delete(String cardId) async {
    try {
      await _storage.delete(key: _key(cardId));
    } catch (_) {
      throw const CacheException('Failed to delete card number');
    }
  }
}
