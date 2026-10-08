import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/transaction.dart';

part 'transaction_state.freezed.dart';

enum TransactionListStatus { initial, loading, success, failure }

enum TransactionSort { newest, oldest, highest, lowest }

@freezed
abstract class TransactionState with _$TransactionState {
  const TransactionState._();

  const factory TransactionState({
    @Default(TransactionListStatus.initial) TransactionListStatus status,
    @Default(<Transaction>[]) List<Transaction> all,
    TransactionType? typeFilter,
    String? categoryFilter,
    @Default(TransactionSort.newest) TransactionSort sort,
    String? errorMessage,
  }) = _TransactionState;

  List<Transaction> get visible {
    final filtered = all.where((t) =>
        (typeFilter == null || t.type == typeFilter) &&
        (categoryFilter == null || t.category == categoryFilter));
    final list = filtered.toList();
    switch (sort) {
      case TransactionSort.newest:
        list.sort((a, b) => b.date.compareTo(a.date));
      case TransactionSort.oldest:
        list.sort((a, b) => a.date.compareTo(b.date));
      case TransactionSort.highest:
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case TransactionSort.lowest:
        list.sort((a, b) => a.amount.compareTo(b.amount));
    }
    return list;
  }
}
