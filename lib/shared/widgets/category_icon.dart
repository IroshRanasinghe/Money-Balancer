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
    case 'Gift':
      return Icons.card_giftcard;
    default:
      return Icons.category;
  }
}
