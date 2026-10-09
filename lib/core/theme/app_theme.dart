import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_tokens.dart';

export 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static const fontFamily = 'PlusJakartaSans';

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static TextStyle _style(
    double size,
    double weight, {
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: FontWeight.values[(weight / 100).round() - 1],
    fontVariations: [FontVariation('wght', weight)],
    letterSpacing: letterSpacing,
    height: height,
  );

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
    displaySmall: _style(34, 800, letterSpacing: -0.8, height: 1.15),
    headlineSmall: _style(24, 800, letterSpacing: -0.4, height: 1.2),
    titleLarge: _style(20, 700, letterSpacing: -0.2),
    titleMedium: _style(16, 700),
    titleSmall: _style(14, 600),
    bodyLarge: _style(16, 500),
    bodyMedium: _style(14, 500),
    bodySmall: _style(12, 500),
    labelLarge: _style(14, 700),
    labelMedium: _style(12, 600),
    labelSmall: _style(11, 600, letterSpacing: 0.4),
  ).apply(bodyColor: primary, displayColor: primary);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final tokens = isDark ? AppTokens.dark : AppTokens.light;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          error: AppColors.danger,
          surface: tokens.surface,
          onSurface: tokens.textPrimary,
          onSurfaceVariant: tokens.textSecondary,
          outline: tokens.border,
          outlineVariant: tokens.border,
          surfaceTint: Colors.transparent,
          surfaceContainerLowest: tokens.background,
          surfaceContainerLow: tokens.surface,
          surfaceContainer: tokens.surface,
          surfaceContainerHigh: tokens.surfaceAlt,
          surfaceContainerHighest: tokens.surfaceAlt,
          inverseSurface: isDark
              ? const Color(0xFFE2E8F0)
              : AppColors.textPrimary,
          onInverseSurface: isDark ? AppColors.textPrimary : Colors.white,
        );
    final text = _textTheme(tokens.textPrimary, tokens.textSecondary);
    const stadium = StadiumBorder();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: tokens.background,
      canvasColor: tokens.background,
      extensions: [tokens],
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tokens.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: isDark ? BorderSide(color: tokens.border) : BorderSide.none,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: tokens.textSecondary),
        labelStyle: text.bodyMedium?.copyWith(color: tokens.textSecondary),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.danger, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: tokens.textPrimary,
          side: BorderSide(color: tokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: stadium,
          textStyle: text.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(stadium),
          side: WidgetStatePropertyAll(BorderSide(color: tokens.border)),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.primary.withValues(alpha: isDark ? 0.24 : 0.12)
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.primary
                : tokens.textSecondary,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: stadium,
        side: BorderSide.none,
        backgroundColor: tokens.surfaceAlt,
        selectedColor: AppColors.primary.withValues(
          alpha: isDark ? 0.28 : 0.14,
        ),
        labelStyle: text.labelLarge?.copyWith(color: tokens.textPrimary),
        secondaryLabelStyle: text.labelLarge?.copyWith(
          color: AppColors.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        showCheckmark: false,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: tokens.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: tokens.surfaceAlt,
        circularTrackColor: tokens.surfaceAlt,
        linearMinHeight: 8,
        borderRadius: BorderRadius.circular(999),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.border,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall?.copyWith(
          color: tokens.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _style(
          22,
          800,
          letterSpacing: -0.3,
        ).copyWith(color: tokens.textPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      ),
    );
  }
}
