import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/data/models/transfer_model.dart';
import '../../../budget/data/models/budget_model.dart';
import '../../../cards/data/datasources/card_number_secure_datasource.dart';
import '../../../cards/data/models/card_model.dart';
import '../../../goals/data/models/goal_model.dart';
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
    this._goals,
    this._cardNumbers,
  );

  final Box<AppSettingsModel> _settings;
  final Box<TransactionModel> _transactions;
  final Box<BudgetModel> _budgets;
  final Box<CardModel> _cards;
  final Box<AccountModel> _accounts;
  final Box<TransferModel> _transfers;
  final Box<RecurringRuleModel> _recurring;
  final Box<GoalModel> _goals;
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
        'goals': _goals.values.map((m) => m.toJson()).toList(),
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
    if (version is! int) {
      throw const InvalidBackupException(
          'This file is not a Money Balance backup.');
    }
    if (version > _version) {
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
    final List<GoalModel> goals;
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
      goals = _parse(data, 'goals', GoalModel.fromJson);
    } catch (_) {
      throw const InvalidBackupException(_damaged);
    }

    final txMap = {for (final m in transactions) m.id: m};
    final budgetMap = {for (final m in budgets) m.id: m};
    final cardMap = {for (final m in cards) m.id: m};
    final accountMap = {for (final m in accounts) m.id: m};
    final transferMap = {for (final m in transfers) m.id: m};
    final ruleMap = {for (final m in rules) m.id: m};
    final goalMap = {for (final m in goals) m.id: m};

    final oldCardIds = _cards.keys.map((k) => k.toString()).toList();
    final snapshot = _Snapshot(
      transactions: Map<dynamic, TransactionModel>.of(_transactions.toMap()),
      budgets: Map<dynamic, BudgetModel>.of(_budgets.toMap()),
      cards: Map<dynamic, CardModel>.of(_cards.toMap()),
      accounts: Map<dynamic, AccountModel>.of(_accounts.toMap()),
      transfers: Map<dynamic, TransferModel>.of(_transfers.toMap()),
      rules: Map<dynamic, RecurringRuleModel>.of(_recurring.toMap()),
      goals: Map<dynamic, GoalModel>.of(_goals.toMap()),
      settings: _settings.get(HiveSettingsLocalDataSource.settingsKey),
    );
    try {
      await _replace(_transactions, txMap);
      await _replace(_budgets, budgetMap);
      await _replace(_cards, cardMap);
      await _replace(_accounts, accountMap);
      await _replace(_transfers, transferMap);
      await _replace(_recurring, ruleMap);
      await _replace(_goals, goalMap);
      if (settings != null) {
        await _settings.put(HiveSettingsLocalDataSource.settingsKey, settings);
      }
    } catch (e) {
      await _rollback(snapshot);
      throw CacheException('Failed to restore data: $e');
    }

    // Only after every write succeeded.
    for (final id in oldCardIds) {
      if (cardMap.containsKey(id)) continue;
      try {
        await _cardNumbers.delete(id);
      } catch (_) {}
    }

    return BackupCounts(
      transactions: txMap.length,
      budgets: budgetMap.length,
      cards: cardMap.length,
      accounts: accountMap.length,
      transfers: transferMap.length,
      recurringRules: ruleMap.length,
      goals: goalMap.length,
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

  Future<void> _rollback(_Snapshot s) async {
    Future<void> restore<T>(Box<T> box, Map<dynamic, T> entries) async {
      try {
        await box.clear();
        await box.putAll(entries);
      } catch (_) {}
    }

    await restore(_transactions, s.transactions);
    await restore(_budgets, s.budgets);
    await restore(_cards, s.cards);
    await restore(_accounts, s.accounts);
    await restore(_transfers, s.transfers);
    await restore(_recurring, s.rules);
    await restore(_goals, s.goals);
    final settings = s.settings;
    if (settings != null) {
      try {
        await _settings.put(HiveSettingsLocalDataSource.settingsKey, settings);
      } catch (_) {}
    }
  }

  Future<void> _replace<T>(Box<T> box, Map<String, T> entries) async {
    await box.clear();
    await box.putAll(entries);
  }
}

class _Snapshot {
  const _Snapshot({
    required this.transactions,
    required this.budgets,
    required this.cards,
    required this.accounts,
    required this.transfers,
    required this.rules,
    required this.goals,
    required this.settings,
  });

  final Map<dynamic, TransactionModel> transactions;
  final Map<dynamic, BudgetModel> budgets;
  final Map<dynamic, CardModel> cards;
  final Map<dynamic, AccountModel> accounts;
  final Map<dynamic, TransferModel> transfers;
  final Map<dynamic, RecurringRuleModel> rules;
  final Map<dynamic, GoalModel> goals;
  final AppSettingsModel? settings;
}
