import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../core/constants/app_colors.dart';
import '../core/services/localization_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM BOTTOM NAVIGATION BAR
// Matches the grey/white style in the reference photo:
// white background, pill highlight on active icon, vivid blue active colour.
// ─────────────────────────────────────────────────────────────────────────────
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Iconsax.element_3,  activeIcon: Iconsax.element_3,  label: AppStrings.of(context, 'dashboard')),
      _NavItem(icon: Iconsax.user_add,    activeIcon: Iconsax.user_add,   label: AppStrings.of(context, 'customers')),
      _NavItem(icon: Iconsax.graph,       activeIcon: Iconsax.graph,      label: AppStrings.of(context, 'reports')),
      _NavItem(icon: Iconsax.wallet_3,    activeIcon: Iconsax.wallet_3,   label: AppStrings.of(context, 'expenses')),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Icon with animated pill background ─────────────
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 6),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            items[i].icon,
                            size: 22,
                            color: active
                                ? AppColors.primary
                                : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // ── Label ──────────────────────────────────────────
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: active
                                ? AppColors.primary
                                : Colors.grey.shade500,
                          ),
                          child: Text(items[i].label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
