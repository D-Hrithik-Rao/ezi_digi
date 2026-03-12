import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'widgets/complaint_card.dart';
import 'widgets/summary_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/ezy_digi_pics.png',
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'Dashboard',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: const [
          Icon(Iconsax.search_normal),
          SizedBox(width: 8),
          Icon(Iconsax.bluetooth),
          SizedBox(width: 8),
          Icon(Iconsax.calendar_1),
          SizedBox(width: 8),
          Icon(Iconsax.scan_barcode),
          SizedBox(width: 12),
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
          Row(
            children: const [
              Expanded(
                child: SummaryCard(
                  title: 'Due Amount',
                  amount: '₹ 24,560',
                  subtitle: '120 customers',
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: SummaryCard(
                  title: 'Month Billing',
                  amount: '₹ 1,20,000',
                  subtitle: 'This month',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: const [
              Expanded(
                child: SummaryCard(
                  title: 'Onetime Charges',
                  amount: '₹ 8,450',
                  subtitle: 'Installations',
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: SummaryCard(
                  title: 'LCO Wallet',
                  amount: '₹ 15,320',
                  subtitle: 'Available',
                  color: AppColors.primary,
                  lottieAsset: 'assets/register.json',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: const [
              Expanded(
                child: SummaryCard(
                  title: 'Collections',
                  amount: '₹ 92,610',
                  subtitle: 'Today',
                  color: AppColors.accent,
                ),
              ),
              SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: SummaryCard(
                  title: 'Quick Stats',
                  amount: '324',
                  subtitle: 'Active customers',
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              _QuickActionChip(
                icon: Iconsax.user_tag,
                label: 'Customer List',
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.paddingS),
              _QuickActionChip(
                icon: Iconsax.document_download,
                label: 'Download Data',
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSizes.paddingS),
              _QuickActionChip(
                icon: Iconsax.search_status,
                label: 'Offline Search',
                color: AppColors.accent,
              ),
            ],
          ),
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

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingS,
          horizontal: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.16),
              color.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

