import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_card.freezed.dart';

enum CardType { debit, credit }

enum CardNetwork { visa, mastercard, amex, other }

/// A saved card summary. Never holds the full card number (kept in secure storage) or a CVV.
@freezed
abstract class BankCard with _$BankCard {
  const BankCard._();

  const factory BankCard({
    required String id,
    required String nickname,
    required String bankName,
    required CardType type,
    required CardNetwork network,
    required String last4,
    required int expiryMonth,
    required int expiryYear,
    required int colorValue,
    required DateTime createdAt,
  }) = _BankCard;

  /// Valid through the last day of the expiry month.
  bool isExpiredAt(DateTime now) =>
      !now.isBefore(DateTime(expiryYear, expiryMonth + 1));
}
