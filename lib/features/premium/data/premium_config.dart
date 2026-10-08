class PremiumConfig {
  const PremiumConfig._();

  /// RevenueCat entitlement identifier that unlocks Premium.
  static const entitlementId = 'premium';

  /// Public SDK keys, supplied at build time with --dart-define.
  static const appleKey = String.fromEnvironment('REVENUECAT_APPLE_KEY');
  static const googleKey = String.fromEnvironment('REVENUECAT_GOOGLE_KEY');
}
