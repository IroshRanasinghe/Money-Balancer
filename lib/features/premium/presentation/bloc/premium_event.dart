import 'package:equatable/equatable.dart';

import '../../domain/entities/premium_status.dart';

sealed class PremiumEvent extends Equatable {
  const PremiumEvent();

  @override
  List<Object?> get props => [];
}

class PremiumStarted extends PremiumEvent {
  const PremiumStarted();
}

class PremiumPurchaseRequested extends PremiumEvent {
  const PremiumPurchaseRequested(this.packageId);
  final String packageId;
  @override
  List<Object?> get props => [packageId];
}

class PremiumRestoreRequested extends PremiumEvent {
  const PremiumRestoreRequested();
}

/// Debug builds only; a no-op otherwise.
class PremiumDebugToggled extends PremiumEvent {
  const PremiumDebugToggled(this.enabled);
  final bool enabled;
  @override
  List<Object?> get props => [enabled];
}

/// Emitted by the status stream subscription.
class PremiumStatusPushed extends PremiumEvent {
  const PremiumStatusPushed(this.status);
  final PremiumStatus status;
  @override
  List<Object?> get props => [status];
}
