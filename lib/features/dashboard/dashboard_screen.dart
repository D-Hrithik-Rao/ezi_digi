import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/location_sync_service.dart';
import '../../main.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'widgets/complaint_card.dart';
import 'widgets/summary_card.dart';
import '../customers/customer_list_screen.dart';
import 'dashboard_screen_v2.dart';

enum _DashboardFeed {
  complaints,
  unpaid,
  nearest,
  payLater,
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  int _selectedTab = 0;
  _DashboardFeed _selectedFeed = _DashboardFeed.complaints;

  @override
  void initState() {
    super.initState();
    LocationSyncService.instance.onScreenOpened(TrackingScreen.dashboard);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    LocationSyncService.instance.stopDashboardTracking();
    super.dispose();
  }

  @override
  void didPushNext() {
    LocationSyncService.instance.onScreenOpened(TrackingScreen.other);
  }

  @override
  void didPopNext() {
    LocationSyncService.instance.onScreenOpened(TrackingScreen.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    // Render the stable v2 dashboard that matches your screenshot/layout.
    return const DashboardScreenV2();
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = AppSizes.paddingS;
              const lcoWalletPurple = Color(0xFF7C4DFF);

              Widget card({
                required String title,
                required String amount,
                required String subtitle,
                required Color color,
                String? lottieAsset,
                bool hardVariant = false,
              }) {
                return SummaryCard(
                  title: title,
                  amount: amount,
                  subtitle: subtitle,
                  color: color,
                  lottieAsset: lottieAsset,
                  hardVariant: hardVariant,
                );
              }

              // Requested layout:
              // Row 1: Due Amount + Month Billing + Onetime Charges
              // Row 2: LCO Wallet + Collections
              //
              // Match reference: always show 3 cards in the first row.
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: card(
                          title: 'Due Amount',
                          amount: '₹ 24,560',
                          subtitle: '120 customers',
                          color: AppColors.secondary,
                          hardVariant: false,
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: card(
                          title: 'Month Billing',
                          amount: '₹ 1,20,000',
                          subtitle: 'This month',
                          color: const Color.fromARGB(255, 243, 35, 8),
                          hardVariant: false,
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: card(
                          title: 'Onetime Charges',
                          amount: '₹ 8,450',
                          subtitle: 'Installations',
                          color: const Color.fromARGB(255, 245, 66, 185),
                          hardVariant: false,
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
                          color: AppColors.accent,
                          hardVariant: true,
                          lottieAsset: 'assets/register.json',
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: card(
                          title: 'Collections',
                          amount: '₹ 92,610',
                          subtitle: 'Today',
                          color: lcoWalletPurple,
                          hardVariant: true,
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
          _DashboardActionGrid(
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
          _DashboardFilterChips(
            selected: _selectedFeed,
            onSelected: (v) => setState(() => _selectedFeed = v),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.7),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: _buildFeedList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedList() {
    return switch (_selectedFeed) {
      _DashboardFeed.complaints => Column(
          children: const [
            ComplaintCard(
              complaintId: 'CMP-10234',
              name: 'Rahul Sharma',
              description: 'No signal since morning, set top box not responding.',
              status: ComplaintStatus.assigned,
            ),
            ComplaintCard(
              complaintId: 'CMP-10231',
              name: 'Priya Verma',
              description: 'HD channels are not working on primary TV.',
              status: ComplaintStatus.inProcess,
            ),
            ComplaintCard(
              complaintId: 'CMP-10228',
              name: 'Ankit Jain',
              description: 'Billing mismatch for last month statement.',
              status: ComplaintStatus.assigned,
            ),
          ],
        ),
      _DashboardFeed.unpaid => Column(
          children: const [
            ComplaintCard(
              complaintId: 'UNP-0007',
              name: 'Customer One Twentyseven',
              description: 'Pending amount ₹ 1,411.00',
              status: ComplaintStatus.assigned,
            ),
            ComplaintCard(
              complaintId: 'UNP-0002',
              name: 'Customer Two',
              description: 'Pending amount ₹ 589.00',
              status: ComplaintStatus.inProcess,
            ),
            ComplaintCard(
              complaintId: 'UNP-0001',
              name: 'Customer Three',
              description: 'Pending amount ₹ 642.00',
              status: ComplaintStatus.assigned,
            ),
          ],
        ),
      _DashboardFeed.nearest => Column(
          children: const [
            ComplaintCard(
              complaintId: 'NEA-0011',
              name: 'Shaker',
              description: 'Distance: 0.8 km',
              status: ComplaintStatus.assigned,
            ),
            ComplaintCard(
              complaintId: 'NEA-0013',
              name: 'Amol',
              description: 'Distance: 1.9 km',
              status: ComplaintStatus.inProcess,
            ),
            ComplaintCard(
              complaintId: 'NEA-0018',
              name: 'Banu',
              description: 'Distance: 2.4 km',
              status: ComplaintStatus.assigned,
            ),
          ],
        ),
      _DashboardFeed.payLater => Column(
          children: const [
            ComplaintCard(
              complaintId: 'PL-1020',
              name: 'Pay Later Customer',
              description: 'Installment pending (next due soon)',
              status: ComplaintStatus.assigned,
            ),
            ComplaintCard(
              complaintId: 'PL-1017',
              name: 'Pay Later Customer',
              description: 'Installment in progress',
              status: ComplaintStatus.inProcess,
            ),
            ComplaintCard(
              complaintId: 'PL-1012',
              name: 'Pay Later Customer',
              description: 'Installment pending (2nd reminder)',
              status: ComplaintStatus.assigned,
            ),
          ],
        ),
    };
  }
}

class _DashboardActionGrid extends StatelessWidget {
  final VoidCallback onCustomerList;
  final VoidCallback onDownloadData;
  final VoidCallback onOfflineSearch;
  final VoidCallback onMinidayReport;
  final VoidCallback onMonthlyReport;
  final VoidCallback onSettings;

  const _DashboardActionGrid({
    required this.onCustomerList,
    required this.onDownloadData,
    required this.onOfflineSearch,
    required this.onMinidayReport,
    required this.onMonthlyReport,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.paddingS,
      crossAxisSpacing: AppSizes.paddingS,
      childAspectRatio: 1.55,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingS,
          vertical: AppSizes.paddingS,
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
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardFilterChips extends StatelessWidget {
  final _DashboardFeed selected;
  final ValueChanged<_DashboardFeed> onSelected;

  const _DashboardFilterChips({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, {bool active = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Iconsax.arrow_down_1,
              size: 13,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          GestureDetector(
            onTap: () => onSelected(_DashboardFeed.complaints),
            child: chip(
              'Complaints',
              active: selected == _DashboardFeed.complaints,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onSelected(_DashboardFeed.unpaid),
            child: chip(
              'Unpaid',
              active: selected == _DashboardFeed.unpaid,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onSelected(_DashboardFeed.nearest),
            child: chip(
              'Nearest',
              active: selected == _DashboardFeed.nearest,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onSelected(_DashboardFeed.payLater),
            child: chip(
              'PayLater',
              active: selected == _DashboardFeed.payLater,
            ),
          ),
        ],
      ),
    );
  }
}
