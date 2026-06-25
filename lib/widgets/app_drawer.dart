import 'package:ezi_cable_digi/core/services/localization_service.dart';
import 'package:ezi_cable_digi/core/services/theme_service.dart';
import 'package:ezi_cable_digi/features/expenses/list_expenses-screen.dart';
import 'package:ezi_cable_digi/features/offline/offline_dashboard_screen.dart';
import 'package:ezi_cable_digi/features/reports/mini_day_report_screen.dart';
import 'package:ezi_cable_digi/features/reports/search_collections_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../core/constants/app_colors.dart';
import '../core/services/offline_mode_service.dart';
import '../core/services/offline_sync_service.dart';
import '../core/widgets/premium_dialog.dart';
import '../features/auth/login_screen.dart';
import '../features/profile/user_profile_screen.dart';
import '../features/settings/printer_settings_screen.dart';
import '../features/search/search_customer_screen.dart';
import '../features/customers/nearest_customers_screen.dart';
import '../features/customers/customer_list_screen.dart';
import '../features/collections/collection_schedule_screen.dart';
import '../features/offline/download_records_screen.dart';
import '../features/offline/static_content_screen.dart';

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

// ── Language Picker bottom-sheet (theme-aware) ────────────────────────────────
void showLanguagePicker(BuildContext context) {
  final service = LocalizationService.instance;
  var isLoading = false;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) {
      final cs = Theme.of(sheetCtx).colorScheme;
      final isLight = ThemeService.instance.isPremiumLight;
      return StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: isLight ? Colors.white : const Color(0xFF0A1628),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isLight
                        ? Colors.grey.shade300
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language_rounded, color: cs.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.get('select_language'),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: isLight
                      ? Colors.grey.shade200
                      : Colors.white.withValues(alpha: 0.08),
                ),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        SizedBox(width: 12),
                        Text('Applying...'),
                      ],
                    ),
                  ),
                // Language list
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: AppLanguage.all.length,
                  itemBuilder: (_, index) {
                    final lang = AppLanguage.all[index];
                    return _LanguageTile(
                      language: lang,
                      isSelected: service.currentLanguage.code == lang.code,
                      isPremiumLight: isLight,
                      primaryColor: cs.primary,
                      isEnabled: !isLoading,
                      onTap: () async {
                        if (isLoading) return;
                        setSheetState(() => isLoading = true);
                        try {
                          await service.setLanguage(lang);
                          if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                        } finally {
                          if (sheetCtx.mounted) {
                            setSheetState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}

// ── Theme Picker — premium dialog ────────────────────────────────────────────
void showThemePicker(BuildContext context) {
  int selected = ThemeService.instance.themeIndex;
  var isSaving = false;
  showPremiumDialog<void>(
    context: context,
    child: StatefulBuilder(
      builder: (ctx2, setDlg) {
        return PremiumDialogShell(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.get('select_theme'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                // Radio tiles
                RadioListTile<int>(
                  value: 0,
                  groupValue: selected,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AppStrings.get('Theme 1'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onChanged: isSaving
                      ? null
                      : (v) {
                          if (v != null) setDlg(() => selected = v);
                        },
                ),
                RadioListTile<int>(
                  value: 1,
                  groupValue: selected,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AppStrings.get('Theme 2'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onChanged: isSaving
                      ? null
                      : (v) {
                          if (v != null) setDlg(() => selected = v);
                        },
                ),
                if (isSaving)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        SizedBox(width: 12),
                        Text('Applying...'),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving ? null : () => Navigator.pop(ctx2),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.get('cancel'),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                setDlg(() => isSaving = true);
                                try {
                                  await ThemeService.instance.setTheme(
                                    selected,
                                  );
                                  if (ctx2.mounted) Navigator.pop(ctx2);
                                } finally {
                                  if (ctx2.mounted) {
                                    setDlg(() => isSaving = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.get('apply'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  static String _s(String key) => AppStrings.get(key);
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService.instance,
      builder: (context, _) => _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Premium Header ────────────────────────────────────────────
            _PremiumDrawerHeader(
              onLogout: () {
                OfflineModeService.instance.setOfflineMode(false);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              onProfileTap: () => _closeDrawerThen(context, (navCtx) {
                Navigator.of(navCtx).push(
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                );
              }),
              userId: 'EDD00485',
              lastLogin: '2026-03-16  12:37:59',
              lastLoginLabel: _s('last_login'),
            ),

            const Divider(height: 1, thickness: 0.5),

            // ── Nav items ─────────────────────────────────────────────────
            _DrawerItem(icon: Iconsax.element_3, labelKey: 'dashboard'),
            _DrawerItem(
              icon: Iconsax.search_normal,
              labelKey: 'search_customer',
            ),
            _DrawerItem(icon: Iconsax.graph, labelKey: 'reports'),
            _DrawerItem(icon: Iconsax.location, labelKey: 'employee_track'),
            _DrawerItem(icon: Iconsax.setting_2, labelKey: 'settings'),
            _DrawerItem(icon: Iconsax.sun_1, labelKey: 'select_theme'),
            _DrawerItem(icon: Iconsax.user_tag, labelKey: 'customer_list'),
            _DrawerItem(
              icon: Iconsax.location_tick,
              labelKey: 'nearest_customer',
            ),
            _DrawerItem(icon: Iconsax.wallet_3, labelKey: 'list_expenses'),
            _DrawerItem(
              icon: Iconsax.calendar_1,
              labelKey: 'collection_schedule',
            ),
            _DrawerItem(
              icon: Iconsax.calendar_tick,
              labelKey: 'calendar_event_list',
            ),

            // ── Language picker ───────────────────────────────────────────
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 1,
              ),
              leading: const Icon(
                Icons.language,
                color: AppColors.primary,
                size: 20,
              ),
              title: Text(
                _s('language'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: Text(
                LocalizationService.instance.currentLanguage.flag,
                style: const TextStyle(fontSize: 18),
              ),
              onTap: () => showLanguagePicker(context),
            ),
            const Divider(height: 12, thickness: 0.5),
            // ── Offline Options ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
              child: Text(
                _s('offline_options'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 1,
              ),
              leading: const Icon(
                Icons.wifi_off,
                color: AppColors.primary,
                size: 20,
              ),
              title: Text(
                _s('switch_offline'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OfflineDashboardScreen(),
                  ),
                );
              },
            ),
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 1,
              ),
              leading: const Icon(
                Icons.download,
                color: AppColors.primary,
                size: 20,
              ),
              title: Text(
                _s('download_data'),
                style: const TextStyle(
                  fontSize: 14,
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
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 1,
              ),
              leading: const Icon(
                Icons.sync,
                color: AppColors.primary,
                size: 20,
              ),
              title: Text(
                _s('sync_clear'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {
                _closeDrawerThen(context, (navCtx) async {
                  final ok = await showPremiumConfirm(
                    context: navCtx,
                    title: _s('sync_confirm_title'),
                    body: _s('sync_confirm_body'),
                    confirmLabel: _s('ok'),
                    cancelLabel: _s('cancel'),
                  );
                  if (ok && navCtx.mounted) {
                    final n = await OfflineSyncService.instance
                        .syncPendingToServer();
                    if (navCtx.mounted) {
                      showPremiumSnackBar(
                        navCtx,
                        n > 0
                            ? _s('synced_records').replaceAll('{n}', '$n')
                            : _s('no_pending_records'),
                        isSuccess: n > 0,
                      );
                    }
                  }
                });
              },
            ),

            const Divider(height: 12, thickness: 0.5),

            // ── Other ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
              child: Text(
                _s('other'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 1,
              ),
              title: Text(_s('about_us'), style: const TextStyle(fontSize: 14)),
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
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 1,
              ),
              title: Text(
                _s('privacy_policy'),
                style: const TextStyle(fontSize: 14),
              ),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LanguageTile
// ─────────────────────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final bool isPremiumLight;
  final bool isEnabled;
  final Color primaryColor;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
    this.isPremiumLight = false,
    this.isEnabled = true,
    this.primaryColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isPremiumLight
        ? (isSelected ? primaryColor : const Color(0xFF1B1F3B))
        : (isSelected ? Colors.white : Colors.white70);
    final subtitleColor = isPremiumLight
        ? Colors.grey.shade500
        : Colors.white.withValues(alpha: 0.5);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha: isPremiumLight ? 0.08 : 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: primaryColor.withValues(alpha: 0.35),
                width: 1.2,
              )
            : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Text(language.flag, style: const TextStyle(fontSize: 26)),
        title: Text(
          language.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: textColor,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          language.englishName,
          style: TextStyle(fontSize: 12, color: subtitleColor),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: primaryColor, size: 22)
            : null,
        enabled: isEnabled,
        onTap: isEnabled ? onTap : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PremiumDrawerHeader — compact, exclusive, production-safe.
// No BackdropFilter / CustomPainter — pure Container + Stack for perf.
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumDrawerHeader extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onProfileTap;
  final String userId;
  final String lastLogin;
  final String lastLoginLabel;

  const _PremiumDrawerHeader({
    required this.onLogout,
    required this.onProfileTap,
    required this.userId,
    required this.lastLogin,
    required this.lastLoginLabel,
  });
  @override
  Widget build(BuildContext context) {
    // Derive initials from userId (e.g. "EDD00485" → "ED")
    final initials = userId.length >= 2
        ? userId.substring(0, 2).toUpperCase()
        : userId.toUpperCase();
    final topPadding = MediaQuery.of(context).padding.top;
    return GestureDetector(
      onTap: onProfileTap,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050E24), Color(0xFF0A2472), Color(0xFF1565C0)],
            stops: [0.0, 0.50, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ── Subtle decorative circles (pure Containers = zero GPU cost) ──
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16, topPadding + 22, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Row 1: Logo  +  Logout pill ───────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                            width: 0.8,
                          ),
                        ),
                        child: Image.asset(
                          'assets/ezy_digi_pics.png',
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const Spacer(),

                      // Logout pill
                      GestureDetector(
                        onTap: onLogout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.40),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.logout,
                                color: Colors.white,
                                size: 13,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'LOGOUT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Row 2: Avatar  +  User info ───────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar circle with initials
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                            width: 2.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // User ID + last login
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userId,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 11,
                                  color: Colors.white.withValues(alpha: 0.55),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '$lastLoginLabel  $lastLogin',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withValues(
                                        alpha: 0.55,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Chevron → profile hint
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.35),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DrawerItem — compact nav tiles with localised labels
// ─────────────────────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String labelKey;

  const _DrawerItem({required this.icon, required this.labelKey});

  @override
  Widget build(BuildContext context) {
    final label = AppStrings.get(labelKey);

    void handleTap() {
      _closeDrawerThen(context, (navCtx) {
        switch (labelKey) {
          case 'search_customer':
            Navigator.of(navCtx).push(
              MaterialPageRoute(builder: (_) => const SearchCustomerScreen()),
            );
            break;
          case 'settings':
            Navigator.of(navCtx).push(
              MaterialPageRoute(builder: (_) => const PrinterSettingsScreen()),
            );
            break;
          case 'nearest_customer':
            Navigator.of(navCtx).push(
              MaterialPageRoute(builder: (_) => const NearestCustomersScreen()),
            );
            break;
          case 'customer_list':
            Navigator.of(navCtx).push(
              MaterialPageRoute(builder: (_) => const CustomerListScreen()),
            );
            break;
          case 'list_expenses':
            Navigator.of(navCtx).push(
              MaterialPageRoute(builder: (_) => const ListExpensesScreen()),
            );
            break;
          case 'collection_schedule':
            Navigator.of(navCtx).push(
              MaterialPageRoute(
                builder: (_) => const CollectionScheduleScreen(),
              ),
            );
            break;
          case 'select_theme':
            showThemePicker(navCtx);
            break;
          case 'reports':
            showModalBottomSheet<void>(
              context: navCtx,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (ctx) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(AppStrings.get('employee_collections')),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          navCtx,
                          MaterialPageRoute(
                            builder: (_) => const SearchCollectionsScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: Text(AppStrings.get('miniday_report')),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          navCtx,
                          MaterialPageRoute(
                            builder: (_) => const MiniDayReportScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: Text(AppStrings.get('monthly_report')),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          navCtx,
                          MaterialPageRoute(
                            builder: (_) => const SearchCollectionsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
            break;
          default:
            break;
        }
      });
    }

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      leading: Icon(icon, size: 20, color: AppColors.primary),
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
