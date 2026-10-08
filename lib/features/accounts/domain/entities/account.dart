import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';

enum AccountType {
  cash('Cash'),
  bank('Bank'),
  savings('Savings'),
  wallet('Wallet'),
  other('Other');

  const AccountType(this.label);

  final String label;
}

@freezed
abstract class Account with _$Account {
  const factory Account({
    required String id,
    required String name,
    required AccountType type,
    required double openingBalance,
    required int colorValue,
    required DateTime createdAt,
  }) = _Account;
}
