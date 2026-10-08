import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../premium/domain/entities/premium_feature.dart';
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

    /// SENSITIVE full card number. Never log this state (a BlocObserver
    /// would print it).
    String? revealedNumber,

    /// Incremented when a save hits a free-plan limit, so the page can open
    /// the paywall for [paywallFeature].
    @Default(0) int paywallCount,
    PremiumFeature? paywallFeature,
  }) = _CardsState;
}
