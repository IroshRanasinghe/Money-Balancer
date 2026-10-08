enum PremiumFeature {
  accounts,
  cards,
  budgets,
  recurring,
  goals,
  csvExport,
  budgetAlerts;

  String get paywallReason => switch (this) {
        PremiumFeature.accounts => 'Free plan includes 2 accounts.',
        PremiumFeature.cards => 'Free plan includes 2 saved cards.',
        PremiumFeature.budgets => 'Free plan includes 5 budgets per month.',
        PremiumFeature.recurring => 'Free plan includes 3 recurring items.',
        PremiumFeature.goals => 'Free plan includes 1 savings goal.',
        PremiumFeature.csvExport => 'CSV export is a Premium feature.',
        PremiumFeature.budgetAlerts => 'Budget alerts are a Premium feature.',
      };
}
