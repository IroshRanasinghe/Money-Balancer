import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/data/models/transfer_model.dart';
import '../../../budget/data/models/budget_model.dart';
import '../../../cards/data/datasources/card_number_secure_datasource.dart';
import '../../../cards/data/models/card_model.dart';
import '../../../recurring/data/models/recurring_rule_model.dart';
import '../../../settings/data/datasources/settings_local_datasource.dart';
import '../../../settings/data/models/app_settings_model.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/backup_counts.dart';

const _appId = 'money_balance';
const _version = 1;
const _damaged = 'This backup file is damaged or incomplete.';

abstract class BackupLocalDataSource {
  Map<String, dynamic> exportAll(DateTime now);

  /// Validates and parses everything first; only then replaces the boxes.
  Future<BackupCounts> replaceAll(Map<String, dynamic> data);
}

class HiveBackupLocalDataSource implements BackupLocalDataSource {
  HiveBackupLocalDataSource(
    this._settings,
    this._transactions,
    this._budgets,
    this._cards,
    this._accounts,
    this._transfers,
    this._recurring,
    this._cardNumbers,
  );

  final Box<AppSettingsModel> _settings;
  final Box<TransactionModel> _transactions;
  final Box<BudgetModel> _budgets;
  final Box<CardModel> _cards;
  final Box<AccountModel> _accounts;
  final Box<TransferModel> _transfers;
  final Box<RecurringRuleModel> _recurring;
  final CardNumberSecureDataSource _cardNumbers;

  @override
  Map<String, dynamic> exportAll(DateTime now) {
    try {
      return {
        'app': _appId,
        'version': _version,
        'exportedAt': now.toIso8601String(),
        'settings':
            _settings.get(HiveSettingsLocalDataSource.settingsKey)?.toJson(),
        'transactions': _transactions.values.map((m) => m.toJson()).toList(),
        'budgets': _budgets.values.map((m) => m.toJson()).toList(),
        'cards': _cards.values.map((m) => m.toJson()).toList(),
        'accounts': _accounts.values.map((m) => m.toJson()).toList(),
        'transfers': _transfers.values.map((m) => m.toJson()).toList(),
        'recurringRules': _recurring.values.map((m) => m.toJson()).toList(),
      };
    } catch (e) {
      throw CacheException('Failed to read data for backup: $e');
    }
  }

  @override
  Future<BackupCounts> replaceAll(Map<String, dynamic> data) async {
    if (data['app'] != _appId) {
      throw const InvalidBackupException('This is not a Money Balance backup.');
    }
    final version = data['version'];
    if (version is! int || version > _version) {
      throw const InvalidBackupException(
          'This backup was made by a newer version of the app.');
    }

    final AppSettingsModel? settings;
    final List<TransactionModel> transactions;
    final List<BudgetModel> budgets;
    final List<CardModel> cards;
    final List<AccountModel> accounts;
    final List<TransferModel> transfers;
    final List<RecurringRuleModel> rules;
    try {
      final rawSettings = data['settings'];
      settings = rawSettings == null
          ? null
          : AppSettingsModel.fromJson(
              Map<String, dynamic>.from(rawSettings as Map));
      transactions = _parse(data, 'transactions', TransactionModel.fromJson);
      budgets = _parse(data, 'budgets', BudgetModel.fromJson);
      cards = _parse(data, 'cards', CardModel.fromJson);
      accounts = _parse(data, 'accounts', AccountModel.fromJson);
      transfers = _parse(data, 'transfers', TransferModel.fromJson);
      rules = _parse(data, 'recurringRules', RecurringRuleModel.fromJson);
    } catch (_) {
      throw const InvalidBackupException(_damaged);
    }

    final List<String> oldCardIds;
    try {
      oldCardIds = _cards.keys.map((k) => k.toString()).toList();
      await _replace(_transactions, {for (final m in transactions) m.id: m});
      await _replace(_budgets, {for (final m in budgets) m.id: m});
      await _replace(_cards, {for (final m in cards) m.id: m});
      await _replace(_accounts, {for (final m in accounts) m.id: m});
      await _replace(_transfers, {for (final m in transfers) m.id: m});
      await _replace(_recurring, {for (final m in rules) m.id: m});
      if (settings != null) {
        await _settings.put(HiveSettingsLocalDataSource.settingsKey, settings);
      }
    } catch (e) {
      throw CacheException('Failed to restore data: $e');
    }

    final newCardIds = {for (final c in cards) c.id};
    for (final id in oldCardIds) {
      if (newCardIds.contains(id)) continue;
      try {
        await _cardNumbers.delete(id);
      } catch (_) {}
    }

    return BackupCounts(
      transactions: transactions.length,
      budgets: budgets.length,
      cards: cards.length,
      accounts: accounts.length,
      transfers: transfers.length,
      recurringRules: rules.length,
    );
  }

  List<T> _parse<T>(Map<String, dynamic> data, String key,
      T Function(Map<String, dynamic>) fromJson) {
    final raw = data[key];
    if (raw == null) return <T>[];
    return (raw as List)
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _replace<T>(Box<T> box, Map<String, T> entries) async {
    await box.clear();
    await box.putAll(entries);
  }
}
