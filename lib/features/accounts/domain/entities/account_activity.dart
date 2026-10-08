import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../transactions/domain/entities/transaction.dart';
import 'transfer.dart';

part 'account_activity.freezed.dart';

/// One row in an account's history: either a transaction or a transfer.
/// [signedAmount] is the effect on the account balance.
@freezed
abstract class AccountActivity with _$AccountActivity {
  const factory AccountActivity({
    required DateTime date,
    required DateTime createdAt,
    required String title,
    required double signedAmount,
    Transaction? transaction,
    Transfer? transfer,
  }) = _AccountActivity;
}
