import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/card_spending.dart';

part 'cards_state.freezed.dart';

enum CardsStatus { initial, loading, success, failure }

@freezed
abstract class CardsState with _$CardsState {
  const factory CardsState({
    @Default(CardsStatus.initial) CardsStatus status,
    @Default(<CardSpending>[]) List<CardSpending> items,
    String? errorMessage,

    /// Set only while the reveal dialog is open; cleared on dismiss.
    String? revealedCardId,
    String? revealedNumber,
  }) = _CardsState;
}
