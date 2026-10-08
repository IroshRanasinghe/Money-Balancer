import 'package:freezed_annotation/freezed_annotation.dart';

part 'premium_package.freezed.dart';

@freezed
abstract class PremiumPackage with _$PremiumPackage {
  const factory PremiumPackage({
    required String id,
    required String title,
    required String priceString,

    /// 'monthly' | 'yearly' | other
    required String period,

    /// e.g. '7-day free trial'
    String? introOffer,
  }) = _PremiumPackage;
}
