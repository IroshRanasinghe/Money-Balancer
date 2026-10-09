import 'package:flutter/material.dart';

/// Raw palette. Prefer `context.tokens` (see `app_tokens.dart`) for anything
/// that must adapt to light/dark; these constants are for brand and semantic
/// hues and for legacy call sites.
class AppColors {
  const AppColors._();

  // Brand and semantic (same in both modes).
  static const primary = Color(0xFF2563EB);
  static const indigo = Color(0xFF4F46E5);
  static const violet = Color(0xFF7C3AED);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const orange = Color(0xFFF97316);

  // Light mode.
  static const background = Color(0xFFF5F7FB);
  static const card = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEEF2F8);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);

  // Dark mode.
  static const darkBackground = Color(0xFF0B1120);
  static const darkCard = Color(0xFF121A2B);
  static const darkSurfaceAlt = Color(0xFF1A2438);
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF24304A);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, indigo, violet],
  );

  static const premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, orange],
  );
}
