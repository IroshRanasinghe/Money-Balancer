import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/premium_package.dart';
import '../../domain/entities/premium_status.dart';

part 'premium_state.freezed.dart';

enum PremiumBusy { none, purchasing, restoring }

@freezed
abstract class PremiumState with _$PremiumState {
  const factory PremiumState({
    @Default(PremiumStatus()) PremiumStatus status,
    @Default(<PremiumPackage>[]) List<PremiumPackage> packages,
    @Default(PremiumBusy.none) PremiumBusy busy,
    String? message,
    @Default(false) bool packagesLoading,
  }) = _PremiumState;
}
