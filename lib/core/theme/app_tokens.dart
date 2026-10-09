import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design tokens exposed through [ThemeData.extensions]. Read with
/// `context.tokens`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
    required this.successContainer,
    required this.warningContainer,
    required this.dangerContainer,
    required this.brandGradient,
    required this.premiumGradient,
    required this.cardShadow,
    required this.heroShadow,
    required this.glassColor,
    required this.glassBorder,
  });

  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color warning;
  final Color danger;
  final Color successContainer;
  final Color warningContainer;
  final Color dangerContainer;
  final LinearGradient brandGradient;
  final LinearGradient premiumGradient;

  /// Empty in dark mode (cards use a 1 px [border] instead).
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> heroShadow;
  final Color glassColor;
  final Color glassBorder;

  static const _heroShadow = [
    BoxShadow(
      color: Color(0x4D2563EB), // primary @ 30%
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
  ];

  static const light = AppTokens(
    isDark: false,
    background: AppColors.background,
    surface: AppColors.card,
    surfaceAlt: AppColors.surfaceAlt,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    successContainer: Color(0x1F22C55E), // 12%
    warningContainer: Color(0x1FF59E0B),
    dangerContainer: Color(0x1FEF4444),
    brandGradient: AppColors.brandGradient,
    premiumGradient: AppColors.premiumGradient,
    cardShadow: [
      BoxShadow(
        color: Color(0x0F0F172A), // 6%
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x080F172A), // 3%
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ],
    heroShadow: _heroShadow,
    glassColor: Color(0xB8FFFFFF), // 72%
    glassBorder: Color(0x66FFFFFF), // 40%
  );

  static const dark = AppTokens(
    isDark: true,
    background: AppColors.darkBackground,
    surface: AppColors.darkCard,
    surfaceAlt: AppColors.darkSurfaceAlt,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    border: AppColors.darkBorder,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    successContainer: Color(0x2E22C55E), // 18%
    warningContainer: Color(0x2EF59E0B),
    dangerContainer: Color(0x2EEF4444),
    brandGradient: AppColors.brandGradient,
    premiumGradient: AppColors.premiumGradient,
    cardShadow: [],
    heroShadow: _heroShadow,
    glassColor: Color(0x99121A2B), // 60% of dark surface
    glassBorder: Color(0x14FFFFFF), // 8%
  );

  @override
  AppTokens copyWith({
    bool? isDark,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
    Color? successContainer,
    Color? warningContainer,
    Color? dangerContainer,
    LinearGradient? brandGradient,
    LinearGradient? premiumGradient,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? heroShadow,
    Color? glassColor,
    Color? glassBorder,
  }) => AppTokens(
    isDark: isDark ?? this.isDark,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    border: border ?? this.border,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    successContainer: successContainer ?? this.successContainer,
    warningContainer: warningContainer ?? this.warningContainer,
    dangerContainer: dangerContainer ?? this.dangerContainer,
    brandGradient: brandGradient ?? this.brandGradient,
    premiumGradient: premiumGradient ?? this.premiumGradient,
    cardShadow: cardShadow ?? this.cardShadow,
    heroShadow: heroShadow ?? this.heroShadow,
    glassColor: glassColor ?? this.glassColor,
    glassBorder: glassBorder ?? this.glassBorder,
  );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      isDark: t < 0.5 ? isDark : other.isDark,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      brandGradient: LinearGradient.lerp(
        brandGradient,
        other.brandGradient,
        t,
      )!,
      premiumGradient: LinearGradient.lerp(
        premiumGradient,
        other.premiumGradient,
        t,
      )!,
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t)!,
      heroShadow: BoxShadow.lerpList(heroShadow, other.heroShadow, t)!,
      glassColor: Color.lerp(glassColor, other.glassColor, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
    );
  }
}

extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
