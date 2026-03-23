import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/services/offline_mode_service.dart';
import '../core/services/offline_sync_service.dart';
import '../features/auth/login_screen.dart';
import '../features/profile/user_profile_screen.dart';
import '../features/settings/printer_settings_screen.dart';
import '../features/search/search_customer_screen.dart';
import '../features/customers/nearest_customers_screen.dart';
import '../features/offline/offline_dialogs.dart';
import '../features/offline/download_records_screen.dart';
import '../features/offline/static_content_screen.dart';

/// The [Drawer] is disposed when it closes — its [BuildContext] is no longer
/// [mounted]. Always use the [NavigatorState]'s context for the next route.
void _closeDrawerThen(
  BuildContext drawerContext,
  void Function(BuildContext navigatorContext) action,
) {
  final navigator = Navigator.of(drawerContext);
  navigator.pop();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (navigator.context.mounted) {
      action(navigator.context);
    }
  });
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: InkWell(
                onTap: () {
                  _closeDrawerThen(context, (navCtx) {
                    Navigator.of(navCtx).push(
                      MaterialPageRoute(
                        builder: (_) => const UserProfileScreen(),
                      ),
                    );
                  });
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
                  OfflineModeService.instance.setOfflineMode(false);
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
            const SizedBox(height: AppSizes.paddingS),
            const Divider(height: 1),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const Divider(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: 4,
                      ),
                      child: Text(
                        'OFFLINE OPTIONS',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.wifi_off,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      title: const Text(
                        'Switch to Offline Mode',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () {
                        _closeDrawerThen(context, (navCtx) async {
                          await showSwitchToOfflineDialog(navCtx);
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.download,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      title: const Text(
                        'Download Data(OFFLINE)',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () {
                        _closeDrawerThen(context, (navCtx) {
                          Navigator.push(
                            navCtx,
                            MaterialPageRoute(
                              builder: (_) => const DownloadRecordsScreen(),
                            ),
                          );
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.sync,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      title: const Text(
                        'Sync/Clear Data',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () {
                        _closeDrawerThen(context, (navCtx) async {
                          final ok = await showDialog<bool>(
                            context: navCtx,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Sync / Clear'),
                              content: const Text(
                                'Sync pending offline payments to server (demo) and mark them cleared locally?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('CANCEL'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true && navCtx.mounted) {
                            final n = await OfflineSyncService.instance
                                .syncPendingToServer();
                            if (navCtx.mounted) {
                              ScaffoldMessenger.of(navCtx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    n > 0
                                        ? 'Synced $n record(s) (demo — API later)'
                                        : 'No pending records to sync',
                                  ),
                                ),
                              );
                            }
                          }
                        });
                      },
                    ),
                    const Divider(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: 4,
                      ),
                      child: Text(
                        'Other',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('About Us'),
                      onTap: () {
                        _closeDrawerThen(context, (navCtx) {
                          Navigator.push(
                            navCtx,
                            MaterialPageRoute(
                              builder: (_) => const StaticContentScreen(
                                title: 'About Us',
                                body: kDummyAboutUs,
                              ),
                            ),
                          );
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Privacy Policy'),
                      onTap: () {
                        _closeDrawerThen(context, (navCtx) {
                          Navigator.push(
                            navCtx,
                            MaterialPageRoute(
                              builder: (_) => const StaticContentScreen(
                                title: 'Privacy Policy',
                                body: kDummyPrivacyPolicy,
                              ),
                            ),
                          );
                        });
                      },
                    ),
              ],
            ),
            ],
          ),
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
      _closeDrawerThen(context, (navCtx) {
        switch (label) {
          case 'Search Customer':
            Navigator.of(navCtx).push(
              MaterialPageRoute(
                builder: (_) => const SearchCustomerScreen(),
              ),
            );
            break;
          case 'Settings':
            Navigator.of(navCtx).push(
              MaterialPageRoute(
                builder: (_) => const PrinterSettingsScreen(),
              ),
            );
            break;
          case 'Nearest Customer':
            Navigator.of(navCtx).push(
              MaterialPageRoute(
                builder: (_) => const NearestCustomersScreen(),
              ),
            );
            break;
          default:
            break;
        }
      });
    }

    return ListTile(
      leading: Icon(
        icon,
        size: 22,
        color: AppColors.primary,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: handleTap,
    );
  }
}
