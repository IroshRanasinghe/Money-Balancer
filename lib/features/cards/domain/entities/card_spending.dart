import 'package:freezed_annotation/freezed_annotation.dart';

import 'bank_card.dart';

part 'card_spending.freezed.dart';

@freezed
abstract class CardSpending with _$CardSpending {
  const factory CardSpending({
    required BankCard card,
    required double spent,
  }) = _CardSpending;
}
