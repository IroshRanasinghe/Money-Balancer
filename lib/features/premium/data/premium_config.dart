class PremiumConfig {
  const PremiumConfig._();

  /// RevenueCat entitlement identifier that unlocks Premium.
  static const entitlementId = 'premium';

  /// Grants Premium to every user regardless of store entitlement.
  /// Build with --dart-define=PREMIUM_FOR_EVERYONE=false to restore paywalls.
  static const forEveryone =
      bool.fromEnvironment('PREMIUM_FOR_EVERYONE', defaultValue: true);

  /// Public SDK keys, supplied at build time with --dart-define.
  static const appleKey = String.fromEnvironment('REVENUECAT_APPLE_KEY');
  static const googleKey = String.fromEnvironment('REVENUECAT_GOOGLE_KEY');
}
