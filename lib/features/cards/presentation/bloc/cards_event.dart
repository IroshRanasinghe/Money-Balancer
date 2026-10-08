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
    required this.cardNumber,
    this.existingLast4,
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

  /// Digits only. May be empty only when editing (keeps the stored number).
  final String cardNumber;

  /// Existing card's last4 when editing; used when [cardNumber] is empty.
  final String? existingLast4;
  final int expiryMonth;
  final int expiryYear;
  final int colorValue;

  /// Never prints the full number.
  @override
  String toString() =>
      'CardSaveRequested(id: $id, nickname: $nickname, number: ${cardNumber.isEmpty ? 'none' : '••••'})';

  @override
  List<Object?> get props => [
        id,
        createdAt,
        nickname,
        bankName,
        type,
        network,
        cardNumber,
        existingLast4,
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

class CardNumberRevealRequested extends CardsEvent {
  const CardNumberRevealRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class CardNumberRevealDismissed extends CardsEvent {
  const CardNumberRevealDismissed();
}
