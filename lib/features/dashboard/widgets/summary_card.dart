import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final Color color;
  final String? lottieAsset;
  final bool hardVariant;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.color,
    this.lottieAsset,
    this.hardVariant = false,
  });

  @override
  Widget build(BuildContext context) {
    // "Light" variant keeps cards pastel like the reference.
    // "Hard" variant uses stronger alpha/border so cards look punchier.
    final a1 = hardVariant ? 0.42 : 0.16;
    final a2 = hardVariant ? 0.18 : 0.04;
    final borderA = hardVariant ? 1.0 : 0.85;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 96),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingS),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: a1),
              color.withValues(alpha: a2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: hardVariant
                ? Colors.white.withValues(alpha: 0.75)
                : AppColors.border.withValues(alpha: borderA),
            width: 0.7,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 10),
              blurRadius: 22,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hardVariant ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: hardVariant ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          hardVariant ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (lottieAsset != null) ...[
              const SizedBox(width: AppSizes.paddingS),
              SizedBox(
                height: 44,
                width: 44,
                child: Lottie.asset(
                  lottieAsset!,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

