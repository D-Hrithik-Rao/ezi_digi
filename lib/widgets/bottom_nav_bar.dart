import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../core/constants/app_colors.dart';

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
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onChanged,
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withValues(alpha: 0.08),
      destinations: const [
        NavigationDestination(
          icon: Icon(Iconsax.element_3),
          selectedIcon: Icon(Iconsax.element_3, color: AppColors.primary),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Iconsax.user),
          selectedIcon: Icon(Iconsax.user, color: AppColors.primary),
          label: 'Customers',
        ),
        NavigationDestination(
          icon: Icon(Iconsax.graph),
          selectedIcon: Icon(Iconsax.graph, color: AppColors.primary),
          label: 'Reports',
        ),
        NavigationDestination(
          icon: Icon(Iconsax.wallet_3),
          selectedIcon: Icon(Iconsax.wallet_3, color: AppColors.primary),
          label: 'Collection',
        ),
      ],
    );
  }
}

