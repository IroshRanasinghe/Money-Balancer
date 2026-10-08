import 'package:flutter/material.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.currencyCode,
    this.onTap,
  });

  final double balance;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: _circle(140, 0.12),
          ),
          Positioned(
            bottom: -50,
            right: 40,
            child: _circle(100, 0.08),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Total balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Spacer(),
                    Text(
                      'Accounts',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: balance),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatCurrency(value, currencyCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
}
