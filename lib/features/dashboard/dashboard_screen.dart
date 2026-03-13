import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'widgets/complaint_card.dart';
import 'widgets/summary_card.dart';
import '../auth/login_screen.dart';
import '../customers/customer_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Iconsax.menu_1),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/ezy_digi_pics.png',
              height: 36,
            ),
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          const Icon(Iconsax.search_normal),
          const SizedBox(width: 8),
          const Icon(Iconsax.bluetooth),
          const SizedBox(width: 8),
          const Icon(Iconsax.calendar_1),
          const SizedBox(width: 8),
          const Icon(Iconsax.scan_barcode),
          const SizedBox(width: 8),
         
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedTab,
        onChanged: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
      ),
      body: _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 390;
              final gap = isTight ? 8.0 : AppSizes.paddingS;
              const lcoWalletPurple = Color(0xFF7C4DFF);

              Widget card({
                required String title,
                required String amount,
                required String subtitle,
                required Color color,
                String? lottieAsset,
              }) {
                return SummaryCard(
                  title: title,
                  amount: amount,
                  subtitle: subtitle,
                  color: color,
                  lottieAsset: lottieAsset,
                );
              }

              // Requested layout:
              // Row 1: Due Amount + Month Billing + Onetime Charges
              // Row 2: LCO Wallet + Collections
              //
              // On very small widths we gracefully wrap while keeping order.
              if (isTight) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: card(
                            title: 'Due Amount',
                            amount: '₹ 24,560',
                            subtitle: '120 customers',
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: card(
                            title: 'Month Billing',
                            amount: '₹ 1,20,000',
                            subtitle: 'This month',
                            color: const Color.fromARGB(255, 243, 35, 8),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: gap),
                    Row(
                      children: [
                        Expanded(
                          child: card(
                            title: 'Onetime Charges',
                            amount: '₹ 8,450',
                            subtitle: 'Installations',
                            color: const Color.fromARGB(255, 245, 66, 185),
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: card(
                            title: 'LCO Wallet',
                            amount: '₹ 1,532',
                            subtitle: 'Available',
                            color: lcoWalletPurple,
                            lottieAsset: 'assets/register.json',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: gap),
                    Row(
                      children: [
                        Expanded(
                          child: card(
                            title: 'Collections',
                            amount: '₹ 92,610',
                            subtitle: 'Today',
                            color: AppColors.accent,
                            lottieAsset: 'assets/Growth Chart.json',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: card(
                          title: 'Due Amount',
                          amount: '₹ 24,560',
                          subtitle: '120 customers',
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: card(
                          title: 'Month Billing',
                          amount: '₹ 1,20,000',
                          subtitle: 'This month',
                          color: AppColors.accent,
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: card(
                          title: 'Onetime Charges',
                          amount: '₹ 8,450',
                          subtitle: 'Installations',
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  Row(
                    children: [
                      Expanded(
                        child: card(
                          title: 'LCO Wallet',
                          amount: '₹ 15,320',
                          subtitle: 'Available',
                          color: lcoWalletPurple,
                          lottieAsset: 'assets/register.json',
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: card(
                          title: 'Collections',
                          amount: '₹ 92,610',
                          subtitle: 'Today',
                          color: AppColors.accent,
                          lottieAsset: 'assets/Growth Chart.json',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSizes.paddingL),
          _DashboardActionStrip(
            onCustomerList: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerListScreen()),
              );
            },
            onDownloadData: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download Data (coming soon)')),
              );
            },
            onOfflineSearch: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offline Search (coming soon)')),
              );
            },
            onMinidayReport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Miniday Report (coming soon)')),
              );
            },
            onMonthlyReport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Monthly Report (coming soon)')),
              );
            },
            onSettings: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings (coming soon)')),
              );
            },
          ),
          const SizedBox(height: AppSizes.paddingM),
          const _DashboardFilterChips(),
          const SizedBox(height: AppSizes.paddingL),
          const Text(
            'Complaints',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          const ComplaintCard(
            complaintId: 'CMP-10234',
            name: 'Rahul Sharma',
            description: 'No signal since morning, set top box not responding.',
            status: ComplaintStatus.assigned,
          ),
          const ComplaintCard(
            complaintId: 'CMP-10231',
            name: 'Priya Verma',
            description: 'HD channels are not working on primary TV.',
            status: ComplaintStatus.inProcess,
          ),
          const ComplaintCard(
            complaintId: 'CMP-10228',
            name: 'Ankit Jain',
            description: 'Billing mismatch for last month statement.',
            status: ComplaintStatus.assigned,
          ),
        ],
      ),
    );
  }
}

class _DashboardActionStrip extends StatelessWidget {
  final VoidCallback onCustomerList;
  final VoidCallback onDownloadData;
  final VoidCallback onOfflineSearch;
  final VoidCallback onMinidayReport;
  final VoidCallback onMonthlyReport;
  final VoidCallback onSettings;

  const _DashboardActionStrip({
    required this.onCustomerList,
    required this.onDownloadData,
    required this.onOfflineSearch,
    required this.onMinidayReport,
    required this.onMonthlyReport,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _ActionTile(
            icon: Iconsax.user_tag,
            label: 'Customer List',
            onTap: onCustomerList,
          ),
          _ActionTile(
            icon: Iconsax.document_download,
            label: 'Download Data',
            onTap: onDownloadData,
          ),
          _ActionTile(
            icon: Iconsax.search_status,
            label: 'Offline Search',
            onTap: onOfflineSearch,
          ),
          _ActionTile(
            icon: Iconsax.calendar_1,
            label: 'Miniday Report',
            onTap: onMinidayReport,
          ),
          _ActionTile(
            icon: Iconsax.chart_2,
            label: 'Monthly Report',
            onTap: onMonthlyReport,
          ),
          _ActionTile(
            icon: Iconsax.setting_2,
            label: 'Settings',
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.paddingS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Ink(
          width: 138,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingS,
            vertical: AppSizes.paddingM,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardFilterChips extends StatelessWidget {
  const _DashboardFilterChips();

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, {bool active = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.border.withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Iconsax.arrow_down_1,
              size: 14,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          chip('Complaints', active: true),
          const SizedBox(width: 10),
          chip('Unpaid'),
          const SizedBox(width: 10),
          chip('Nearest'),
          const SizedBox(width: 10),
          chip('PayLater'),
        ],
      ),
    );
  }
}
