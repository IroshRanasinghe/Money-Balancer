import 'package:flutter/material.dart';

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
    case 'Salary':
      return Icons.work;
    case 'Freelance':
      return Icons.laptop;
    case 'Business':
      return Icons.store;
    case 'Investment':
      return Icons.trending_up;
    case 'Gift':
      return Icons.card_giftcard;
    default:
      return Icons.category;
  }
}
