import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../features/auth/login_screen.dart';
import '../features/profile/user_profile_screen.dart';
import '../features/settings/printer_settings_screen.dart';
import '../features/search/search_customer_screen.dart';

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
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserProfileScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0288D1), Color(0xFF26C6DA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.15),
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
                            'EDD00485 (tap for profile)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Last Login - 2026-03-16 10:28:56',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
    void handleTap() {
      Navigator.of(context).pop();
      switch (label) {
        case 'Search Customer':
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SearchCustomerScreen(),
            ),
          );
          break;
        case 'Settings':
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PrinterSettingsScreen(),
            ),
          );
          break;
        default:
          break;
      }
    }

    return ListTile(
      leading: Icon(icon, size: 20, color: AppColors.textSecondary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: handleTap,
    );
  }
}

