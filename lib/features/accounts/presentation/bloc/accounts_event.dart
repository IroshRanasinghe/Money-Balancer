import 'package:equatable/equatable.dart';

import '../../domain/entities/account.dart';

sealed class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

class AccountsLoadRequested extends AccountsEvent {
  const AccountsLoadRequested();
}

class AccountSaveRequested extends AccountsEvent {
  const AccountSaveRequested({
    this.id,
    required this.name,
    required this.type,
    required this.openingBalanceText,
    required this.colorValue,
    this.createdAt,
  });

  final String? id;
  final String name;
  final AccountType type;
  final String openingBalanceText;
  final int colorValue;

  /// Existing account's creation time when editing; null for a new account.
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    openingBalanceText,
    colorValue,
    createdAt,
  ];
}

class AccountDeleteRequested extends AccountsEvent {
  const AccountDeleteRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class TransferSaveRequested extends AccountsEvent {
  const TransferSaveRequested({
    this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amountText,
    required this.date,
    this.notes,
    this.createdAt,
  });

  final String? id;
  final String? fromAccountId;
  final String? toAccountId;
  final String amountText;
  final DateTime date;
  final String? notes;

  /// Existing transfer's creation time when editing; null for a new one.
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    fromAccountId,
    toAccountId,
    amountText,
    date,
    notes,
    createdAt,
  ];
}

class TransferDeleteRequested extends AccountsEvent {
  const TransferDeleteRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
