import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/premium/premium_feature.dart';
import '../../../../core/utils/formatters.dart';
import '../../../premium/domain/usecases/check_premium_access.dart';
import '../../../settings/domain/usecases/get_settings.dart';
import '../entities/budget_progress.dart';
import '../repositories/budget_alert_repository.dart';
import 'get_budget_progress.dart';

/// Sends a local notification when a budget first reaches 80% and when it
/// first goes over 100% in a month. Premium only.
class CheckBudgetAlerts {
  const CheckBudgetAlerts(
    this._getProgress,
    this._checkPremium,
    this._getSettings,
    this._alerts,
    this._notifications,
  );

  final GetBudgetProgress _getProgress;
  final CheckPremiumAccess _checkPremium;
  final GetSettings _getSettings;
  final BudgetAlertRepository _alerts;
  final NotificationService _notifications;

  /// Returns the number of alerts sent. Right(0) when the user is not premium,
  /// alerts are switched off or settings can't be read.
  Future<Either<Failure, int>> call(DateTime date) async {
    final access = await _checkPremium(
      PremiumFeature.budgetAlerts,
      currentCount: 0,
    );
    if (access.isLeft()) return const Right(0);
    final settings = (await _getSettings()).toOption().toNullable();
    if (settings == null || !settings.budgetAlertsEnabled) {
      return const Right(0);
    }
    // Without OS permission a notification is silently dropped; record
    // nothing so the alerts still fire once permission is granted.
    if (!await _notifications.hasPermission()) return const Right(0);
    final progressResult = await _getProgress(
      month: date.month,
      year: date.year,
    );
    final items = progressResult.toOption().toNullable();
    if (items == null) {
      return Left(progressResult.swap().getOrElse(() => const CacheFailure()));
    }

    // One budget failing must not stop the others.
    var sent = 0;
    for (final item in items) {
      if (await _alert(item, date, settings.currency)) sent++;
    }
    return Right(sent);
  }

  /// Sends the alert for [item] if due. Returns true when one was shown.
  Future<bool> _alert(
    BudgetProgress item,
    DateTime date,
    String currency,
  ) async {
    final threshold = switch (item.status) {
      BudgetStatus.exceeded => 100,
      BudgetStatus.warning => 80,
      BudgetStatus.onTrack => 0,
    };
    if (threshold == 0) return false;
    final budget = item.budget;
    final prefix = '${budget.id}_${date.year}_${date.month}';
    final key = '${prefix}_$threshold';

    final already = await _alerts.wasSent(key);
    if (already.isLeft() || already.getOrElse(() => false)) return false;

    final String title;
    final String body;
    if (threshold == 100) {
      title = '${budget.category} budget exceeded';
      body = "You're ${formatCurrency(item.spent - budget.limit, currency)}"
          ' over your ${formatCurrency(budget.limit, currency)} budget.';
    } else {
      title = '${budget.category} budget at ${(item.ratio * 100).floor()}%';
      body = '${formatCurrency(item.remaining, currency)} left of '
          '${formatCurrency(budget.limit, currency)} this month.';
    }
    try {
      await _notifications.show(
        id: key.hashCode & 0x7fffffff,
        title: title,
        body: body,
      );
    } on NotificationException {
      return false;
    }

    final marked = await _alerts.markSent(key);
    if (marked.isLeft()) return true;
    if (threshold == 100) {
      // A later drop-and-rise must not send the stale 80% alert.
      await _alerts.markSent('${prefix}_80');
    }
    return true;
  }
}
