import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_counts.freezed.dart';

@freezed
abstract class BackupCounts with _$BackupCounts {
  const factory BackupCounts({
    required int transactions,
    required int budgets,
    required int cards,
    required int accounts,
    required int transfers,
    required int recurringRules,
  }) = _BackupCounts;
}
