import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

enum TransactionType { expense, income }

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required double amount,
    required String category,
    required DateTime date,
    required TransactionType type,
    String? paymentMethod,
    String? notes,
    String? cardId,
    String? cardLast4,
    required DateTime createdAt,
  }) = _Transaction;
}
