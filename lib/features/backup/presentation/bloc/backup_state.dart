import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/premium/premium_feature.dart';

part 'backup_state.freezed.dart';

enum BackupStatus { idle, working, success, failure }

@freezed
abstract class BackupState with _$BackupState {
  const factory BackupState({
    @Default(BackupStatus.idle) BackupStatus status,
    String? message,
    @Default(0) int restoredCount,

    /// Incremented when a save hits a free-plan limit, so the page can open
    /// the paywall for [paywallFeature].
    @Default(0) int paywallCount,
    PremiumFeature? paywallFeature,
  }) = _BackupState;
}
