import 'package:equatable/equatable.dart';

import '../premium/premium_feature.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not access local storage.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Item not found.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AccountInUseFailure extends Failure {
  const AccountInUseFailure(
      [super.message =
          'This account has transactions or transfers. Remove them first.']);
}

class InvalidBackupFailure extends Failure {
  const InvalidBackupFailure(super.message);
}

class FileFailure extends Failure {
  const FileFailure([super.message = 'Could not open or save the file.']);
}

class PremiumRequiredFailure extends Failure {
  PremiumRequiredFailure(this.feature) : super(feature.paywallReason);

  final PremiumFeature feature;

  @override
  List<Object?> get props => [message, feature];
}

class PurchaseCancelledFailure extends Failure {
  const PurchaseCancelledFailure([super.message = 'Purchase cancelled.']);
}

class StoreUnavailableFailure extends Failure {
  const StoreUnavailableFailure(
      [super.message = "Purchases aren't available on this device."]);
}

class PurchaseFailure extends Failure {
  const PurchaseFailure(super.message);
}

class NotificationFailure extends Failure {
  const NotificationFailure([super.message = "Couldn't show the notification."]);
}
