import 'package:freezed_annotation/freezed_annotation.dart';

part 'premium_status.freezed.dart';

@freezed
abstract class PremiumStatus with _$PremiumStatus {
  const factory PremiumStatus({
    @Default(false) bool isPremium,
    DateTime? expiresAt,
    String? productId,
    @Default(false) bool storeAvailable,
  }) = _PremiumStatus;
}
