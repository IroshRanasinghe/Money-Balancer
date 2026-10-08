import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/transfer.dart';

part 'transfer_model.g.dart';

@JsonSerializable()
class TransferModel {
  const TransferModel({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) =>
      _$TransferModelFromJson(json);

  factory TransferModel.fromEntity(Transfer t) => TransferModel(
    id: t.id,
    fromAccountId: t.fromAccountId,
    toAccountId: t.toAccountId,
    amount: t.amount,
    date: t.date,
    notes: t.notes,
    createdAt: t.createdAt,
  );

  final String id;
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$TransferModelToJson(this);

  Transfer toEntity() => Transfer(
    id: id,
    fromAccountId: fromAccountId,
    toAccountId: toAccountId,
    amount: amount,
    date: date,
    notes: notes,
    createdAt: createdAt,
  );
}
