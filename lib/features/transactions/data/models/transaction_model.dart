import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.paymentMethod,
    this.notes,
    this.cardId,
    this.cardLast4,
    this.accountId,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  factory TransactionModel.fromEntity(Transaction t) => TransactionModel(
        id: t.id,
        amount: t.amount,
        category: t.category,
        date: t.date,
        type: t.type,
        paymentMethod: t.paymentMethod,
        notes: t.notes,
        cardId: t.cardId,
        cardLast4: t.cardLast4,
        accountId: t.accountId,
        createdAt: t.createdAt,
      );

  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final TransactionType type;
  final String? paymentMethod;
  final String? notes;
  final String? cardId;
  final String? cardLast4;
  final String? accountId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  Transaction toEntity() => Transaction(
        id: id,
        amount: amount,
        category: category,
        date: date,
        type: type,
        paymentMethod: paymentMethod,
        notes: notes,
        cardId: cardId,
        cardLast4: cardLast4,
        accountId: accountId,
        createdAt: createdAt,
      );
}
