import 'package:equatable/equatable.dart';

import '../../domain/entities/bank_card.dart';

sealed class CardsEvent extends Equatable {
  const CardsEvent();

  @override
  List<Object?> get props => [];
}

class CardsLoadRequested extends CardsEvent {
  const CardsLoadRequested();
}

class CardSaveRequested extends CardsEvent {
  const CardSaveRequested({
    this.id,
    this.createdAt,
    required this.nickname,
    required this.bankName,
    required this.type,
    required this.network,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.colorValue,
  });

  final String? id;

  /// Existing card's creation time when editing; null for a new card.
  final DateTime? createdAt;
  final String nickname;
  final String bankName;
  final CardType type;
  final CardNetwork network;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final int colorValue;

  @override
  List<Object?> get props => [
        id,
        createdAt,
        nickname,
        bankName,
        type,
        network,
        last4,
        expiryMonth,
        expiryYear,
        colorValue,
      ];
}

class CardDeleteRequested extends CardsEvent {
  const CardDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
