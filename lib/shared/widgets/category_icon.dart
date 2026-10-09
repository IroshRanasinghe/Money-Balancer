import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'ui/icon_badge.dart';

IconData categoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant;
    case 'Transport':
      return Icons.directions_car;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Bills':
      return Icons.receipt;
    case 'Entertainment':
      return Icons.movie;
    case 'Health':
      return Icons.favorite;
    case 'Education':
      return Icons.school;
    case 'Groceries':
      return Icons.local_grocery_store;
    case 'Fuel':
      return Icons.local_gas_station;
    case 'Rent':
      return Icons.home;
    case 'Lease':
      return Icons.key;
    case 'Utilities':
      return Icons.bolt;
    case 'Subscriptions':
      return Icons.subscriptions;
    case 'Travel':
      return Icons.flight;
    case 'Fitness':
      return Icons.fitness_center;
    case 'Personal Care':
      return Icons.spa;
    case 'Insurance':
      return Icons.shield;
    case 'Kids':
      return Icons.child_care;
    case 'Pets':
      return Icons.pets;
    case 'Donations':
      return Icons.volunteer_activism;
    case 'Loan Payments':
      return Icons.account_balance;
    case 'Salary':
      return Icons.work;
    case 'Freelance':
      return Icons.laptop;
    case 'Business':
      return Icons.store;
    case 'Investment':
      return Icons.trending_up;
    case 'Uber':
      return Icons.local_taxi;
    case 'PickMe':
      return Icons.hail;
    case 'Uber Eats':
      return Icons.delivery_dining;
    case 'PickMe Eats':
      return Icons.fastfood;
    case 'Credit Card':
      return Icons.credit_card;
    case 'Pawn':
      return Icons.diamond;
    case 'Gift':
      return Icons.card_giftcard;
    default:
      return Icons.category;
  }
}

const _categoryColors = <String, Color>{
  'Food': Color(0xFFF97316),
  'Groceries': Color(0xFF84CC16),
  'Transport': Color(0xFF0EA5E9),
  'Fuel': Color(0xFFEAB308),
  'Shopping': Color(0xFFEC4899),
  'Rent': Color(0xFF8B5CF6),
  'Lease': Color(0xFF6366F1),
  'Bills': Color(0xFF14B8A6),
  'Utilities': Color(0xFFF59E0B),
  'Subscriptions': Color(0xFFE11D48),
  'Entertainment': Color(0xFFA855F7),
  'Travel': Color(0xFF06B6D4),
  'Health': Color(0xFFEF4444),
  'Fitness': Color(0xFF22C55E),
  'Personal Care': Color(0xFFF472B6),
  'Insurance': Color(0xFF0891B2),
  'Education': Color(0xFF3B82F6),
  'Kids': Color(0xFFFB923C),
  'Pets': Color(0xFFB45309),
  'Donations': Color(0xFFDB2777),
  'Loan Payments': Color(0xFFC2410C),
  'Uber': Color(0xFF334155),
  'PickMe': Color(0xFFFACC15),
  'Uber Eats': Color(0xFF10B981),
  'PickMe Eats': Color(0xFFF43F5E),
  'Credit Card': Color(0xFF4F46E5),
  'Pawn': Color(0xFFCA8A04),
  'Salary': Color(0xFF16A34A),
  'Freelance': Color(0xFF0D9488),
  'Business': Color(0xFF7C3AED),
  'Investment': Color(0xFF2563EB),
  'Gift': Color(0xFFD946EF),
};

/// Brand logos shown in place of a Material icon for these categories.
const _categoryLogos = <String, String>{
  'Uber': 'assets/images/categories/uber.png',
  'Uber Eats': 'assets/images/categories/uber_eats.png',
};

/// Stable per-category hue; unknown categories (and "Other") use the primary.
Color categoryColor(String category) =>
    _categoryColors[category] ?? AppColors.primary;

/// [IconBadge] for [category] in its own colour.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 44});

  final String category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logo = _categoryLogos[category];
    if (logo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size < 40 ? 11 : 14),
        child: Image.asset(
          logo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      );
    }
    return IconBadge(
      icon: categoryIcon(category),
      color: categoryColor(category),
      size: size,
    );
  }
}
