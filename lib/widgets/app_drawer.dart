import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../features/auth/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.12),
                    child: Image.asset(
                      'assets/ezy_digi_pics.png',
                      height: 32,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Employee ID: EMP1023',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Last login: Today 09:32 AM',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                ),
                icon: const Icon(Iconsax.logout),
                label: const Text('Logout'),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            const Divider(height: 1),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _DrawerItem(
                      icon: Iconsax.element_3,
                      label: 'Dashboard',
                    ),
                    _DrawerItem(
                      icon: Iconsax.search_normal,
                      label: 'Search Customer',
                    ),
                    _DrawerItem(
                      icon: Iconsax.graph,
                      label: 'Reports',
                    ),
                    _DrawerItem(
                      icon: Iconsax.location,
                      label: 'Employee Track',
                    ),
                    _DrawerItem(
                      icon: Iconsax.setting_2,
                      label: 'Settings',
                    ),
                    _DrawerItem(
                      icon: Iconsax.sun_1,
                      label: 'Select Theme',
                    ),
                    _DrawerItem(
                      icon: Iconsax.user_tag,
                      label: 'Customer List',
                    ),
                    _DrawerItem(
                      icon: Iconsax.location_tick,
                      label: 'Nearest Customer',
                    ),
                    _DrawerItem(
                      icon: Iconsax.wallet_3,
                      label: 'List Expenses',
                    ),
                    _DrawerItem(
                      icon: Iconsax.calendar_1,
                      label: 'Collection Schedule',
                    ),
                    _DrawerItem(
                      icon: Iconsax.calendar_tick,
                      label: 'Calendar Event List',
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              child: Text(
                'Offline Options',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DrawerItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: AppColors.textSecondary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}

