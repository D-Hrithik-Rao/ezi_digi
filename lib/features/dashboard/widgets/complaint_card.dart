import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

enum ComplaintStatus { assigned, inProcess }

class ComplaintCard extends StatelessWidget {
  final String complaintId;
  final String name;
  final String description;
  final ComplaintStatus status;

  const ComplaintCard({
    super.key,
    required this.complaintId,
    required this.name,
    required this.description,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      ComplaintStatus.assigned => AppColors.success,
      ComplaintStatus.inProcess => AppColors.warning,
    };
    final statusText = switch (status) {
      ComplaintStatus.assigned => 'ASSIGNED',
      ComplaintStatus.inProcess => 'INPROCESS',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                complaintId,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: [
              const Icon(Iconsax.user, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Iconsax.edit, size: 16),
              label: const Text('Update Status'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

